import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/runtime/app_diagnostics.dart';

class AdRuntimeStatus {
  const AdRuntimeStatus({
    required this.sdkReady,
    required this.bannerUnitId,
  });

  final bool sdkReady;
  final String? bannerUnitId;

  bool get bannerReady => sdkReady && bannerUnitId != null && bannerUnitId!.isNotEmpty;
}

Future<AdRuntimeStatus> ensureAdMobReady() async {
  if (kIsWeb) {
    return const AdRuntimeStatus(sdkReady: false, bannerUnitId: null);
  }

  try {
    await MobileAds.instance.initialize();
    return AdRuntimeStatus(
      sdkReady: true,
      bannerUnitId: _resolveBannerUnitId(),
    );
  } catch (error, stackTrace) {
    logUiError(error, stackTrace, context: 'ad_runtime.initialize');
    return AdRuntimeStatus(
      sdkReady: false,
      bannerUnitId: _resolveBannerUnitId(),
    );
  }
}

String? _resolveBannerUnitId() {
  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.android) {
    const id = String.fromEnvironment('FIGHTCUE_ANDROID_BANNER_AD_UNIT_ID');
    return id.isEmpty ? null : id;
  }
  if (platform == TargetPlatform.iOS) {
    const id = String.fromEnvironment('FIGHTCUE_IOS_BANNER_AD_UNIT_ID');
    return id.isEmpty ? null : id;
  }
  return null;
}

class FightCueBannerAdController {
  BannerAd? _bannerAd;

  BannerAd? get bannerAd => _bannerAd;

  Future<BannerAd?> loadBannerAd() async {
    final status = await ensureAdMobReady();
    final unitId = status.bannerUnitId;
    if (!status.sdkReady || unitId == null || unitId.isEmpty) {
      return null;
    }

    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: unitId,
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          logUiError(
            PlatformException(
              code: 'ad_load_failed',
              message: error.message,
            ),
            StackTrace.current,
            context: 'ad_runtime.banner_load',
          );
        },
      ),
      request: const AdRequest(),
    );

    await banner.load();
    _bannerAd = banner;
    return banner;
  }

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}
