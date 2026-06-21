package com.player.zen_video_player

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/** Handles play/pause taps on the PiP overlay action button. */
class PipActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        try {
            if (intent?.action == MainActivity.ACTION_PIP_TOGGLE_PLAY_PAUSE) {
                MainActivity.notifyPipToggleFromReceiver()
            }
        } catch (e: Exception) {
            Log.w("ZenPip", "PipActionReceiver failed: ${e.message}")
        }
    }
}
