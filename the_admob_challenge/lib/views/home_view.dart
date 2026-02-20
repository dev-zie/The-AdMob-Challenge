import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:the_admob_challenge/views/premium_view.dart';
import 'package:the_admob_challenge/widgets/button_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late BannerAd bannerAd;
  bool isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    bannerAd = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/2934735716",
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();

    loadInterstitialAd();
    loadRewardedAd();

    Future.delayed(const Duration(seconds: 2), () {
      interstitialAd?.show();
    });
  }

  InterstitialAd? interstitialAd;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-3940256099942544/1033173712", // TEST ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  void onPremiumPressed() {
    if (rewardedAd == null) {
      return;
    }

    rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumView()),
        );
      },
    );
    rewardedAd = null;
  }

  RewardedAd? rewardedAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: "ca-app-pub-3940256099942544/5224354917",
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonWidget(
                text: 'Go Premium',
                onPressed: () => onPremiumPressed(),
              ),
              if (isAdLoaded)
                SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: bannerAd),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
