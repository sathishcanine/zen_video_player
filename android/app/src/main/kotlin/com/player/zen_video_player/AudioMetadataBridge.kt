package com.player.zen_video_player

import android.media.MediaMetadataRetriever
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Reads embedded audio tags and album art via [MediaMetadataRetriever]. */
class AudioMetadataBridge(messenger: BinaryMessenger) {

    private val channel = MethodChannel(messenger, CHANNEL)

    fun register() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getArtwork" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    result.success(readArtwork(path))
                }
                "getMetadata" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    result.success(readMetadata(path))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun readArtwork(path: String): ByteArray? {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(path)
            retriever.embeddedPicture
        } catch (_: Exception) {
            null
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
                // ignore
            }
        }
    }

    private fun readMetadata(path: String): Map<String, Any?> {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(path)
            val album =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM).orEmpty()
            val artist =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST).orEmpty()
            val title =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE).orEmpty()
            val art = retriever.embeddedPicture
            mapOf(
                "album" to album,
                "artist" to artist,
                "title" to title,
                "hasArtwork" to (art != null && art.isNotEmpty()),
            )
        } catch (_: Exception) {
            mapOf(
                "album" to "",
                "artist" to "",
                "title" to "",
                "hasArtwork" to false,
            )
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
                // ignore
            }
        }
    }

    companion object {
        private const val CHANNEL = "zen.audio/metadata"
    }
}
