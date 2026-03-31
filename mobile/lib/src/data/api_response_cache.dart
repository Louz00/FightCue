import 'package:shared_preferences/shared_preferences.dart';

class ApiResponseCacheStore {
  static const _cachePrefix = 'fightcue_api_cache_';

  Future<void> write(String key, String body) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('$_cachePrefix$key', body);
  }

  Future<String?> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('$_cachePrefix$key');
  }
}

