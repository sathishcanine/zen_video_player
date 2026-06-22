package com.player.zen_video_player

import android.app.PictureInPictureParams
import android.app.PendingIntent
import android.app.RemoteAction
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.Rect
import android.graphics.drawable.Icon
import android.os.Build
import android.util.Log
import android.util.Rational
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import kotlin.math.roundToInt

class MainActivity : AudioServiceActivity() {

    private var audioMetadataBridge: AudioMetadataBridge? = null
    private var audioVisualizerBridge: AudioVisualizerBridge? = null
    private var mediaAssetBridge: MediaAssetBridge? = null
    private var castLocalMediaBridge: CastLocalMediaBridge? = null
    private var videoOrientationBridge: VideoOrientationBridge? = null
    private var pushIntentBridge: PushIntentBridge? = null

    /** When true, pre-Android-12 devices may enter PiP from [onUserLeaveHint]. */
    private var pipPreparedForLeave: Boolean = false

    /** Latest params for manual enter or legacy leave-hint enter. */
    private var pipParams: PictureInPictureParams? = null

    private var pipModeSink: EventChannel.EventSink? = null
    private var pipControlSink: EventChannel.EventSink? = null

    private var lastPipRational: Rational? = null
    private var pipIsPlaying: Boolean = true

    private fun rationalFromArgs(args: Map<*, *>?): Rational {
        val aspectNum = (args?.get("aspectNum") as? Number)?.toInt()
        val aspectDen = (args?.get("aspectDen") as? Number)?.toInt()
        if (aspectNum != null && aspectDen != null && aspectNum > 0 && aspectDen > 0) {
            return aspectRatioRational(aspectNum, aspectDen)
        }
        val w = (args?.get("width") as? Number)?.toInt()?.coerceAtLeast(1) ?: 16
        val h = (args?.get("height") as? Number)?.toInt()?.coerceAtLeast(1) ?: 9
        return aspectRatioRational(w, h)
    }

    private fun isPlayingFromArgs(args: Map<*, *>?): Boolean {
        return when (val v = args?.get("isPlaying")) {
            is Boolean -> v
            else -> true
        }
    }

    private fun activityAlive(): Boolean = !isFinishing && !isDestroyed

    private fun safePipModeEmit(inPip: Boolean) {
        try {
            pipModeSink?.success(inPip)
        } catch (e: Exception) {
            Log.w(TAG, "pipModeSink emit failed: ${e.message}")
            pipModeSink = null
        }
    }

    private fun safePipControlEmit(event: String) {
        try {
            pipControlSink?.success(event)
        } catch (e: Exception) {
            Log.w(TAG, "pipControlSink emit failed: ${e.message}")
            pipControlSink = null
        }
    }

    /** Called from [PipActionReceiver] on a background thread. */
    internal fun deliverPipToggleToFlutter() {
        if (!activityAlive()) return
        runOnUiThread {
            if (!activityAlive()) return@runOnUiThread
            safePipControlEmit("toggle")
        }
    }

    private fun readSourceRect(args: Map<*, *>?): Rect? {
        if (args == null) return null
        val l = (args["srcLeft"] as? Number)?.toInt() ?: return null
        val t = (args["srcTop"] as? Number)?.toInt() ?: return null
        val r = (args["srcRight"] as? Number)?.toInt() ?: return null
        val b = (args["srcBottom"] as? Number)?.toInt() ?: return null
        if (r <= l || b <= t) return null
        return Rect(l, t, r, b)
    }

    private fun createPlayPauseAction(isPlaying: Boolean): RemoteAction? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return null
        return try {
            val iconRes =
                if (isPlaying) android.R.drawable.ic_media_pause
                else android.R.drawable.ic_media_play
            val title = if (isPlaying) "Pause" else "Play"
            val intent = Intent(ACTION_PIP_TOGGLE_PLAY_PAUSE)
                .setClass(this, PipActionReceiver::class.java)
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                REQUEST_PIP_TOGGLE,
                intent,
                flags,
            )
            RemoteAction(
                Icon.createWithResource(this, iconRes),
                title,
                title,
                pendingIntent,
            )
        } catch (e: Exception) {
            Log.w(TAG, "createPlayPauseAction failed: ${e.message}")
            null
        }
    }

    /**
     * [autoEnterEnabled] null = leave unset (manual enter). Non-null sets auto-enter on API 31+.
     */
    private fun buildPipParams(
        rational: Rational,
        sourceRect: Rect?,
        autoEnterEnabled: Boolean?,
        seamlessResize: Boolean,
        isPlaying: Boolean,
    ): PictureInPictureParams {
        val b = PictureInPictureParams.Builder().setAspectRatio(rational)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && sourceRect != null) {
            b.setSourceRectHint(sourceRect)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createPlayPauseAction(isPlaying)?.let { action ->
                b.setActions(listOf(action))
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (autoEnterEnabled != null) {
                b.setAutoEnterEnabled(autoEnterEnabled)
            }
            if (seamlessResize) {
                b.setSeamlessResizeEnabled(true)
            }
        }
        return b.build()
    }

    private fun storeAndApplyPipParams(
        rational: Rational,
        isPlaying: Boolean,
        autoEnterEnabled: Boolean?,
        seamlessResize: Boolean,
        sourceRect: Rect? = null,
    ): PictureInPictureParams {
        lastPipRational = rational
        pipIsPlaying = isPlaying
        val params = buildPipParams(
            rational = rational,
            sourceRect = sourceRect,
            autoEnterEnabled = autoEnterEnabled,
            seamlessResize = seamlessResize,
            isPlaying = isPlaying,
        )
        pipParams = params
        try {
            setPictureInPictureParams(params)
        } catch (_: Exception) {
            // ignore
        }
        return params
    }

    private fun refreshPipPlayPauseAction(isPlaying: Boolean) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val rational = lastPipRational ?: return
        pipIsPlaying = isPlaying
        val autoEnter =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && pipPreparedForLeave) true else null
        storeAndApplyPipParams(
            rational = rational,
            isPlaying = isPlaying,
            autoEnterEnabled = autoEnter,
            seamlessResize = false,
        )
    }

    override fun onResume() {
        super.onResume()
        VideoOrientationBridge.reapplyIfNeeded(this)
    }

    override fun onDestroy() {
        detachPipHost(this)
        pipModeSink = null
        pipControlSink = null
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        attachPipHost(this)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        audioMetadataBridge = AudioMetadataBridge(this, messenger).also { it.register() }
        audioVisualizerBridge = AudioVisualizerBridge(messenger).also { it.register() }
        mediaAssetBridge = MediaAssetBridge(this, messenger).also { it.register() }
        castLocalMediaBridge = CastLocalMediaBridge(this, messenger).also { it.register() }
        videoOrientationBridge = VideoOrientationBridge(this).also { it.register(messenger) }
        pushIntentBridge = PushIntentBridge(this).also {
            it.register(flutterEngine)
        }

        EventChannel(messenger, "zen.video/pip_events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    pipModeSink = events
                    safePipModeEmit(isInPictureInPictureMode)
                }

                override fun onCancel(arguments: Any?) {
                    pipModeSink = null
                }
            },
        )

        EventChannel(messenger, "zen.video/pip_controls").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    pipControlSink = events
                }

                override fun onCancel(arguments: Any?) {
                    pipControlSink = null
                }
            },
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "zen.video/pip",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "prepare" -> {
                    try {
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                            result.success(null)
                            return@setMethodCallHandler
                        }
                        if (!packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)) {
                            result.success(null)
                            return@setMethodCallHandler
                        }
                        if (isInPictureInPictureMode) {
                            result.success(null)
                            return@setMethodCallHandler
                        }
                        @Suppress("UNCHECKED_CAST")
                        val args = call.arguments as? Map<*, *>
                        val rational = rationalFromArgs(args)
                        val isPlaying = isPlayingFromArgs(args)
                        val autoEnter =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) true else null
                        storeAndApplyPipParams(
                            rational = rational,
                            isPlaying = isPlaying,
                            autoEnterEnabled = autoEnter,
                            seamlessResize = false,
                        )
                        pipPreparedForLeave = true
                    } catch (e: Exception) {
                        Log.w(TAG, "prepare failed: ${e.message}")
                    }
                    result.success(null)
                }
                "updateActions" -> {
                    try {
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                            result.success(null)
                            return@setMethodCallHandler
                        }
                        @Suppress("UNCHECKED_CAST")
                        val args = call.arguments as? Map<*, *>
                        val isPlaying = isPlayingFromArgs(args)
                        refreshPipPlayPauseAction(isPlaying)
                    } catch (e: Exception) {
                        Log.w(TAG, "updateActions failed: ${e.message}")
                    }
                    result.success(null)
                }
                "clear" -> {
                    pipPreparedForLeave = false
                    pipParams = null
                    lastPipRational = null
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val off = PictureInPictureParams.Builder()
                                .setAutoEnterEnabled(false)
                                .build()
                            setPictureInPictureParams(off)
                        } catch (_: Exception) {
                            // ignore
                        }
                    }
                    result.success(null)
                }
                "enter" -> {
                    try {
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        if (!packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        if (isInPictureInPictureMode) {
                            result.success(true)
                            return@setMethodCallHandler
                        }
                        @Suppress("UNCHECKED_CAST")
                        val args = call.arguments as? Map<*, *>
                        result.success(tryEnterPip(args))
                    } catch (e: Exception) {
                        Log.w(TAG, "enter failed: ${e.message}")
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onUserLeaveHint() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S &&
            pipPreparedForLeave &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE) &&
            !isInPictureInPictureMode
        ) {
            val p = pipParams
            if (p != null) {
                try {
                    enterPictureInPictureMode(p)
                } catch (_: Exception) {
                    // ignore
                }
            }
        }
        super.onUserLeaveHint()
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration,
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        safePipModeEmit(isInPictureInPictureMode)
        if (isInPictureInPictureMode) {
            try {
                refreshPipPlayPauseAction(pipIsPlaying)
            } catch (e: Exception) {
                Log.w(TAG, "refresh PiP actions failed: ${e.message}")
            }
        } else {
            pipPreparedForLeave = false
        }
    }

    private fun tryEnterPip(args: Map<*, *>?): Boolean {
        if (isInPictureInPictureMode) return true
        val rational = rationalFromArgs(args)
        val isPlaying = isPlayingFromArgs(args)
        val landscape = rational.numerator >= rational.denominator

        val rationals = listOf(
            rational,
            if (landscape) Rational(16, 9) else Rational(9, 16),
        )

        for (r in rationals) {
            val params = storeAndApplyPipParams(
                rational = r,
                isPlaying = isPlaying,
                autoEnterEnabled = null,
                seamlessResize = false,
            )
            if (enterPipWithParams(params)) {
                pipPreparedForLeave = true
                return true
            }
        }
        Log.w(TAG, "tryEnterPip: all attempts failed")
        return false
    }

    private fun enterPipWithParams(params: PictureInPictureParams): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        if (isInPictureInPictureMode) return true
        return try {
            setPictureInPictureParams(params)
            val entered = enterPictureInPictureMode(params)
            entered || isInPictureInPictureMode
        } catch (e: Exception) {
            Log.w(TAG, "enterPipWithParams failed: ${e.message}")
            false
        }
    }

    private fun gcd(a: Int, b: Int): Int {
        var x = kotlin.math.abs(a)
        var y = kotlin.math.abs(b)
        if (x == 0) return y.coerceAtLeast(1)
        if (y == 0) return x.coerceAtLeast(1)
        while (y != 0) {
            val t = y
            y = x % y
            x = t
        }
        return x.coerceAtLeast(1)
    }

    private fun aspectRatioRational(width: Int, height: Int): Rational {
        var w = width.coerceAtLeast(1)
        var h = height.coerceAtLeast(1)
        val minRatio = 100.0 / 239.0
        val maxRatio = 239.0 / 100.0
        var ratio = w.toDouble() / h
        if (ratio < minRatio) {
            w = (h * minRatio).roundToInt().coerceAtLeast(1)
        } else if (ratio > maxRatio) {
            h = (w / maxRatio).roundToInt().coerceAtLeast(1)
        }
        var g = gcd(w, h)
        w /= g
        h /= g
        if (w > 239 || h > 239) {
            val scale = maxOf(w / 239.0, h / 239.0)
            w = maxOf(1, (w / scale).roundToInt())
            h = maxOf(1, (h / scale).roundToInt())
            g = gcd(w, h)
            w /= g
            h /= g
        }
        return try {
            Rational(w.coerceAtLeast(1), h.coerceAtLeast(1))
        } catch (e: Exception) {
            Log.w(TAG, "Rational($w,$h) invalid, using 16:9: ${e.message}")
            Rational(16, 9)
        }
    }

    companion object {
        private const val TAG = "ZenPip"
        const val ACTION_PIP_TOGGLE_PLAY_PAUSE =
            "com.player.zen_video_player.PIP_TOGGLE_PLAY_PAUSE"
        private const val REQUEST_PIP_TOGGLE = 42_001

        private var pipHostRef: WeakReference<MainActivity> = WeakReference(null)

        fun attachPipHost(activity: MainActivity) {
            pipHostRef = WeakReference(activity)
        }

        fun detachPipHost(activity: MainActivity) {
            if (pipHostRef.get() === activity) {
                pipHostRef = WeakReference(null)
            }
        }

        fun notifyPipToggleFromReceiver() {
            pipHostRef.get()?.deliverPipToggleToFlutter()
        }
    }

}
