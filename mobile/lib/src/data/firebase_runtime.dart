import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../core/runtime/app_diagnostics.dart';

class FirebaseMessagingBootstrapStatus {
  const FirebaseMessagingBootstrapStatus({
    required this.available,
    this.reason,
  });

  final bool available;
  final String? reason;
}

FirebaseMessagingBootstrapStatus? _cachedBootstrapStatus;
bool _backgroundHandlerRegistered = false;

Future<FirebaseMessagingBootstrapStatus> ensureFirebaseMessagingReady() async {
  if (_cachedBootstrapStatus?.available == true) {
    return _cachedBootstrapStatus!;
  }

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }

    if (!kIsWeb && !_backgroundHandlerRegistered) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _backgroundHandlerRegistered = true;
    }

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    final status = const FirebaseMessagingBootstrapStatus(available: true);
    _cachedBootstrapStatus = status;
    return status;
  } catch (error, stackTrace) {
    logUiError(error, stackTrace, context: 'firebase_messaging.bootstrap');
    final status = FirebaseMessagingBootstrapStatus(
      available: false,
      reason: error.toString(),
    );
    _cachedBootstrapStatus = status;
    return status;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (error, stackTrace) {
    logUiError(
      error,
      stackTrace,
      context: 'firebase_messaging.background_handler',
    );
  }
}
