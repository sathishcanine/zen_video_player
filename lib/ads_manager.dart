
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';

class AdsManager {

  static InterstitialAd? admobAd;

  static Future<void> init() async {
    await MobileAds.instance.initialize();
  }

  static void showStartAd() async {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-4789468551786381/4193593813",
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          admobAd = ad;
          ad.show();
        },
        onAdFailedToLoad: (error) {
          // AppLovinMAX.showInterstitial("APPLOVIN_INTERSTITIAL_ID");
        },
      ),
    );
  }

  static void scheduleAds(){
    Timer.periodic(const Duration(minutes:10), (timer){
      showStartAd();
    });
  }
}

class BannerAdWidget extends StatefulWidget {
  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? banner;

  @override
  void initState() {
    super.initState();

    banner = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-8723888126390754/7532332319",
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          AppLovinMAX.showMediationDebugger();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (banner == null) return const SizedBox();
    return SizedBox(
      width: banner!.size.width.toDouble(),
      height: banner!.size.height.toDouble(),
      child: AdWidget(ad: banner!),
    );
  }
}
