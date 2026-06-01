import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  static InterstitialAd? _ad;
  static int _navCount = 0;
  static const int _showEvery = 3;

  static const String _adUnitId = 'ca-app-pub-7364238257602037/3730346695';

  static void preload() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _ad = ad,
        onAdFailedToLoad: (error) {
          debugPrint('[InterstitialAd] failed to load: ${error.message}');
          _ad = null;
        },
      ),
    );
  }

  static void showIfReady() {
    _navCount++;
    if (_navCount % _showEvery != 0) return;
    if (_ad == null) {
      preload();
      return;
    }
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
      },
    );
    _ad!.show();
    _ad = null;
  }
}
