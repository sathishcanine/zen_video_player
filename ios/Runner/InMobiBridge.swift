import Flutter
import InMobiSDK
import UIKit

/// Method-channel bridge between the Dart `InMobiAdapter` and the
/// native InMobi iOS SDK. Mirrors `InMobiBridge.kt` on Android.
///
/// Channel name: `zen.ads/inmobi`
///
/// Note: InMobi exposes rewarded ads through `IMInterstitial` on iOS
/// — the type name is historical, the actual ad format is set in the
/// InMobi dashboard. This bridge only loads/shows rewarded.
final class InMobiBridge: NSObject {
    private static let channelName = "zen.ads/inmobi"

    private let channel: FlutterMethodChannel

    private var initialized = false

    private var rewarded: IMInterstitial?
    private var rewardedReady = false
    private var pendingShowRewarded: FlutterResult?
    private var rewardedDelegate: InterstitialEventForwarder?
    private var lastRewardEarned = false

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: InMobiBridge.channelName,
            binaryMessenger: messenger
        )
        super.init()
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
    }

    func dispose() {
        channel.setMethodCallHandler(nil)
        rewarded = nil
        rewardedDelegate = nil
        pendingShowRewarded = nil
    }

    // MARK: - Dispatch

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "init":
            handleInit(accountId: args?["accountId"] as? String ?? "", result: result)
        case "loadRewarded":
            handleLoad(
                placementId: args?["placementId"] as? String ?? "",
                result: result
            )
        case "showRewarded":
            handleShow(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Init

    private func handleInit(accountId: String, result: @escaping FlutterResult) {
        if initialized {
            result(true)
            return
        }
        guard isValidId(accountId) else {
            NSLog("[InMobiBridge] init called with invalid accountId: \(accountId)")
            result(false)
            return
        }
        // Minimal consent payload. Replace with a proper CMP-driven
        // consent string when targeting GDPR regions.
        let consent: [String: Any] = [
            IM_GDPR_CONSENT_AVAILABLE: "true",
            "gdpr": "0"
        ]
        IMSdk.initWithAccountID(accountId, consentDictionary: consent) { [weak self] error in
            if let error = error {
                NSLog("[InMobiBridge] init failed: \(error.localizedDescription)")
                result(false)
            } else {
                self?.initialized = true
                result(true)
            }
        }
    }

    // MARK: - Load

    private func handleLoad(
        placementId: String,
        result: @escaping FlutterResult
    ) {
        if !initialized {
            result(false)
            return
        }
        guard let placementInt = Int64(placementId), isValidId(placementId) else {
            result(false)
            return
        }

        let resolved = ResultOnce(result)
        let forwarder = InterstitialEventForwarder(
            onLoaded: { [weak self] in
                self?.rewardedReady = true
                resolved.success(true)
            },
            onLoadFailed: { error in
                NSLog("[InMobiBridge] load failed: \(error?.localizedDescription ?? "unknown")")
                resolved.success(false)
            },
            onDismissed: { [weak self] in
                guard let self = self else { return }
                self.pendingShowRewarded?([
                    "shown": true,
                    "rewarded": self.lastRewardEarned
                ])
                self.pendingShowRewarded = nil
                self.lastRewardEarned = false
                self.rewardedReady = false
            },
            onDisplayFailed: { [weak self] in
                guard let self = self else { return }
                self.pendingShowRewarded?([
                    "shown": false,
                    "rewarded": false
                ])
                self.pendingShowRewarded = nil
                self.lastRewardEarned = false
                self.rewardedReady = false
            },
            onRewardsUnlocked: { [weak self] in
                self?.lastRewardEarned = true
            }
        )

        let ad = IMInterstitial(placementId: placementInt)
        ad.delegate = forwarder
        rewarded = ad
        rewardedDelegate = forwarder

        ad.load()
    }

    // MARK: - Show

    private func handleShow(result: @escaping FlutterResult) {
        guard let ad = rewarded, rewardedReady else {
            result(["shown": false, "rewarded": false])
            return
        }
        pendingShowRewarded = result
        guard let root = topViewController() else {
            pendingShowRewarded = nil
            result(["shown": false, "rewarded": false])
            return
        }
        ad.show(from: root)
    }

    private func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        return top
    }

    private func isValidId(_ value: String) -> Bool {
        if value.isEmpty { return false }
        if value.hasPrefix("INMOBI_") { return false }
        return true
    }
}

// MARK: - Helpers

/// Forwards InMobi rewarded events (delivered through the
/// `IMInterstitialDelegate` API) to closures so the bridge stays small.
private final class InterstitialEventForwarder: NSObject, IMInterstitialDelegate {
    private let onLoaded: () -> Void
    private let onLoadFailed: (Error?) -> Void
    private let onDismissed: () -> Void
    private let onDisplayFailed: () -> Void
    private let onRewardsUnlocked: () -> Void

    init(
        onLoaded: @escaping () -> Void,
        onLoadFailed: @escaping (Error?) -> Void,
        onDismissed: @escaping () -> Void,
        onDisplayFailed: @escaping () -> Void,
        onRewardsUnlocked: @escaping () -> Void
    ) {
        self.onLoaded = onLoaded
        self.onLoadFailed = onLoadFailed
        self.onDismissed = onDismissed
        self.onDisplayFailed = onDisplayFailed
        self.onRewardsUnlocked = onRewardsUnlocked
    }

    func interstitialDidFinishLoading(_ interstitial: IMInterstitial) {
        onLoaded()
    }

    func interstitial(
        _ interstitial: IMInterstitial,
        didFailToLoadWithError error: IMRequestStatus
    ) {
        onLoadFailed(error)
    }

    func interstitial(
        _ interstitial: IMInterstitial,
        didFailToPresentWithError error: IMRequestStatus
    ) {
        onDisplayFailed()
    }

    func interstitialDidDismiss(_ interstitial: IMInterstitial) {
        onDismissed()
    }

    func interstitial(
        _ interstitial: IMInterstitial,
        rewardActionCompletedWithRewards rewards: [AnyHashable: Any]
    ) {
        onRewardsUnlocked()
    }
}

/// Guarantees a [FlutterResult] is invoked at most once.
private final class ResultOnce {
    private var inner: FlutterResult?
    init(_ result: @escaping FlutterResult) {
        self.inner = result
    }
    func success(_ value: Any?) {
        guard let inner = inner else { return }
        self.inner = nil
        inner(value)
    }
}
