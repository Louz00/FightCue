import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/runtime/app_diagnostics.dart';
import '../models/domain_models.dart';
import 'firebase_runtime.dart';

class PushDeviceRegistrationResult {
  const PushDeviceRegistrationResult({
    required this.permissionStatus,
    required this.platform,
    this.tokenValue,
  });

  final PushPermissionStatus permissionStatus;
  final PushTokenPlatform platform;
  final String? tokenValue;

  bool get tokenRegistered => tokenValue != null && tokenValue!.isNotEmpty;
}

abstract class PushDeliveryService {
  Future<PushDeviceRegistrationResult> getStatus();
  Future<PushDeviceRegistrationResult> requestPermission();
}

class NativePushDeliveryService implements PushDeliveryService {
  NativePushDeliveryService({
    MethodChannel? channel,
  }) : _fallbackService = _MethodChannelPushDeliveryService(
         channel: channel,
       );

  final _MethodChannelPushDeliveryService _fallbackService;

  @override
  Future<PushDeviceRegistrationResult> getStatus() async {
    final firebaseStatus = await ensureFirebaseMessagingReady();
    if (!firebaseStatus.available || kIsWeb) {
      return _fallbackService.getStatus();
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();
      final tokenValue = await _resolveToken(messaging);
      return PushDeviceRegistrationResult(
        permissionStatus: _parseFirebasePermissionStatus(
          settings.authorizationStatus,
        ),
        platform: _fallbackPlatform(),
        tokenValue: tokenValue,
      );
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'push_delivery.firebase.status');
      return _fallbackService.getStatus();
    }
  }

  @override
  Future<PushDeviceRegistrationResult> requestPermission() async {
    final firebaseStatus = await ensureFirebaseMessagingReady();
    if (!firebaseStatus.available || kIsWeb) {
      return _fallbackService.requestPermission();
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      final tokenValue = await _resolveToken(messaging);
      return PushDeviceRegistrationResult(
        permissionStatus: _parseFirebasePermissionStatus(
          settings.authorizationStatus,
        ),
        platform: _fallbackPlatform(),
        tokenValue: tokenValue,
      );
    } catch (error, stackTrace) {
      logUiError(
        error,
        stackTrace,
        context: 'push_delivery.firebase.request_permission',
      );
      return _fallbackService.requestPermission();
    }
  }

  Future<String?> _resolveToken(FirebaseMessaging messaging) async {
    try {
      final firebaseToken = await messaging.getToken();
      if (firebaseToken != null && firebaseToken.isNotEmpty) {
        return firebaseToken;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await messaging.getAPNSToken();
        if (apnsToken == null || apnsToken.isEmpty) {
          debugPrint(
            '[FightCue][push_delivery.firebase.apns] APNs token missing after Firebase bootstrap.',
          );
        }
      }
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'push_delivery.firebase.token');
    }

    final fallbackStatus = await _fallbackService.getStatus();
    return fallbackStatus.tokenValue;
  }

  PushTokenPlatform _fallbackPlatform() {
    if (kIsWeb) {
      return PushTokenPlatform.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return PushTokenPlatform.ios;
      case TargetPlatform.android:
        return PushTokenPlatform.android;
      default:
        return PushTokenPlatform.web;
    }
  }
}

class _MethodChannelPushDeliveryService implements PushDeliveryService {
  _MethodChannelPushDeliveryService({
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'fightcue/push_setup';

  final MethodChannel _channel;

  @override
  Future<PushDeviceRegistrationResult> getStatus() async {
    return _invoke('getStatus');
  }

  @override
  Future<PushDeviceRegistrationResult> requestPermission() async {
    return _invoke('requestPermission');
  }

  Future<PushDeviceRegistrationResult> _invoke(String method) async {
    try {
      final payload =
          await _channel.invokeMapMethod<String, dynamic>(method) ?? const {};
      return PushDeviceRegistrationResult(
        permissionStatus: _parsePushPermissionStatus(
          payload['permissionStatus'] as String?,
        ),
        platform: _parsePushTokenPlatform(payload['platform'] as String?),
        tokenValue: payload['tokenValue'] as String?,
      );
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'push_delivery.$method');
      return PushDeviceRegistrationResult(
        permissionStatus: PushPermissionStatus.unknown,
        platform: _fallbackPlatform(),
      );
    }
  }

  PushTokenPlatform _fallbackPlatform() {
    if (kIsWeb) {
      return PushTokenPlatform.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return PushTokenPlatform.ios;
      case TargetPlatform.android:
        return PushTokenPlatform.android;
      default:
        return PushTokenPlatform.web;
    }
  }
}

PushPermissionStatus _parsePushPermissionStatus(String? rawStatus) {
  switch (rawStatus) {
    case 'prompt':
      return PushPermissionStatus.prompt;
    case 'granted':
      return PushPermissionStatus.granted;
    case 'denied':
      return PushPermissionStatus.denied;
    case 'unknown':
    default:
      return PushPermissionStatus.unknown;
  }
}

PushTokenPlatform _parsePushTokenPlatform(String? rawPlatform) {
  switch (rawPlatform) {
    case 'ios':
      return PushTokenPlatform.ios;
    case 'web':
      return PushTokenPlatform.web;
    case 'android':
    default:
      return PushTokenPlatform.android;
  }
}

PushPermissionStatus _parseFirebasePermissionStatus(
  AuthorizationStatus status,
) {
  switch (status) {
    case AuthorizationStatus.authorized:
    case AuthorizationStatus.provisional:
      return PushPermissionStatus.granted;
    case AuthorizationStatus.denied:
      return PushPermissionStatus.denied;
    case AuthorizationStatus.notDetermined:
      return PushPermissionStatus.prompt;
  }
}
