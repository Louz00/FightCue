import 'package:shared_preferences/shared_preferences.dart';

class CachedApiResponse {
  const CachedApiResponse({
    required this.body,
    required this.cachedAt,
  });

  final String body;
  final DateTime? cachedAt;
}

class ApiResponseCacheStore {
  static const _cachePrefix = 'fightcue_api_cache_';
  static const _cacheTimestampPrefix = 'fightcue_api_cache_ts_';

  Future<void> write(String key, String body) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('$_cachePrefix$key', body);
    await preferences.setString(
      '$_cacheTimestampPrefix$key',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<String?> read(String key) async {
    final entry = await readEntry(key);
    return entry?.body;
  }

  Future<CachedApiResponse?> readEntry(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final body = preferences.getString('$_cachePrefix$key');
    if (body == null) {
      return null;
    }

    final rawTimestamp = preferences.getString('$_cacheTimestampPrefix$key');
    return CachedApiResponse(
      body: body,
      cachedAt: rawTimestamp == null ? null : DateTime.tryParse(rawTimestamp),
    );
  }
}
