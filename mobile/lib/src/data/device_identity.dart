import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/runtime/app_diagnostics.dart';

class DeviceIdentityStore {
  static const _deviceIdKey = 'fightcue_device_id';
  static const _deviceTokenKey = 'fightcue_device_token';
  String? _cachedDeviceId;
  String? _cachedDeviceToken;

  Future<String> getOrCreateDeviceId() async {
    final cached = _cachedDeviceId;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final existing = preferences.getString(_deviceIdKey);
      if (existing != null && existing.isNotEmpty) {
        _cachedDeviceId = existing;
        return existing;
      }

      final created = _generateDeviceId();
      await preferences.setString(_deviceIdKey, created);
      _cachedDeviceId = created;
      return created;
    } catch (error, stackTrace) {
      final fallback = _generateDeviceId();
      logUiError(
        error,
        stackTrace,
        context: 'device_identity.device_id',
      );
      _cachedDeviceId = fallback;
      return fallback;
    }
  }

  Future<String?> getStoredDeviceToken() async {
    final cached = _cachedDeviceToken;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final existing = preferences.getString(_deviceTokenKey);
      if (existing != null && existing.isNotEmpty) {
        _cachedDeviceToken = existing;
        return existing;
      }
    } catch (error, stackTrace) {
      logUiError(
        error,
        stackTrace,
        context: 'device_identity.read_device_token',
      );
    }

    return null;
  }

  Future<void> saveDeviceToken(String token) async {
    _cachedDeviceToken = token;

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_deviceTokenKey, token);
    } catch (error, stackTrace) {
      logUiError(
        error,
        stackTrace,
        context: 'device_identity.save_device_token',
      );
    }
  }

  Future<void> clearDeviceToken() async {
    _cachedDeviceToken = null;

    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_deviceTokenKey);
    } catch (error, stackTrace) {
      logUiError(
        error,
        stackTrace,
        context: 'device_identity.clear_device_token',
      );
    }
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final buffer = StringBuffer('device_');
    buffer.write(DateTime.now().millisecondsSinceEpoch.toRadixString(36));
    buffer.write('_');

    for (var index = 0; index < 12; index += 1) {
      buffer.write(random.nextInt(36).toRadixString(36));
    }

    return buffer.toString();
  }
}
