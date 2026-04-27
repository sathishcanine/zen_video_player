package com.player.zen_video_player

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var inMobiBridge: InMobiBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Wire the InMobi method channel. The Dart side talks to it via
        // the channel name "zen.ads/inmobi" inside InMobiAdapter.
        inMobiBridge = InMobiBridge(
            activity = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun onDestroy() {
        inMobiBridge?.dispose()
        inMobiBridge = null
        super.onDestroy()
    }
}
