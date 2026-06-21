package com.player.zen_video_player

import android.net.Uri
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** Resolves gallery / open-with URIs to a readable file path for local Cast HTTP serving. */
class CastLocalMediaBridge(
    private val activity: FlutterActivity,
    messenger: BinaryMessenger,
) {
    private val channel = MethodChannel(messenger, CHANNEL)

    fun register() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "resolveReadablePath" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString.isNullOrBlank()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    result.success(resolveReadablePath(uriString))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun resolveReadablePath(uriString: String): String? {
        val uri = Uri.parse(uriString)
        if (uri.scheme == "file") {
            val path = uri.path
            return if (!path.isNullOrBlank() && File(path).exists()) path else null
        }
        if (uri.scheme != "content") return null

        try {
            activity.contentResolver.query(
                uri,
                arrayOf(MediaStore.MediaColumns.DATA, MediaStore.MediaColumns.DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val dataIdx = cursor.getColumnIndex(MediaStore.MediaColumns.DATA)
                    if (dataIdx >= 0) {
                        val path = cursor.getString(dataIdx)
                        if (!path.isNullOrBlank() && File(path).canRead()) {
                            return path
                        }
                    }
                }
            }
        } catch (_: Exception) {
            // Fall through to cache copy.
        }

        return try {
            val resolver = activity.contentResolver
            val mime = resolver.getType(uri)
            val ext = extensionForMime(mime)
            val out = File(activity.cacheDir, "cast_${System.currentTimeMillis()}.$ext")
            resolver.openInputStream(uri)?.use { input ->
                out.outputStream().use { output -> input.copyTo(output) }
            } ?: return null
            if (out.length() <= 0L) {
                out.delete()
                return null
            }
            out.absolutePath
        } catch (_: Exception) {
            null
        }
    }

    private fun extensionForMime(mime: String?): String {
        if (!mime.isNullOrBlank()) {
            val fromMime = MimeTypeMap.getSingleton().getExtensionFromMimeType(mime)
            if (!fromMime.isNullOrBlank()) return fromMime
        }
        return "mp4"
    }

    companion object {
        private const val CHANNEL = "zen.cast/local"
    }
}
