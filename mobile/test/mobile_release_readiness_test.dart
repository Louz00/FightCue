import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/data/ad_runtime.dart';
import 'package:fightcue_mobile/src/data/crash_reporting.dart';
import 'package:fightcue_mobile/src/data/firebase_runtime.dart';
import 'package:fightcue_mobile/src/data/mobile_release_readiness.dart';

void main() {
  test('non-release runtime skips provider readiness enforcement', () {
    final status = evaluateMobileReleaseReadiness(
      firebaseStatus: const FirebaseMessagingBootstrapStatus(available: false),
      crashReportingStatus: const CrashReportingStatus(
        available: false,
        providerLabel: 'disabled',
      ),
      adRuntimeStatus: const AdRuntimeStatus(
        sdkReady: false,
        appIdConfigured: false,
        bannerUnitId: null,
        usingTestIdentifiers: false,
      ),
      releaseModeOverride: false,
    );

    expect(status.isReleaseMode, isFalse);
    expect(status.fullyReady, isTrue);
    expect(status.issues, isEmpty);
  });

  test('release runtime reports missing provider config', () {
    final status = evaluateMobileReleaseReadiness(
      firebaseStatus: const FirebaseMessagingBootstrapStatus(available: false),
      crashReportingStatus: const CrashReportingStatus(
        available: false,
        providerLabel: 'disabled',
      ),
      adRuntimeStatus: const AdRuntimeStatus(
        sdkReady: false,
        appIdConfigured: false,
        bannerUnitId: null,
        usingTestIdentifiers: false,
      ),
      releaseModeOverride: true,
    );

    expect(status.fullyReady, isFalse);
    expect(status.issues.length, 3);
    expect(status.issues.first, contains('Firebase Messaging is unavailable'));
  });

  test('release runtime flags test ad identifiers', () {
    final status = evaluateMobileReleaseReadiness(
      firebaseStatus: const FirebaseMessagingBootstrapStatus(available: true),
      crashReportingStatus: const CrashReportingStatus(
        available: true,
        providerLabel: 'firebase_crashlytics',
      ),
      adRuntimeStatus: const AdRuntimeStatus(
        sdkReady: true,
        appIdConfigured: true,
        bannerUnitId: 'test-banner',
        usingTestIdentifiers: true,
      ),
      releaseModeOverride: true,
    );

    expect(status.fullyReady, isFalse);
    expect(
      status.issues.any((issue) => issue.contains('Google test ad identifiers')),
      isTrue,
    );
  });

  test('release runtime passes when provider configuration is complete', () {
    final status = evaluateMobileReleaseReadiness(
      firebaseStatus: const FirebaseMessagingBootstrapStatus(available: true),
      crashReportingStatus: const CrashReportingStatus(
        available: true,
        providerLabel: 'firebase_crashlytics',
      ),
      adRuntimeStatus: const AdRuntimeStatus(
        sdkReady: true,
        appIdConfigured: true,
        bannerUnitId: 'prod-banner',
        usingTestIdentifiers: false,
      ),
      releaseModeOverride: true,
    );

    expect(status.fullyReady, isTrue);
    expect(status.issues, isEmpty);
  });
}
