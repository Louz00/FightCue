import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/runtime/app_diagnostics.dart';
import '../models/domain_models.dart';

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
