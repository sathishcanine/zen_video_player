# Zen Video Player

A fast, lightweight Flutter video player with deeplink-driven ad
mediation across multiple ad networks.

## Getting Started

This project is a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Ad Networks

The app uses an adapter-based architecture so any single network can
be added, removed, or hot-swapped at runtime via deeplink — useful when
one network suddenly imposes an ad-serving restriction.

### Networks now wired

- `admob` — fully working (`AdmobAdapter`). Unit IDs and the sample vs
  production switch live in `lib/ads/ad_ids.dart` (`kUseTestAdIds`, default
  **production** / `false`). With `kUseTestAdIds == true`, AdMob uses
  [Google’s sample app id and ad units](https://developers.google.com/admob/android/test-ads#sample_ad_units); native `APPLICATION_ID` / `GADApplicationIdentifier` must always match `adMobAppId` in that file.
- `unity` — fully working (`UnityAdapter`). With `kUseTestAdIds == false`
  (production), `UnityAds.init` uses **testMode: false** and your
  **production** Game IDs from [ad_ids]. With `kUseTestAdIds == true`, the
  SDK uses **test mode** for local debugging. Placements default to
  `Rewarded_Android` / `Rewarded_iOS` / `Banner_Android` / `Banner_iOS` (adjust in `UnityAdapter`
  if your ad unit names differ).
- `inmobi` — fully working through a native method-channel bridge.
  Account and placement IDs are read from `ad_ids.dart` (separate
  test/prod slots; InMobi does not publish universal sample placements —
  use your console IDs and [register the device as a test device](https://support.inmobi.com/monetize/)).
  Native code lives at:
  - `android/app/src/main/kotlin/com/player/zen_video_player/InMobiBridge.kt`
  - `ios/Runner/InMobiBridge.swift`

### Files

```
lib/ads/
├── ad_ids.dart            # Test vs production IDs (single switch: kUseTestAdIds)
├── ad_network.dart        # Common interface
├── ad_config.dart         # Config model + deeplink parser + persistence
├── ad_throttle.dart       # Frequency / hourly cap
├── ads_orchestrator.dart  # Init, fallback chain, banner builder
├── admob_adapter.dart
├── unity_adapter.dart
└── inmobi_adapter.dart
```

`lib/rewarded_ads.dart` (`AdManager`) and `lib/ads_manager.dart`
(`AdsManager`, `BannerAdWidget`) are kept as thin facades over
`AdsOrchestrator` for backwards compatibility with existing screens.

This build only serves **rewarded** and **banner** ads. Interstitial
support has been removed across the orchestrator, every adapter, the
deeplink config, and the InMobi native bridges.

## How to use the deeplink config

Append any of these query params to the existing video deeplink. All
params are optional — anything you omit keeps its previous (persisted
or default) value. Param order does not matter.

```
zenvideoplayer://play?url=<videoUrl>
    &ads=unity,admob,inmobi   # priority order (left = primary)
    &banner=1                 # 0/1
    &rew=1                    # 0/1
    &cap=30                   # hourly cap on ad requests per device
```

### Parameter reference

| Param | Purpose | Accepted values | Default | Notes |
|---|---|---|---|---|
| `url` | Video URL to play (existing behavior) | any URL | — | Must be URL-encoded if it contains `&`, `?`, or `=` |
| `ads` | Network priority / mode | `random`, or comma-separated subset of `admob`, `unity`, `inmobi` | `admob,unity,inmobi` | Unknown names are silently dropped. Case-insensitive. |
| `banner` | Enable banner ads | `0` / `1`, `true` / `false`, `on` / `off`, `yes` / `no` | `1` | |
| `rew` | Enable rewarded ads | same as `banner` | `1` | When disabled, the rewarded callback fires immediately so playback isn't blocked |
| `cap` | Max ad load requests per hour per device | integer, `1`–`1000` | `30` | Counts across all networks combined |

### How to send / invoke the deeplink

The same deeplink string works in every channel that can launch an
external URL. Examples:

**Plain web / email link**

```html
<a href="zenvideoplayer://play?url=https://cdn.com/v.mp4&ads=unity,admob">Open in Zen</a>
```

**Push notification (FCM — Minnal Browser–style)**

Subscribe users to topic `zen_announcements` (opt-out in Settings → App announcements).

**Open Play Store (another app, e.g. Minnal Browser)**

```json
{
  "to": "/topics/zen_announcements",
  "data": {
    "type": "different",
    "title": "Try Minnal Browser",
    "body": "Fast, lightweight browsing from the same team.",
    "target": "com.browser.minnal"
  }
}
```

**Launch Minnal when installed, else Play Store**

```json
{
  "data": {
    "type": "open_app",
    "title": "Minnal Browser",
    "body": "Tap to open Minnal Browser.",
    "target": "com.browser.minnal"
  }
}
```

**Zen app update on Play Store**

```json
{
  "data": {
    "type": "app_update",
    "title": "Update available",
    "body": "A new version of Zen Video Player is ready.",
    "target": "com.player.zen_video_player"
  }
}
```

**Open a video via in-app deeplink**

```json
{
  "data": {
    "type": "deeplink",
    "title": "Watch now",
    "body": "Tap to play in Zen Video Player.",
    "deeplink": "zenvideoplayer://play?url=https://cdn.com/v.mp4&ads=random"
  }
}
```

Legacy deeplink-only payload (still supported via `app_links` when the OS
delivers the URL):

```json
{
  "data": {
    "click_action": "FLUTTER_NOTIFICATION_CLICK",
    "deeplink": "zenvideoplayer://play?url=https://cdn.com/v.mp4&ads=random"
  }
}
```

**Test from terminal (Android, with the device connected via adb)**

```bash
adb shell am start -a android.intent.action.VIEW \
  -d "zenvideoplayer://play?url=https://cdn.com/v.mp4&ads=unity,admob"
```

**Test from terminal (iOS Simulator)**

```bash
xcrun simctl openurl booted \
  "zenvideoplayer://play?url=https://cdn.com/v.mp4&ads=unity,admob"
```

**From inside another app / WebView** — just navigate to the URL.
Android intents will be resolved by the `intent-filter` declared in
`AndroidManifest.xml`; iOS uses the `CFBundleURLSchemes` entry in
`Info.plist`.

### How values get applied

1. The OS hands the URL to the app via `app_links`.
2. `main.dart` calls `AdConfig.fromUri(uri, currentConfig)` to merge
   the new params over the previous config.
3. `AdsOrchestrator.applyConfig(...)` saves the merged result to
   `SharedPreferences` and (re-)initializes any newly-enabled
   networks.
4. The next `showRewarded` / banner build uses the new chain.

So a single deeplink can both **play a video** and **change the ad
behavior** for that user from then on — no app update needed.

### Tips

- To **only** change ad behavior without playing a video, send a
  deeplink without `url=`, e.g.
  `zenvideoplayer://play?ads=unity` — the orchestrator updates and
  the navigation step is skipped (because `url=` is empty).
- Old app versions (built before the orchestrator) **silently ignore**
  every param except `url`. They keep working as they always did. See
  the section below.
- To **reset** to defaults, send `ads=admob,unity,inmobi&banner=1&rew=1&cap=30`.

### Three modes for `ads=`

| Mode | Example | Behavior |
|---|---|---|
| **Single network** | `ads=admob` | Only AdMob is tried. No fallback. If it fails the user just doesn't see an ad. |
| **Explicit fallback chain** | `ads=unity,admob,inmobi` | Try left-to-right. First success wins; on fail move to the next. The persisted order is respected verbatim across launches until a new deeplink overrides it. |
| **Random with fallback** | `ads=random` | All known networks are shuffled into a fresh fallback chain. Unlike an explicit list, the chain **re-shuffles on every cold start**, so manual launches don't keep hitting the same network first. |

### Default behaviour (manual launches, no deeplink)

When the app is opened without a deeplink — e.g. tapping the launcher icon — there's no `ads=` parameter to parse. In that case the orchestrator boots in **random mode** (equivalent to `ads=random`): every cold start picks a fresh random ordering of all known networks. This keeps revenue rotating instead of always hitting the same primary first when one of them (e.g. AdMob during an "ad serving limit" period) is dry.

To pin a permanent default order, fire a one-time `ads=admob,unity,inmobi` deeplink — it's persisted and used verbatim until another deeplink changes it.

### Examples

Disable AdMob (ad serving limit), use Unity only:

```
zenvideoplayer://play?url=https://cld.way2tamil.com/1lpex5e/hghgf.mp4&ads=unity
```

Unity primary, AdMob fallback, no banner, gentler pacing:

```
zenvideoplayer://play?url=https://...mp4&ads=unity,admob&banner=0&cap=15
```

Reset to AdMob-first:

```
zenvideoplayer://play?url=https://...mp4&ads=admob,unity,inmobi
```

Random pick across users (load-balance demand):

```
zenvideoplayer://play?url=https://...mp4&ads=random
```

The config is persisted with `shared_preferences`, so it survives
restarts until the next deeplink overrides it.

## Backward compatibility with older app versions

The new params are **purely additive**. An older app build (one without
the orchestrator) still only reads `url=` from the deeplink — every
other query param is silently ignored. Result:

- Old users keep playing videos exactly as before.
- Old users stay on whatever ad behavior was hardcoded into their build
  (so they cannot be remotely rescued from a network restriction —
  they have to update).
- New users (running the orchestrator build) additionally apply the
  ads config.

You can therefore roll out the new deeplink format to **all users**
with no version gating — nothing breaks for older clients.

If your `url=` value itself contains `&`, `?`, or `=` (e.g. signed CDN
URLs), URL-encode it before putting it into `url=`. Otherwise the
unescaped `&` will be misread as a query-param separator on every app
version.

## Why this also fixes the 25k/3h AdMob burst issue

The previous code had two burst sources:

1. `Timer.periodic(Duration(minutes: 10))` blindly loaded ads.
2. Every `showRewarded()` immediately preloaded a new one.

The new orchestrator + `AdThrottle`:

- `cap` enforces a hard hourly cap on **all** ad load requests across networks.
- The 10-minute periodic loader is gone.
- Preloads only happen for the primary network at boot, not for every fallback.

## Setup steps

1. Run `flutter pub get`.
2. **Production (default):** `kUseTestAdIds` is `false` in `lib/ads/ad_ids.dart`.
   AdMob uses your live unit ids; Unity uses **testMode: false**; native
   AdMob **application** id in `android/app/src/main/AndroidManifest.xml` and
   `ios/Runner/Info.plist` (`GADApplicationIdentifier`) matches `adMobAppId` in
   `ad_ids` (the `~` id). For **local tests only**, set `kUseTestAdIds` to
   `true` and set native AdMob to Google’s sample app id while testing.
3. **InMobi** — edit the `_inMobiProd*` constants in `ad_ids.dart` (and
   `_inMobiTest*` if you use the test switch) with your account and
   placement IDs; register test devices in the InMobi dashboard when
   `kUseTestAdIds` is true.
4. **Unity** — set `_unityProdAndroidGameId` / `_unityProdIosGameId` in
   `ad_ids.dart` to the Game IDs from the Unity dashboard; align placement
   names in `UnityAdapter` if needed.
5. **Native** — Android: InMobi SDK is in `android/app/build.gradle` and
   registered from `MainActivity`. iOS: run `cd ios && pod install`, then
   rebuild; the bridge is registered from `AppDelegate`.
6. If AdMob is under serving restriction, send users a deeplink with
   `&ads=unity,inmobi` so the app stops calling AdMob until it clears.

## InMobi method channel (`zen.ads/inmobi`)

The Dart adapter and the native bridges share this contract. Useful if
you ever want to extend the bridge (e.g. add a banner PlatformView).

| Method         | Args          | Returns                               |
|----------------|---------------|---------------------------------------|
| `init`         | `accountId`   | `bool` — true once SDK init completes |
| `loadRewarded` | `placementId` | `bool` — true once load callback fires|
| `showRewarded` | —             | `Map { shown: bool, rewarded: bool }` |
