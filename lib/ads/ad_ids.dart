/// Ad network IDs — [kUseTestAdIds] switches Google sample AdMob units vs
/// **live** dashboard values.
///
/// Meta, Unity, and Pangle are mediated inside AdMob — map
/// account/placement IDs in the AdMob console only.
///
/// **Production:** set [kUseTestAdIds] to `false` and set native **AdMob app id**
/// (`AndroidManifest` / `Info.plist` `GADApplicationIdentifier`) to the same
/// value as [adMobAppId] (your live `~` string).
///
/// **Production:** [kUseTestAdIds] is `false` — live app id + units below must
/// match AdMob dashboard and native manifest / Info.plist.
///
/// [kUseTestAdIds] must be a compile-time constant. true == testing, false == production
const bool kUseTestAdIds = false;

/// Pause-overlay native ads (local + network units). Set false to skip load/request.
const bool kPauseNativeAdsEnabled = false;

// --- Google AdMob (official sample app + ad units) ---
// See: https://developers.google.com/admob/android/test-ads#sample_ad_units
const String _adMobTestAppId = 'ca-app-pub-3940256099942544~3347511713';
const String _adMobTestRewardedUnit = 'ca-app-pub-3940256099942544/5224354917';
const String _adMobTestRewardedInterstitialUnit =
    'ca-app-pub-3940256099942544/5354046379';
const String _adMobTestInterstitialUnit =
    'ca-app-pub-3940256099942544/1033173712';
const String _adMobTestBannerUnit = 'ca-app-pub-3940256099942544/6300978111';
/// Native Advanced — Google sample unit (see AdMob test ads doc).
const String _adMobTestNativeAdvancedUnit =
    'ca-app-pub-3940256099942544/2247696110';

/// Live AdMob **application** id — must match AndroidManifest
/// `com.google.android.gms.ads.APPLICATION_ID` and iOS
/// `GADApplicationIdentifier` (tilde `~` form, not slash).
const String kAdMobProdApplicationId = 'ca-app-pub-8723888126390754~6064872820';

const String _adMobProdAppId = kAdMobProdApplicationId;

// Live ad units (names from AdMob console):
//   rewarded              → general playback rewarded
//   Pro-User-Rewarded     → pro settings unlock
//   Native-ad             → video preview native
//   v3-Pause-Native-Ad    → player pause / end native (network stream)
//   pause-native-local    → player pause / end native (local / content URI)
const String _adMobProdRewardedUnit = 'ca-app-pub-8723888126390754/3493871496';
const String _adMobProdRewardedInterstitialUnit =
    'ca-app-pub-8723888126390754/5103877770';
/// Video player back — engaged users only (1× per day in app logic).
const String _adMobProdVideoExitInterstitialUnit =
    'ca-app-pub-8723888126390754/8935596981';
/// Video preview back — after landing on home (no daily cap).
const String _adMobProdVideoPreviewExitInterstitialUnit =
    'ca-app-pub-8723888126390754/2414566459';
/// Network video player back — after landing on home (no session gate).
const String _adMobProdNetworkVideoExitInterstitialUnit =
    'ca-app-pub-8723888126390754/8393651444';
const String _adMobProdUnlockRewardedUnit =
    'ca-app-pub-8723888126390754/8579446752';
const String _adMobProdNativeAdvancedUnit =
    'ca-app-pub-8723888126390754/8811473905';
const String _adMobProdPauseNativeNetworkUnit =
    'ca-app-pub-8723888126390754/7649508461';
const String _adMobProdPauseNativeLocalUnit =
    'ca-app-pub-8723888126390754/4924176731';

// --- Unity Ads: each **platform has its own Game ID** in the Monetization
// dashboard. Using a legacy "sample" pair (e.g. 14850 / 14851) can trigger
// `PUBLIC_ERROR_CODE_INIT_MISMATCHED_PLATFORM` if that ID is not the one
// registered for this OS on Unity’s side.
//
// For testing, use the **same** Android / iOS Game IDs you see under **Project
// settings** for your app, and keep [unityAdsTestMode] on via
// [kUseTestAdIds] — "test" traffic is controlled by the SDK + dashboard, not
// by swapping in unrelated sample numbers.
const String _unityTestAndroidGameId = '6100151';
const String _unityTestIosGameId = '6100150';
const String _unityProdAndroidGameId = '6100151';
const String _unityProdIosGameId = '6100150';

// ---------------------------------------------------------------------------
// Resolved values — used by adapters

/// AdMob *application* id (`~` form), for docs / copying into native plists;
/// the adapters use [adMobRewardedUnitId] and [adMobBannerUnitId] for units.
String get adMobAppId => kUseTestAdIds ? _adMobTestAppId : _adMobProdAppId;

String get adMobRewardedUnitId =>
    kUseTestAdIds ? _adMobTestRewardedUnit : _adMobProdRewardedUnit;

String get adMobRewardedInterstitialUnitId => kUseTestAdIds
    ? _adMobTestRewardedInterstitialUnit
    : _adMobProdRewardedInterstitialUnit;

String get adMobVideoExitInterstitialUnitId => kUseTestAdIds
    ? _adMobTestInterstitialUnit
    : _adMobProdVideoExitInterstitialUnit;

String get adMobVideoPreviewExitInterstitialUnitId => kUseTestAdIds
    ? _adMobTestInterstitialUnit
    : _adMobProdVideoPreviewExitInterstitialUnit;

String get adMobNetworkVideoExitInterstitialUnitId => kUseTestAdIds
    ? _adMobTestInterstitialUnit
    : _adMobProdNetworkVideoExitInterstitialUnit;

String get adMobProUnlockRewardedUnitId =>
    kUseTestAdIds ? _adMobTestRewardedUnit : _adMobProdUnlockRewardedUnit;
String get adMobBannerUnitId => _adMobTestBannerUnit;

String get adMobNativeAdvancedUnitId =>
    kUseTestAdIds ? _adMobTestNativeAdvancedUnit : _adMobProdNativeAdvancedUnit;

/// Pause overlay native — local file / content URI vs network URL.
String adMobPauseNativeUnitId({required bool isLocalPlayback}) {
  if (kUseTestAdIds) return _adMobTestNativeAdvancedUnit;
  return isLocalPlayback
      ? _adMobProdPauseNativeLocalUnit
      : _adMobProdPauseNativeNetworkUnit;
}

/// Unity: `UnityAds.init(..., testMode: true)` only when [kUseTestAdIds] is
/// true. Production must use `false` in the Unity dashboard for live traffic.
bool get unityAdsTestMode => kUseTestAdIds;

String get unityAndroidGameId =>
    kUseTestAdIds ? _unityTestAndroidGameId : _unityProdAndroidGameId;
String get unityIosGameId =>
    kUseTestAdIds ? _unityTestIosGameId : _unityProdIosGameId;
