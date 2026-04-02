import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/data/ad_runtime.dart';

void main() {
  test('resolveAdRuntimeIdentifiers uses official Google test IDs for iOS debug runs', () {
    final identifiers = resolveAdRuntimeIdentifiers(
      platformOverride: TargetPlatform.iOS,
      releaseModeOverride: false,
      iosAppIdOverride: '',
      iosBannerUnitIdOverride: '',
    );

    expect(
      identifiers.appId,
      'ca-app-pub-3940256099942544~1458002511',
    );
    expect(
      identifiers.bannerUnitId,
      'ca-app-pub-3940256099942544/2435281174',
    );
    expect(identifiers.usingTestIdentifiers, isTrue);
  });

  test('resolveAdRuntimeIdentifiers uses official Google test IDs for Android debug runs', () {
    final identifiers = resolveAdRuntimeIdentifiers(
      platformOverride: TargetPlatform.android,
      releaseModeOverride: false,
      androidAppIdOverride: '',
      androidBannerUnitIdOverride: '',
    );

    expect(
      identifiers.appId,
      'ca-app-pub-3940256099942544~3347511713',
    );
    expect(
      identifiers.bannerUnitId,
      'ca-app-pub-3940256099942544/6300978111',
    );
    expect(identifiers.usingTestIdentifiers, isTrue);
  });

  test('resolveAdRuntimeIdentifiers stays unconfigured for release builds without real IDs', () {
    final identifiers = resolveAdRuntimeIdentifiers(
      platformOverride: TargetPlatform.iOS,
      releaseModeOverride: true,
      iosAppIdOverride: '',
      iosBannerUnitIdOverride: '',
    );

    expect(identifiers.appId, isNull);
    expect(identifiers.bannerUnitId, isNull);
    expect(identifiers.usingTestIdentifiers, isFalse);
  });

  test('resolveAdRuntimeIdentifiers prefers explicit production IDs when present', () {
    final identifiers = resolveAdRuntimeIdentifiers(
      platformOverride: TargetPlatform.android,
      releaseModeOverride: true,
      androidAppIdOverride: 'prod-app-id',
      androidBannerUnitIdOverride: 'prod-banner-id',
    );

    expect(identifiers.appId, 'prod-app-id');
    expect(identifiers.bannerUnitId, 'prod-banner-id');
    expect(identifiers.usingTestIdentifiers, isFalse);
  });
}
