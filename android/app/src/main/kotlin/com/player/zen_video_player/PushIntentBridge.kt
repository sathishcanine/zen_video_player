package com.player.zen_video_player

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Opens the Play Store or launches another installed app (e.g. Minnal Browser)
 * when the user taps a promotional push notification.
 */
class PushIntentBridge(private val activity: Activity) {

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openPlayStore" -> {
                        val target = call.argument<String>("target").orEmpty()
                        openPlayStore(activity, target)
                        result.success(null)
                    }
                    "launchApp" -> {
                        val target = call.argument<String>("target").orEmpty()
                        result.success(launchApp(activity, target))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        const val CHANNEL = "zen.push_intents"

        fun openPlayStore(context: Context, target: String) {
            val packageName = resolvePackageName(target)
            if (packageName.isBlank()) return
            val marketUri = Uri.parse("market://details?id=$packageName")
            val webUri =
                Uri.parse("https://play.google.com/store/apps/details?id=$packageName")
            try {
                context.startActivity(
                    Intent(Intent.ACTION_VIEW, marketUri)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
            } catch (_: ActivityNotFoundException) {
                context.startActivity(
                    Intent(Intent.ACTION_VIEW, webUri)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
            }
        }

        /** Launches [target] when installed; otherwise opens its Play Store listing. */
        fun launchApp(context: Context, target: String): Boolean {
            val packageName = resolvePackageName(target)
            if (packageName.isBlank()) return false
            val launch = context.packageManager.getLaunchIntentForPackage(packageName)
            return if (launch != null) {
                launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(launch)
                true
            } else {
                openPlayStore(context, packageName)
                false
            }
        }

        /**
         * Accepts a package name or a Play Store / market URL (including when a
         * full URL was mistakenly passed as the `id` query value).
         */
        internal fun resolvePackageName(target: String): String {
            val trimmed = target.trim()
            if (trimmed.isEmpty()) return trimmed
            val uri = runCatching { Uri.parse(trimmed) }.getOrNull()
            val id = uri?.getQueryParameter("id")?.trim()?.takeIf { it.isNotEmpty() }
            if (id != null) return resolvePackageName(id)
            return trimmed
        }
    }
}
