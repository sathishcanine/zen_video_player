package com.player.zen_video_player

import android.media.audiofx.Visualizer
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** Streams waveform + FFT from Android [Visualizer] for the audio player session. */
class AudioVisualizerBridge(messenger: BinaryMessenger) {

    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
    private var visualizer: Visualizer? = null
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    fun register() {
        eventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            },
        )
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val sessionId = call.argument<Int>("sessionId") ?: 0
                    result.success(start(sessionId))
                }
                "stop" -> {
                    stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun start(sessionId: Int): Boolean {
        stop()
        if (sessionId == 0) return false
        return try {
            val v = Visualizer(sessionId)
            val range = Visualizer.getCaptureSizeRange()
            v.captureSize = range[1]
            val rate = Visualizer.getMaxCaptureRate().coerceAtMost(20_000)
            v.setDataCaptureListener(
                object : Visualizer.OnDataCaptureListener {
                    override fun onWaveFormDataCapture(
                        visualizer: Visualizer?,
                        waveform: ByteArray?,
                        samplingRate: Int,
                    ) {
                        if (waveform == null) return
                        val samples = IntArray(waveform.size) { i ->
                            (waveform[i].toInt() and 0xFF) - 128
                        }
                        postEvent(mapOf("type" to "wave", "data" to samples.toList()))
                    }

                    override fun onFftDataCapture(
                        visualizer: Visualizer?,
                        fft: ByteArray?,
                        samplingRate: Int,
                    ) {
                        if (fft == null || fft.size < 4) return
                        val mags = ArrayList<Double>((fft.size - 2) / 2)
                        var i = 2
                        while (i + 1 < fft.size) {
                            val r = fft[i].toDouble()
                            val im = fft[i + 1].toDouble()
                            mags.add(kotlin.math.hypot(r, im))
                            i += 2
                        }
                        postEvent(mapOf("type" to "fft", "data" to mags))
                    }
                },
                rate,
                true,
                true,
            )
            v.enabled = true
            visualizer = v
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun postEvent(payload: Map<String, Any>) {
        mainHandler.post { eventSink?.success(payload) }
    }

    private fun stop() {
        try {
            visualizer?.enabled = false
            visualizer?.release()
        } catch (_: Exception) {
            // ignore
        }
        visualizer = null
    }

    companion object {
        private const val METHOD_CHANNEL = "zen.audio/visualizer"
        private const val EVENT_CHANNEL = "zen.audio/visualizer_stream"
    }
}
