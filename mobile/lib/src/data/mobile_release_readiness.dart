import 'package:flutter/foundation.dart';

import '../core/runtime/app_diagnostics.dart';
import 'ad_runtime.dart';
import 'crash_reporting.dart';
import 'firebase_runtime.dart';

class MobileReleaseReadinessStatus {
  const MobileReleaseReadinessStatus({
    required this.isReleaseMode,
    required this.issues,
  });

  final bool isReleaseMode;
  final List<String> issues;

  bool get fullyReady => issues.isEmpty;
}

MobileReleaseReadinessStatus evaluateMobileReleaseReadiness({
  required FirebaseMessagingBootstrapStatus firebaseStatus,
  required CrashReportingStatus crashReportingStatus,
  required AdRuntimeStatus adRuntimeStatus,
  bool? releaseModeOverride,
}) {
  final isReleaseMode = releaseModeOverride ?? kReleaseMode;
  if (!isReleaseMode) {
    return const MobileReleaseReadinessStatus(
      isReleaseMode: false,
      issues: <String>[],
    );
  }

  final issues = <String>[];
  if (!firebaseStatus.available) {
    issues.add(
      'Firebase Messaging is unavailable. Add the platform Firebase config files and verify the mobile Firebase project wiring before release.',
    );
  }
  if (!crashReportingStatus.available) {
    issues.add(
      'Crash reporting is unavailable. Validate Firebase Crashlytics in the release runtime before shipping.',
    );
  }
  if (!adRuntimeStatus.appIdConfigured) {
    issues.add(
      'AdMob app IDs are missing for this release runtime. Configure the production mobile ad identifiers before enabling live ads.',
    );
  } else if (!adRuntimeStatus.bannerReady) {
    issues.add(
      'AdMob initialized without a banner unit ready. Configure the production banner unit IDs before relying on quiet ad delivery.',
    );
  }
  if (adRuntimeStatus.usingTestIdentifiers) {
    issues.add(
      'Google test ad identifiers are still active in a release runtime. Replace them with production IDs before shipping.',
    );
  }

  return MobileReleaseReadinessStatus(
    isReleaseMode: true,
    issues: issues,
  );
}

void logMobileReleaseReadiness(MobileReleaseReadinessStatus status) {
  if (!status.isReleaseMode) {
    logUiNotice(
      'Skipping release-readiness enforcement for non-release runtime.',
      context: 'mobile_release_readiness',
    );
    return;
  }

  if (status.fullyReady) {
    logUiNotice(
      'Mobile provider configuration looks release-ready.',
      context: 'mobile_release_readiness',
    );
    return;
  }

  for (final issue in status.issues) {
    logUiNotice(
      issue,
      context: 'mobile_release_readiness',
    );
  }
}
