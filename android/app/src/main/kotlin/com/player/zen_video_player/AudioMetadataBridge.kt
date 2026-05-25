package com.player.zen_video_player

import android.media.MediaMetadataRetriever
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Reads embedded audio tags and album art via [MediaMetadataRetriever]. */
class AudioMetadataBridge(
    private val activity: FlutterActivity,
    messenger: BinaryMessenger,
) {

    private val channel = MethodChannel(messenger, CHANNEL)

    fun register() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getArtwork" -> {
                    val source = readSourceArg(call.arguments)
                    if (source.isNullOrBlank()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    result.success(readArtwork(source))
                }
                "getMetadata" -> {
                    val source = readSourceArg(call.arguments)
                    if (source.isNullOrBlank()) {
                        result.success(null)
                        return@setMethodCallHandler
                    }
                    result.success(readMetadata(source))
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun readSourceArg(arguments: Any?): String? {
        val map = arguments as? Map<*, *> ?: return null
        return (map["uri"] as? String)?.takeIf { it.isNotBlank() }
            ?: (map["path"] as? String)?.takeIf { it.isNotBlank() }
    }

    private fun openRetriever(source: String): MediaMetadataRetriever? {
        val retriever = MediaMetadataRetriever()
        return try {
            if (source.startsWith("content://")) {
                retriever.setDataSource(activity, Uri.parse(source))
            } else {
                val path = source.removePrefix("file://")
                retriever.setDataSource(path)
            }
            retriever
        } catch (_: Exception) {
            try {
                retriever.release()
            } catch (_: Exception) {
                // ignore
            }
            null
        }
    }

    private fun readArtwork(source: String): ByteArray? {
        val retriever = openRetriever(source) ?: return null
        return try {
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

    private fun readMetadata(source: String): Map<String, Any?> {
        val retriever = openRetriever(source) ?: return emptyMetadata()
        return try {
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
            emptyMetadata()
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
                // ignore
            }
        }
    }

    private fun emptyMetadata(): Map<String, Any?> = mapOf(
        "album" to "",
        "artist" to "",
        "title" to "",
        "hasArtwork" to false,
    )

    companion object {
        private const val CHANNEL = "zen.audio/metadata"
    }
}
