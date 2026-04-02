import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/runtime/app_diagnostics.dart';

class AdRuntimeStatus {
  const AdRuntimeStatus({
    required this.sdkReady,
    required this.appIdConfigured,
    required this.bannerUnitId,
    required this.usingTestIdentifiers,
  });

  final bool sdkReady;
  final bool appIdConfigured;
  final String? bannerUnitId;
  final bool usingTestIdentifiers;

  bool get bannerReady => sdkReady && bannerUnitId != null && bannerUnitId!.isNotEmpty;
}

const _androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
const _androidTestBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
const _iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';
const _iosTestBannerUnitId = 'ca-app-pub-3940256099942544/2435281174';

class AdRuntimeIdentifiers {
  const AdRuntimeIdentifiers({
    required this.appId,
    required this.bannerUnitId,
    required this.usingTestIdentifiers,
  });

  final String? appId;
  final String? bannerUnitId;
  final bool usingTestIdentifiers;
}

Future<AdRuntimeStatus> ensureAdMobReady() async {
  if (kIsWeb) {
    return const AdRuntimeStatus(
      sdkReady: false,
      appIdConfigured: false,
      bannerUnitId: null,
      usingTestIdentifiers: false,
    );
  }

  final identifiers = resolveAdRuntimeIdentifiers();
  final appId = identifiers.appId;
  final bannerUnitId = identifiers.bannerUnitId;
  if (appId == null || appId.isEmpty) {
    return AdRuntimeStatus(
      sdkReady: false,
      appIdConfigured: false,
      bannerUnitId: bannerUnitId,
      usingTestIdentifiers: identifiers.usingTestIdentifiers,
    );
  }

  try {
    await MobileAds.instance.initialize();
    return AdRuntimeStatus(
      sdkReady: true,
      appIdConfigured: true,
      bannerUnitId: bannerUnitId,
      usingTestIdentifiers: identifiers.usingTestIdentifiers,
    );
  } catch (error, stackTrace) {
    logUiError(error, stackTrace, context: 'ad_runtime.initialize');
    return AdRuntimeStatus(
      sdkReady: false,
      appIdConfigured: true,
      bannerUnitId: bannerUnitId,
      usingTestIdentifiers: identifiers.usingTestIdentifiers,
    );
  }
}

AdRuntimeIdentifiers resolveAdRuntimeIdentifiers({
  TargetPlatform? platformOverride,
  bool? releaseModeOverride,
  String? androidAppIdOverride,
  String? iosAppIdOverride,
  String? androidBannerUnitIdOverride,
  String? iosBannerUnitIdOverride,
}) {
  final platform = platformOverride ?? defaultTargetPlatform;
  final isReleaseMode = releaseModeOverride ?? kReleaseMode;
  String? appId;
  String? bannerUnitId;
  if (platform == TargetPlatform.android) {
    final id =
        androidAppIdOverride ??
        const String.fromEnvironment('FIGHTCUE_ANDROID_ADMOB_APP_ID');
    if (id.isNotEmpty) {
      appId = id;
    } else {
      appId = isReleaseMode ? null : _androidTestAppId;
    }
    final bannerId =
        androidBannerUnitIdOverride ??
        const String.fromEnvironment('FIGHTCUE_ANDROID_BANNER_AD_UNIT_ID');
    if (bannerId.isNotEmpty) {
      bannerUnitId = bannerId;
    } else {
      bannerUnitId = isReleaseMode ? null : _androidTestBannerUnitId;
    }
  } else if (platform == TargetPlatform.iOS) {
    final id =
        iosAppIdOverride ??
        const String.fromEnvironment('FIGHTCUE_IOS_ADMOB_APP_ID');
    if (id.isNotEmpty) {
      appId = id;
    } else {
      appId = isReleaseMode ? null : _iosTestAppId;
    }
    final bannerId =
        iosBannerUnitIdOverride ??
        const String.fromEnvironment('FIGHTCUE_IOS_BANNER_AD_UNIT_ID');
    if (bannerId.isNotEmpty) {
      bannerUnitId = bannerId;
    } else {
      bannerUnitId = isReleaseMode ? null : _iosTestBannerUnitId;
    }
  }

  return AdRuntimeIdentifiers(
    appId: appId,
    bannerUnitId: bannerUnitId,
    usingTestIdentifiers:
        appId == _androidTestAppId ||
        appId == _iosTestAppId ||
        bannerUnitId == _androidTestBannerUnitId ||
        bannerUnitId == _iosTestBannerUnitId,
  );
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
