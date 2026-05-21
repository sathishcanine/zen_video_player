package com.player.zen_video_player

import android.content.pm.ActivityInfo
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Activity-level sensor orientation during video playback.
 *
 * Flutter's [SystemChrome.setPreferredOrientations] often re-locks portrait on
 * Samsung devices; we own orientation here and re-apply on [MainActivity.onResume].
 */
class VideoOrientationBridge(private val activity: FlutterActivity) {

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enterPlayer" -> {
                    enterPlayerMode()
                    result.success(null)
                }
                "exitPlayer" -> {
                    exitPlayerMode()
                    result.success(null)
                }
                "toggleOrientation" -> {
                    toggleOrientation()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun enterPlayerMode() {
        if (!playerModeActive) {
            savedOrientation = activity.requestedOrientation
        }
        playerModeActive = true
        applySensorOrientation()
    }

    private fun exitPlayerMode() {
        if (!playerModeActive) return
        playerModeActive = false
        activity.requestedOrientation = savedOrientation
    }

    private fun toggleOrientation() {
        if (!playerModeActive) {
            enterPlayerMode()
        }
        val config = activity.resources.configuration
        activity.requestedOrientation =
            if (config.orientation == Configuration.ORIENTATION_LANDSCAPE) {
                ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT
            } else {
                ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
            }
    }

    private fun applySensorOrientation() {
        activity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR
    }

    companion object {
        private const val CHANNEL = "zen.video/orientation"

        private var playerModeActive: Boolean = false
        private var savedOrientation: Int = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED

        /** Re-apply after Flutter / plugins touch [Activity.setRequestedOrientation]. */
        fun reapplyIfNeeded(activity: FlutterActivity) {
            if (!playerModeActive) return
            activity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR
        }

        fun isPlayerModeActive(): Boolean = playerModeActive
    }
}
