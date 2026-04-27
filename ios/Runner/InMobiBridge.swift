import Flutter
import InMobiSDK
import UIKit

/// Method-channel bridge between the Dart `InMobiAdapter` and the
/// native InMobi iOS SDK. Mirrors `InMobiBridge.kt` on Android.
///
/// Channel name: `zen.ads/inmobi`
final class InMobiBridge: NSObject {
    private static let channelName = "zen.ads/inmobi"

    private let channel: FlutterMethodChannel

    private var initialized = false

    private var interstitial: IMInterstitial?
    private var interstitialReady = false
    private var pendingShowInterstitial: FlutterResult?
    private var interstitialDelegate: InterstitialEventForwarder?

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
        interstitial = nil
        rewarded = nil
        interstitialDelegate = nil
        rewardedDelegate = nil
        pendingShowInterstitial = nil
        pendingShowRewarded = nil
    }

    // MARK: - Dispatch

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "init":
            handleInit(accountId: args?["accountId"] as? String ?? "", result: result)
        case "loadInterstitial":
            handleLoad(
                placementId: args?["placementId"] as? String ?? "",
                isRewarded: false,
                result: result
            )
        case "loadRewarded":
            handleLoad(
                placementId: args?["placementId"] as? String ?? "",
                isRewarded: true,
                result: result
            )
        case "showInterstitial":
            handleShow(isRewarded: false, result: result)
        case "showRewarded":
            handleShow(isRewarded: true, result: result)
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
        isRewarded: Bool,
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
                if isRewarded {
                    self?.rewardedReady = true
                } else {
                    self?.interstitialReady = true
                }
                resolved.success(true)
            },
            onLoadFailed: { error in
                NSLog("[InMobiBridge] load failed: \(error?.localizedDescription ?? "unknown")")
                resolved.success(false)
            },
            onDismissed: { [weak self] in
                guard let self = self else { return }
                if isRewarded {
                    self.pendingShowRewarded?([
                        "shown": true,
                        "rewarded": self.lastRewardEarned
                    ])
                    self.pendingShowRewarded = nil
                    self.lastRewardEarned = false
                    self.rewardedReady = false
                } else {
                    self.pendingShowInterstitial?(true)
                    self.pendingShowInterstitial = nil
                    self.interstitialReady = false
                }
            },
            onDisplayFailed: { [weak self] in
                guard let self = self else { return }
                if isRewarded {
                    self.pendingShowRewarded?([
                        "shown": false,
                        "rewarded": false
                    ])
                    self.pendingShowRewarded = nil
                    self.lastRewardEarned = false
                    self.rewardedReady = false
                } else {
                    self.pendingShowInterstitial?(false)
                    self.pendingShowInterstitial = nil
                    self.interstitialReady = false
                }
            },
            onRewardsUnlocked: { [weak self] in
                self?.lastRewardEarned = true
            }
        )

        let ad = IMInterstitial(placementId: placementInt)
        ad.delegate = forwarder

        if isRewarded {
            rewarded = ad
            rewardedDelegate = forwarder
        } else {
            interstitial = ad
            interstitialDelegate = forwarder
        }

        ad.load()
    }

    // MARK: - Show

    private func handleShow(isRewarded: Bool, result: @escaping FlutterResult) {
        let ad = isRewarded ? rewarded : interstitial
        let ready = isRewarded ? rewardedReady : interstitialReady
        guard let ad = ad, ready else {
            if isRewarded {
                result(["shown": false, "rewarded": false])
            } else {
                result(false)
            }
            return
        }
        if isRewarded {
            pendingShowRewarded = result
        } else {
            pendingShowInterstitial = result
        }
        guard let root = topViewController() else {
            if isRewarded {
                pendingShowRewarded = nil
                result(["shown": false, "rewarded": false])
            } else {
                pendingShowInterstitial = nil
                result(false)
            }
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

/// Forwards InMobi interstitial events to closures so a single bridge
/// instance can host both interstitial and rewarded delegates without
/// subclassing.
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
