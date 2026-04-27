import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  /// Holds the InMobi method-channel bridge for the lifetime of the app.
  /// The Dart side talks to it via the `zen.ads/inmobi` channel inside
  /// `InMobiAdapter`.
  private var inMobiBridge: InMobiBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      inMobiBridge = InMobiBridge(messenger: controller.binaryMessenger)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    inMobiBridge?.dispose()
    inMobiBridge = nil
    super.applicationWillTerminate(application)
  }
}
