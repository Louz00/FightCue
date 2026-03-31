import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentityStore {
  static const _deviceIdKey = 'fightcue_device_id';
  String? _cachedDeviceId;

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
    } catch (_) {
      final fallback = _generateDeviceId();
      _cachedDeviceId = fallback;
      return fallback;
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
