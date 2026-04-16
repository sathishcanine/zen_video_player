import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:applovin_max/applovin_max.dart';
import 'package:zen_video_player/video_player_screen.dart';
import 'download_service.dart';

class AdManager {

  static RewardedAd? admobRewarded;

  static const String admobRewardedId = "ca-app-pub-8723888126390754/7234751166";
  static const String applovinRewardedId = "APPLOVIN_REWARDED_ID";

  /// Initialize both networks
  static Future<void> initialize() async {

    await MobileAds.instance.initialize();

    // await AppLovinMAX.initialize("APPLOVIN_SDK_KEY");

    loadAdmobRewarded();

    // AppLovinMAX.loadRewardedAd(applovinRewardedId);
  }

  /// Load AdMob rewarded
  static void loadAdmobRewarded() {

    RewardedAd.load(
      adUnitId: admobRewardedId,
      request: const AdRequest(),

      rewardedAdLoadCallback: RewardedAdLoadCallback(

        onAdLoaded: (ad) {
          admobRewarded = ad;
        },

        onAdFailedToLoad: (error) {
          admobRewarded = null;
        },

      ),
    );
  }

  /// Show rewarded ad
  static void showRewarded(
      BuildContext context, {
        required String url,
        bool download = false,
        bool isLocal = false,
      }) {

    bool useAdmob = Random().nextBool();

    // if (useAdmob && admobRewarded != null) {
    if (admobRewarded != null) {

      admobRewarded!.show(

        onUserEarnedReward: (ad, reward) {

          startVideo(context, url, download, isLocal);

        },

      );

      admobRewarded = null;
      loadAdmobRewarded();

    } else {
      startVideo(context, url, download, isLocal);

      /// AppLovin MAX

      // final listener = RewardedAdListener(
      //   onAdLoadedCallback: (ad) {
      //     print('Rewarded ad loaded');
      //   },
      //   onAdLoadFailedCallback: (adUnitId, error) {
      //     print('Rewarded ad failed to load: $error');
      //   },
      //   onAdDisplayedCallback: (ad) {
      //     print('Rewarded ad displayed');
      //   },
      //   onAdDisplayFailedCallback: (ad, error) {
      //     print('Rewarded ad failed to display: $error');
      //   },
      //   onAdClickedCallback: (ad) {
      //     print('Rewarded ad clicked');
      //   },
      //   onAdHiddenCallback: (ad) {
      //     print('Rewarded ad hidden');
      //   },
      //   onAdReceivedRewardCallback: (ad, reward) {  // ✅ This is the correct name from the source code
      //     print('Reward received!');
      //     startVideo(context, url, download, isLocal);
      //   },
      // );
      //
      // // Set the listener
      // AppLovinMAX.setRewardedAdListener(listener);
      //
      // AppLovinMAX.showRewardedAd(applovinRewardedId);

    }
  }

  /// Start video or download
  static void startVideo(
      BuildContext context,
      String url,
      bool download,
      bool isLocal,
      ) {

    if (download) {

      DownloadService.downloadFile(url);

    } else {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            videoSource: url,
            isLocal: isLocal,
          ),
        ),
      );

    }

  }

}