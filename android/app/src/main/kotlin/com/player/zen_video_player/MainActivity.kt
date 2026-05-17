package com.player.zen_video_player

import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.graphics.Rect
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var inMobiBridge: InMobiBridge? = null

    /** When true, pre-Android-12 devices may enter PiP from [onUserLeaveHint]. */
    private var pipPreparedForLeave: Boolean = false

    /** Latest params for manual enter or legacy leave-hint enter. */
    private var pipParams: PictureInPictureParams? = null

    private fun rationalFromArgs(args: Map<*, *>?): Rational {
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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        inMobiBridge = InMobiBridge(
            activity = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
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
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<*, *>
                    val rational = rationalFromArgs(args)
                    val src = readSourceRect(args)
                    val autoEnter =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) true else null
                    val params = buildPipParams(
                        rational = rational,
                        sourceRect = src,
                        autoEnterEnabled = autoEnter,
                        seamlessResize = true,
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
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    @Suppress("UNCHECKED_CAST")
                    val args = call.arguments as? Map<*, *>
                    val rational = rationalFromArgs(args)
                    val src = readSourceRect(args)
                    val params = buildPipParams(
                        rational = rational,
                        sourceRect = src,
                        autoEnterEnabled = null,
                        seamlessResize = true,
                    )
                    try {
                        enterPictureInPictureMode(params)
                        result.success(true)
                    } catch (_: Exception) {
                        result.success(false)
                    }
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

    /** Reduces to small coprime integers suitable for [Rational]. */
    private fun aspectRatioRational(width: Int, height: Int): Rational {
        val g = gcd(width, height)
        var w = width / g
        var h = height / g
        while (w > 500 || h > 500) {
            w = ((w + 1) / 2).coerceAtLeast(1)
            h = ((h + 1) / 2).coerceAtLeast(1)
            val g2 = gcd(w, h)
            w = (w / g2).coerceAtLeast(1)
            h = (h / g2).coerceAtLeast(1)
        }
        return Rational(w.coerceAtLeast(1), h.coerceAtLeast(1))
    }

    override fun onDestroy() {
        inMobiBridge?.dispose()
        inMobiBridge = null
        super.onDestroy()
    }
}
