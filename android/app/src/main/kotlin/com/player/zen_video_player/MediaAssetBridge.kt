package com.player.zen_video_player

import android.content.ContentUris
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Reads MediaStore metadata without exporting full media files to cache. */
class MediaAssetBridge(
    private val activity: FlutterActivity,
    messenger: BinaryMessenger,
) {
    private val channel = MethodChannel(messenger, CHANNEL)

    fun register() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getSizeBytes" -> {
                    val id = call.argument<String>("id")
                    val type = call.argument<Int>("type") ?: 2
                    if (id.isNullOrBlank()) {
                        result.success(0)
                        return@setMethodCallHandler
                    }
                    result.success(querySizeBytes(id.toLong(), type))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun querySizeBytes(id: Long, typeInt: Int): Long {
        val collection = when (typeInt) {
            1 -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            3 -> MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            else -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        }
        val uri = ContentUris.withAppendedId(collection, id)
        val projection = arrayOf(MediaStore.MediaColumns.SIZE)
        return try {
            activity.contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (!cursor.moveToFirst()) return 0L
                val idx = cursor.getColumnIndex(MediaStore.MediaColumns.SIZE)
                if (idx < 0) 0L else cursor.getLong(idx).coerceAtLeast(0L)
            } ?: 0L
        } catch (_: Exception) {
            0L
        }
    }

    companion object {
        private const val CHANNEL = "zen.media/asset"
    }
}
