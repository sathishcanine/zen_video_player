package com.player.zen_video_player

import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.Rect
import android.os.Build
import android.util.Log
import android.util.Rational
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

class MainActivity : AudioServiceActivity() {

    private var audioMetadataBridge: AudioMetadataBridge? = null
    private var audioVisualizerBridge: AudioVisualizerBridge? = null
    private var mediaAssetBridge: MediaAssetBridge? = null
    private var castLocalMediaBridge: CastLocalMediaBridge? = null
    private var videoOrientationBridge: VideoOrientationBridge? = null

    /** When true, pre-Android-12 devices may enter PiP from [onUserLeaveHint]. */
    private var pipPreparedForLeave: Boolean = false

    /** Latest params for manual enter or legacy leave-hint enter. */
    private var pipParams: PictureInPictureParams? = null

    private var pipModeSink: EventChannel.EventSink? = null

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

    private fun readSourceRect(args: Map<*, *>?): Rect? {
        if (args == null) return null
        val l = (args["srcLeft"] as? Number)?.toInt() ?: return null
        val t = (args["srcTop"] as? Number)?.toInt() ?: return null
        val r = (args["srcRight"] as? Number)?.toInt() ?: return null
        val b = (args["srcBottom"] as? Number)?.toInt() ?: return null
        if (r <= l || b <= t) return null
        return Rect(l, t, r, b)
    }

    /**
     * [autoEnterEnabled] null = leave unset (manual enter). Non-null sets auto-enter on API 31+.
     */
    private fun buildPipParams(
        rational: Rational,
        sourceRect: Rect?,
        autoEnterEnabled: Boolean?,
        seamlessResize: Boolean,
    ): PictureInPictureParams {
        val b = PictureInPictureParams.Builder().setAspectRatio(rational)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && sourceRect != null) {
            b.setSourceRectHint(sourceRect)
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

    override fun onResume() {
        super.onResume()
        VideoOrientationBridge.reapplyIfNeeded(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        audioMetadataBridge = AudioMetadataBridge(this, messenger).also { it.register() }
        audioVisualizerBridge = AudioVisualizerBridge(messenger).also { it.register() }
        mediaAssetBridge = MediaAssetBridge(this, messenger).also { it.register() }
        castLocalMediaBridge = CastLocalMediaBridge(this, messenger).also { it.register() }
        videoOrientationBridge = VideoOrientationBridge(this).also { it.register(messenger) }

        EventChannel(messenger, "zen.video/pip_events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    pipModeSink = events
                    events?.success(isInPictureInPictureMode)
                }

                override fun onCancel(arguments: Any?) {
                    pipModeSink = null
                }
            },
        )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "zen.video/pip",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "prepare" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    if (!packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    // Do not update params while in PiP — causes aspect-ratio oscillation.
                    if (isInPictureInPictureMode) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<*, *>
                    val rational = rationalFromArgs(args)
                    val autoEnter =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) true else null
                    val params = buildPipParams(
                        rational = rational,
                        sourceRect = null,
                        autoEnterEnabled = autoEnter,
                        seamlessResize = false,
                    )
                    pipParams = params
                    pipPreparedForLeave = true
                    try {
                        setPictureInPictureParams(params)
                    } catch (_: Exception) {
                        // ignore
                    }
                    result.success(null)
                }
                "clear" -> {
                    pipPreparedForLeave = false
                    pipParams = null
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
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onUserLeaveHint() {
        // Flutter's AppLifecycleState.paused is too late: enterPictureInPictureMode
        // must run while still resumed. API 31+ uses setAutoEnterEnabled on prepare;
        // API 26–30 enter here when the user presses Home / switches away.
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
        pipModeSink?.success(isInPictureInPictureMode)
        if (!isInPictureInPictureMode) {
            pipPreparedForLeave = false
        }
    }

    /** Tries PiP enter with a stable decoder aspect ratio (no multi-ratio loop). */
    private fun tryEnterPip(args: Map<*, *>?): Boolean {
        if (isInPictureInPictureMode) return true
        val rational = rationalFromArgs(args)
        val landscape = rational.numerator >= rational.denominator

        val attempts = mutableListOf(
            buildPipParams(rational, null, null, seamlessResize = false),
            buildPipParams(
                if (landscape) Rational(16, 9) else Rational(9, 16),
                null,
                null,
                seamlessResize = false,
            ),
        )

        for (params in attempts) {
            if (enterPipWithParams(params)) {
                pipParams = params
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

    /** Reduces to integers suitable for [Rational] (must stay within PiP aspect bounds). */
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
        // Scale proportionally — never clamp w and h independently (that made 853×480 → 239×239 square).
        if (w > 239 || h > 239) {
            val scale = maxOf(w / 239.0, h / 239.0)
            w = maxOf(1, (w / scale).roundToInt())
            h = maxOf(1, (h / scale).roundToInt())
            g = gcd(w, h)
            w /= g
            h /= g
        }
        return Rational(w.coerceAtLeast(1), h.coerceAtLeast(1))
    }

    companion object {
        private const val TAG = "ZenPip"
    }

}
