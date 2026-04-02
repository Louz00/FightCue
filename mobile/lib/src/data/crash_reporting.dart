import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../core/runtime/app_diagnostics.dart';

class CrashReportingStatus {
  const CrashReportingStatus({
    required this.available,
    required this.providerLabel,
    this.reason,
  });

  final bool available;
  final String providerLabel;
  final String? reason;
}

CrashReportingStatus? _cachedCrashReportingStatus;
bool _crashReporterRegistered = false;

Future<CrashReportingStatus> ensureCrashReportingReady() async {
  if (_cachedCrashReportingStatus != null) {
    return _cachedCrashReportingStatus!;
  }

  if (kIsWeb) {
    const status = CrashReportingStatus(
      available: false,
      providerLabel: 'disabled',
      reason: 'Crash reporting is not wired for web builds.',
    );
    _cachedCrashReportingStatus = status;
    return status;
  }

  if (Firebase.apps.isEmpty) {
    const status = CrashReportingStatus(
      available: false,
      providerLabel: 'disabled',
      reason: 'Firebase is not initialized for this runtime.',
    );
    _cachedCrashReportingStatus = status;
    return status;
  }

  try {
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(kReleaseMode);

    if (!_crashReporterRegistered) {
      registerUiErrorReporter((error, stackTrace, {required context}) {
        return crashlytics.recordError(
          error,
          stackTrace,
          reason: context,
          fatal: false,
          printDetails: false,
        );
      });
      _crashReporterRegistered = true;
    }

    const status = CrashReportingStatus(
      available: true,
      providerLabel: 'firebase_crashlytics',
    );
    _cachedCrashReportingStatus = status;
    return status;
  } catch (error, stackTrace) {
    logUiError(error, stackTrace, context: 'crash_reporting.initialize');
    final status = CrashReportingStatus(
      available: false,
      providerLabel: 'disabled',
      reason: error.toString(),
    );
    _cachedCrashReportingStatus = status;
    return status;
  }
}
