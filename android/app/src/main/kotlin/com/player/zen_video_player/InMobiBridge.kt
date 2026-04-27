package com.player.zen_video_player

import android.app.Activity
import android.util.Log
import com.google.android.gms.ads.identifier.AdvertisingIdClient
import com.inmobi.ads.AdMetaInfo
import com.inmobi.ads.InMobiAdRequestStatus
import com.inmobi.ads.InMobiInterstitial
import com.inmobi.ads.listeners.InterstitialAdEventListener
import com.inmobi.sdk.InMobiSdk
import com.inmobi.sdk.SdkInitializationListener
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/**
 * Method-channel bridge between the Dart [InMobiAdapter] and the
 * native InMobi Android SDK.
 *
 * Channel name: `zen.ads/inmobi`
 *
 * Methods:
 *   init             { accountId } -> Bool
 *   loadInterstitial { placementId } -> Bool   (true once load succeeded)
 *   loadRewarded     { placementId } -> Bool
 *   showInterstitial () -> Bool                 (true once dismissed)
 *   showRewarded     () -> Map { shown, rewarded }
 */
class InMobiBridge(
    private val activity: Activity,
    messenger: BinaryMessenger,
) {
    companion object {
        private const val TAG = "InMobiBridge"
        private const val CHANNEL = "zen.ads/inmobi"
    }

    private val channel = MethodChannel(messenger, CHANNEL)

    private var initialized = false

    private var interstitial: InMobiInterstitial? = null
    private var interstitialReady = false
    private var pendingShowInterstitial: MethodChannel.Result? = null

    private var rewarded: InMobiInterstitial? = null
    private var rewardedReady = false
    private var pendingShowRewarded: MethodChannel.Result? = null
    private var lastRewardEarned = false

    init {
        channel.setMethodCallHandler { call, result -> handle(call, result) }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> handleInit(call.argument<String>("accountId").orEmpty(), result)
            "loadInterstitial" -> handleLoad(
                call.argument<String>("placementId").orEmpty(),
                isRewarded = false,
                result = result,
            )
            "loadRewarded" -> handleLoad(
                call.argument<String>("placementId").orEmpty(),
                isRewarded = true,
                result = result,
            )
            "showInterstitial" -> handleShow(isRewarded = false, result = result)
            "showRewarded" -> handleShow(isRewarded = true, result = result)
            else -> result.notImplemented()
        }
    }

    private fun handleInit(accountId: String, result: MethodChannel.Result) {
        if (initialized) {
            result.success(true)
            return
        }
        if (!isValidId(accountId)) {
            Log.w(TAG, "init called with invalid accountId: $accountId")
            result.success(false)
            return
        }
        // Print the GAID once so the developer can copy it into the
        // InMobi (and Unity) dashboard's Test Devices list. Most
        // demand-side platforms only fill ads when test mode is set
        // to "Device" AND the device's advertising ID is registered.
        logAdvertisingId()
        // Verbose SDK logs surface the actual auction-server reason
        // behind INTERNAL_ERROR (which is a deliberate catch-all in
        // the public API). Filter for tag `InMobi` in logcat to see
        // them. Switch to NONE for production builds.
        InMobiSdk.setLogLevel(InMobiSdk.LogLevel.DEBUG)
        Log.w(
            TAG,
            "init: sdkVersion=${InMobiSdk.getVersion()} " +
                "packageName=${activity.packageName} accountId=$accountId",
        )
        // Minimal consent payload. Replace with a proper CMP-driven
        // consent string when targeting GDPR regions.
        val consent = JSONObject().apply {
            put(InMobiSdk.IM_GDPR_CONSENT_AVAILABLE, "true")
            put("gdpr", "0")
        }
        try {
            InMobiSdk.init(activity, accountId, consent, object : SdkInitializationListener {
                override fun onInitializationComplete(error: Error?) {
                    if (error != null) {
                        Log.e(TAG, "init failed: ${error.message}")
                        result.success(false)
                    } else {
                        initialized = true
                        result.success(true)
                    }
                }
            })
        } catch (e: Throwable) {
            Log.e(TAG, "init threw", e)
            result.success(false)
        }
    }

    /**
     * Fetches the device's Google Advertising ID off the main thread
     * (required by [AdvertisingIdClient]) and logs it once at WARN
     * level so it shows up clearly in `adb logcat`. Logged tag and
     * format are stable so a single grep reveals it:
     *
     *     adb logcat -s InMobiBridge | grep GAID
     */
    private fun logAdvertisingId() {
        Thread {
            try {
                val info = AdvertisingIdClient.getAdvertisingIdInfo(activity.applicationContext)
                val id = info.id ?: "<unavailable>"
                val limited = info.isLimitAdTrackingEnabled
                Log.w(
                    TAG,
                    "GAID=$id limitAdTracking=$limited — register this " +
                        "ID under InMobi → Test Devices and Unity → " +
                        "Test Devices to receive test ads.",
                )
            } catch (e: Throwable) {
                Log.w(TAG, "GAID lookup failed: ${e.message}")
            }
        }.apply {
            name = "GAIDLookup"
            isDaemon = true
        }.start()
    }

    private fun handleLoad(
        placementId: String,
        isRewarded: Boolean,
        result: MethodChannel.Result,
    ) {
        val kind = if (isRewarded) "rewarded" else "interstitial"
        if (!initialized) {
            Log.w(TAG, "load($kind) skipped: SDK not initialized")
            result.success(false)
            return
        }
        val placement = placementId.toLongOrNull()
        if (placement == null || !isValidId(placementId)) {
            Log.w(TAG, "load($kind) skipped: invalid placementId=\"$placementId\"")
            result.success(false)
            return
        }

        val resolved = ResultOnce(result)

        val listener = object : InterstitialAdEventListener() {
            override fun onAdLoadSucceeded(ad: InMobiInterstitial, info: AdMetaInfo) {
                if (isRewarded) rewardedReady = true else interstitialReady = true
                resolved.success(true)
            }

            override fun onAdLoadFailed(ad: InMobiInterstitial, status: InMobiAdRequestStatus) {
                // INTERNAL_ERROR from InMobi is a catch-all. The most common
                // causes are: placement not provisioned for this account,
                // placement type mismatch (e.g. dashboard says Banner but we
                // requested it as a rewarded interstitial), or device GAID
                // not registered as a Test Device while the account is in
                // test-only mode.
                Log.w(
                    TAG,
                    "load($kind) failed: code=${status.statusCode} " +
                        "msg=\"${status.message}\" placementId=$placement",
                )
                resolved.success(false)
            }

            override fun onAdDismissed(ad: InMobiInterstitial) {
                if (isRewarded) {
                    pendingShowRewarded?.success(
                        mapOf("shown" to true, "rewarded" to lastRewardEarned),
                    )
                    pendingShowRewarded = null
                    lastRewardEarned = false
                    rewardedReady = false
                } else {
                    pendingShowInterstitial?.success(true)
                    pendingShowInterstitial = null
                    interstitialReady = false
                }
            }

            override fun onAdDisplayFailed(ad: InMobiInterstitial) {
                if (isRewarded) {
                    pendingShowRewarded?.success(
                        mapOf("shown" to false, "rewarded" to false),
                    )
                    pendingShowRewarded = null
                    lastRewardEarned = false
                    rewardedReady = false
                } else {
                    pendingShowInterstitial?.success(false)
                    pendingShowInterstitial = null
                    interstitialReady = false
                }
            }

            override fun onRewardsUnlocked(
                ad: InMobiInterstitial,
                rewards: Map<Any, Any>?,
            ) {
                lastRewardEarned = true
            }
        }

        try {
            val ad = InMobiInterstitial(activity, placement, listener)
            if (isRewarded) rewarded = ad else interstitial = ad
            ad.load()
        } catch (e: Throwable) {
            Log.e(TAG, "load threw", e)
            resolved.success(false)
        }
    }

    private fun handleShow(isRewarded: Boolean, result: MethodChannel.Result) {
        val ad = if (isRewarded) rewarded else interstitial
        val ready = if (isRewarded) rewardedReady else interstitialReady
        if (ad == null || !ready) {
            if (isRewarded) {
                result.success(mapOf("shown" to false, "rewarded" to false))
            } else {
                result.success(false)
            }
            return
        }
        // Stash the pending result; the listener resolves it from
        // onAdDismissed / onAdDisplayFailed.
        if (isRewarded) {
            pendingShowRewarded = result
        } else {
            pendingShowInterstitial = result
        }
        try {
            ad.show()
        } catch (e: Throwable) {
            Log.e(TAG, "show threw", e)
            if (isRewarded) {
                pendingShowRewarded?.success(mapOf("shown" to false, "rewarded" to false))
                pendingShowRewarded = null
            } else {
                pendingShowInterstitial?.success(false)
                pendingShowInterstitial = null
            }
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        interstitial = null
        rewarded = null
        pendingShowInterstitial = null
        pendingShowRewarded = null
    }

    /** Reject obvious placeholder strings so a misconfigured app fails fast. */
    private fun isValidId(value: String): Boolean {
        if (value.isBlank()) return false
        if (value.startsWith("INMOBI_")) return false
        return true
    }

    /** Guarantees a [MethodChannel.Result] is completed at most once. */
    private class ResultOnce(private val inner: MethodChannel.Result) {
        private var completed = false
        fun success(value: Any?) {
            if (completed) return
            completed = true
            inner.success(value)
        }
    }
}
