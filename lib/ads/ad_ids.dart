/// Ad network IDs — [kUseTestAdIds] switches Google sample AdMob units + Unity
/// test mode + InMobi "test" slots vs **live** dashboard values.
///
/// **Production:** set [kUseTestAdIds] to `false` and set native **AdMob app id**
/// (`AndroidManifest` / `Info.plist` `GADApplicationIdentifier`) to the same
/// value as [adMobAppId] (your live `~` string).
///
/// **Current:** `true` — Google sample app id + sample ad units + Unity test
/// mode + InMobi test placement constants. Flip to `false` before release.
///
/// [kUseTestAdIds] must be a compile-time constant.
const bool kUseTestAdIds = true;

// --- Google AdMob (official sample app + ad units) ---
// See: https://developers.google.com/admob/android/test-ads#sample_ad_units
const String _adMobTestAppId = 'ca-app-pub-3940256099942544~3347511713';
const String _adMobTestRewardedUnit = 'ca-app-pub-3940256099942544/5224354917';
const String _adMobTestBannerUnit = 'ca-app-pub-3940256099942544/6300978111';
/// Native Advanced — Google sample unit (see AdMob test ads doc).
const String _adMobTestNativeAdvancedUnit =
    'ca-app-pub-3940256099942544/2247696110';

// Your AdMob app id (iOS "App ID" / Android Application ID) — must match
// `com.google.android.gms.ads.APPLICATION_ID` in AndroidManifest and
// `GADApplicationIdentifier` in iOS `Info.plist` when not using test app id.
const String _adMobProdAppId = 'ca-app-pub-8723888126390754~6064872820';
const String _adMobProdRewardedUnit = 'ca-app-pub-8723888126390754/7234751166';
/// Pro unlock (dark theme, accent color, find duplicate).
const String _adMobProdUnlockRewardedUnit =
    'ca-app-pub-8723888126390754/8579446752';
/// Home screen bottom banner (library shell).
const String _adMobProdBannerUnit = 'ca-app-pub-8723888126390754/4197348615';
/// Video preview screen (pre-play).
const String _adMobProdNativeAdvancedUnit =
    'ca-app-pub-8723888126390754/5486908814';
/// Video player — shown when user pauses playback.
const String _adMobProdPauseNativeUnit =
    'ca-app-pub-8723888126390754/7649508461';

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

// --- InMobi: placement IDs are always from your InMobi account. Edit the
// "prod" consts to your live placements; for testing, use separate test
// placements in the dashboard and register the device (GAID / IDFA) as a
// test device, or use the same IDs with a test / staging app in the console.
const String _inMobiTestAccountId = '10000195071';
const String _inMobiTestRewardedPlacement = '10000672165';
const String _inMobiTestBannerPlacement = '10000672163';
const String _inMobiProdAccountId = '10000195071';
const String _inMobiProdRewardedPlacement = '10000672165';
const String _inMobiProdBannerPlacement = '10000672163';

// ---------------------------------------------------------------------------
// Resolved values — used by adapters

/// AdMob *application* id (`~` form), for docs / copying into native plists;
/// the adapters use [adMobRewardedUnitId] and [adMobBannerUnitId] for units.
String get adMobAppId => kUseTestAdIds ? _adMobTestAppId : _adMobProdAppId;

String get adMobRewardedUnitId =>
    kUseTestAdIds ? _adMobTestRewardedUnit : _adMobProdRewardedUnit;

String get adMobProUnlockRewardedUnitId =>
    kUseTestAdIds ? _adMobTestRewardedUnit : _adMobProdUnlockRewardedUnit;
String get adMobBannerUnitId =>
    kUseTestAdIds ? _adMobTestBannerUnit : _adMobProdBannerUnit;

String get adMobNativeAdvancedUnitId =>
    kUseTestAdIds ? _adMobTestNativeAdvancedUnit : _adMobProdNativeAdvancedUnit;

String get adMobPauseNativeUnitId =>
    kUseTestAdIds ? _adMobTestNativeAdvancedUnit : _adMobProdPauseNativeUnit;

/// Unity: `UnityAds.init(..., testMode: true)` only when [kUseTestAdIds] is
/// true. Production must use `false` in the Unity dashboard for live traffic.
bool get unityAdsTestMode => kUseTestAdIds;

String get unityAndroidGameId =>
    kUseTestAdIds ? _unityTestAndroidGameId : _unityProdAndroidGameId;
String get unityIosGameId =>
    kUseTestAdIds ? _unityTestIosGameId : _unityProdIosGameId;

String get inMobiAccountId => kUseTestAdIds ? _inMobiTestAccountId : _inMobiProdAccountId;
String get inMobiRewardedPlacementId =>
    kUseTestAdIds ? _inMobiTestRewardedPlacement : _inMobiProdRewardedPlacement;
String get inMobiBannerPlacementId =>
    kUseTestAdIds ? _inMobiTestBannerPlacement : _inMobiProdBannerPlacement;
