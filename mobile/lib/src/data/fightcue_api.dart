import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/runtime/app_diagnostics.dart';
import 'api_response_cache.dart';
import 'api_models.dart';
import 'device_identity.dart';
import 'fightcue_api_mappers.dart';
import '../models/domain_models.dart';

class ApiFetchResult<T> {
  const ApiFetchResult({
    required this.data,
    required this.isFromCache,
    this.lastSyncedAt,
  });

  final T data;
  final bool isFromCache;
  final DateTime? lastSyncedAt;

  static const Duration staleThreshold = Duration(minutes: 30);

  bool get isStaleCache {
    if (!isFromCache || lastSyncedAt == null) {
      return false;
    }

    return DateTime.now().toUtc().difference(lastSyncedAt!.toUtc()) >
        staleThreshold;
  }
}

String resolveFightCueApiBaseUrl({
  required bool isWeb,
  required TargetPlatform platform,
  String configuredBaseUrl = '',
}) {
  if (configuredBaseUrl.isNotEmpty) {
    return configuredBaseUrl;
  }

  if (isWeb) {
    return 'http://127.0.0.1:3000';
  }

  if (platform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }

  return 'http://127.0.0.1:3000';
}

class FightCueApi {
  FightCueApi({
    http.Client? client,
    DeviceIdentityStore? deviceIdentityStore,
    ApiResponseCacheStore? responseCacheStore,
    String? baseUrl,
    int maxReadRetries = 2,
    Duration retryBaseDelay = const Duration(milliseconds: 250),
  })  : _client = client ?? http.Client(),
        _deviceIdentityStore = deviceIdentityStore ?? DeviceIdentityStore(),
        _responseCacheStore = responseCacheStore ?? ApiResponseCacheStore(),
        _baseUrlOverride = baseUrl,
        _maxReadRetries = maxReadRetries,
        _retryBaseDelay = retryBaseDelay;

  final http.Client _client;
  final DeviceIdentityStore _deviceIdentityStore;
  final ApiResponseCacheStore _responseCacheStore;
  final String? _baseUrlOverride;
  final int _maxReadRetries;
  final Duration _retryBaseDelay;
  static const Duration _requestTimeout = Duration(seconds: 8);

  String get _baseUrl {
    final override = _baseUrlOverride;
    if (override != null && override.isNotEmpty) {
      return override;
    }

    const configuredBaseUrl = String.fromEnvironment('FIGHTCUE_API_BASE_URL');
    return resolveFightCueApiBaseUrl(
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
      configuredBaseUrl: configuredBaseUrl,
    );
  }

  Future<Map<String, String>> _defaultHeaders({
    Map<String, String>? extraHeaders,
  }) async {
    final deviceId = await _deviceIdentityStore.getOrCreateDeviceId();
    final deviceToken = await _resolveDeviceToken(deviceId);
    return {
      'x-fightcue-device-id': deviceId,
      if (deviceToken != null && deviceToken.isNotEmpty)
        'x-fightcue-device-token': deviceToken,
      ...?extraHeaders,
    };
  }

  Future<String?> _resolveDeviceToken(String deviceId) async {
    final cached = await _deviceIdentityStore.getStoredDeviceToken();
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final response = await _sendReadRequestWithRetry(
        () => _client
            .post(
              Uri.parse('$_baseUrl/v1/session/bootstrap'),
              headers: {
                'x-fightcue-device-id': deviceId,
              },
            )
            .timeout(_requestTimeout),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Session bootstrap failed: ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final token = json['deviceToken'] as String?;
      if (token == null || token.isEmpty) {
        throw const FormatException('Missing deviceToken in session bootstrap');
      }

      await _deviceIdentityStore.saveDeviceToken(token);
      return token;
    } catch (error, stackTrace) {
      logUiError(
        error,
        stackTrace,
        context: 'api.bootstrap_session',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>> _getJsonMap(
    String path, {
    bool allowCachedFallback = true,
  }) async {
    final result = await _getJsonMapResult(
      path,
      allowCachedFallback: allowCachedFallback,
    );
    return result.data;
  }

  Future<ApiFetchResult<Map<String, dynamic>>> _getJsonMapResult(
    String path, {
    bool allowCachedFallback = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    try {
      final headers = await _defaultHeaders();
      final response = await _sendReadRequestWithRetry(
        () => _client
            .get(
              uri,
              headers: headers,
            )
            .timeout(_requestTimeout),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('GET $path failed: ${response.statusCode}');
      }

      await _responseCacheStore.write(path, response.body);
      return ApiFetchResult(
        data: jsonDecode(response.body) as Map<String, dynamic>,
        isFromCache: false,
        lastSyncedAt: DateTime.now().toUtc(),
      );
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'api.get.$path');

      if (allowCachedFallback) {
        final cached = await _responseCacheStore.readEntry(path);
        if (cached != null && cached.body.isNotEmpty) {
          return ApiFetchResult(
            data: jsonDecode(cached.body) as Map<String, dynamic>,
            isFromCache: true,
            lastSyncedAt: cached.cachedAt,
          );
        }
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> _putJsonMap(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    try {
      final response = await _client
          .put(
            uri,
            headers: await _defaultHeaders(
              extraHeaders: {'content-type': 'application/json'},
            ),
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 401) {
        await _deviceIdentityStore.clearDeviceToken();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('PUT $path failed: ${response.statusCode}');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'api.put.$path');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _postJsonMap(
    String path, {
    Map<String, dynamic> body = const {},
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    try {
      final response = await _client
          .post(
            uri,
            headers: await _defaultHeaders(
              extraHeaders: {'content-type': 'application/json'},
            ),
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 401) {
        await _deviceIdentityStore.clearDeviceToken();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('POST $path failed: ${response.statusCode}');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'api.post.$path');
      rethrow;
    }
  }

  Future<HomeSnapshot> fetchHome() async {
    return (await fetchHomeResult()).data;
  }

  Future<ApiFetchResult<HomeSnapshot>> fetchHomeResult() async {
    final result = await _getJsonMapResult('/v1/home');
    return ApiFetchResult(
      data: mapHomeSnapshot(result.data),
      isFromCache: result.isFromCache,
      lastSyncedAt: result.lastSyncedAt,
    );
  }

  Future<EventDetailSnapshot> fetchEventDetail(String eventId) async {
    return (await fetchEventDetailResult(eventId)).data;
  }

  Future<ApiFetchResult<EventDetailSnapshot>> fetchEventDetailResult(
    String eventId,
  ) async {
    final result = await _getJsonMapResult('/v1/events/$eventId');
    return ApiFetchResult(
      data: mapEventDetailSnapshot(result.data),
      isFromCache: result.isFromCache,
      lastSyncedAt: result.lastSyncedAt,
    );
  }

  Future<FighterDetailSnapshot> fetchFighterDetail(String fighterId) async {
    return (await fetchFighterDetailResult(fighterId)).data;
  }

  Future<ApiFetchResult<FighterDetailSnapshot>> fetchFighterDetailResult(
    String fighterId,
  ) async {
    final result = await _getJsonMapResult('/v1/fighters/$fighterId');
    return ApiFetchResult(
      data: mapFighterDetailSnapshot(result.data),
      isFromCache: result.isFromCache,
      lastSyncedAt: result.lastSyncedAt,
    );
  }

  Future<AlertsSnapshot> fetchAlerts() async {
    return (await fetchAlertsResult()).data;
  }

  Future<ApiFetchResult<AlertsSnapshot>> fetchAlertsResult() async {
    final result = await _getJsonMapResult('/v1/me/alerts');
    return ApiFetchResult(
      data: mapAlertsSnapshot(result.data),
      isFromCache: result.isFromCache,
      lastSyncedAt: result.lastSyncedAt,
    );
  }

  Future<PushSettingsSnapshot> fetchPushSettings() async {
    return (await fetchPushSettingsResult()).data;
  }

  Future<ApiFetchResult<PushSettingsSnapshot>> fetchPushSettingsResult() async {
    final result = await _getJsonMapResult('/v1/me/push');
    return ApiFetchResult(
      data: mapPushSettingsSnapshot(result.data),
      isFromCache: result.isFromCache,
      lastSyncedAt: result.lastSyncedAt,
    );
  }

  Future<ApiFetchResult<PushPreviewSnapshot>> fetchPushPreviewResult() async {
    final result = await _getJsonMapResult('/v1/me/push/preview');
    return ApiFetchResult(
      data: mapPushPreviewSnapshot(result.data),
      isFromCache: result.isFromCache,
      lastSyncedAt: result.lastSyncedAt,
    );
  }

  Future<PushProviderStatusSnapshot> fetchPushProviderStatus() async {
    final json = await _getJsonMap('/v1/me/push/provider');
    return mapPushProviderStatusSnapshot(json);
  }

  Future<PushTestDispatchSnapshot> sendTestPush() async {
    final json = await _postJsonMap('/v1/me/push/test');
    return mapPushTestDispatchSnapshot(json);
  }

  Future<MonetizationSnapshot> fetchMonetization() async {
    return (await fetchMonetizationResult()).data;
  }

  Future<ApiFetchResult<MonetizationSnapshot>> fetchMonetizationResult() async {
    final result = await _getJsonMapResult('/v1/me/monetization');
    return ApiFetchResult(
      data: mapMonetizationSnapshot(result.data),
      isFromCache: result.isFromCache,
      lastSyncedAt: result.lastSyncedAt,
    );
  }

  Future<BillingProviderStatusSnapshot> fetchBillingProviderStatus() async {
    final json = await _getJsonMap('/v1/me/billing/provider');
    return mapBillingProviderStatusSnapshot(json);
  }

  Future<AdProviderStatusSnapshot> fetchAdProviderStatus() async {
    final json = await _getJsonMap('/v1/me/ads/provider');
    return mapAdProviderStatusSnapshot(json);
  }

  Future<MonetizationSnapshot> updateMonetizationSettings({
    bool? analyticsConsent,
    bool? adConsentGranted,
  }) async {
    final body = <String, dynamic>{};
    if (analyticsConsent != null) {
      body['analyticsConsent'] = analyticsConsent;
    }
    if (adConsentGranted != null) {
      body['adConsentGranted'] = adConsentGranted;
    }

    final json = await _putJsonMap(
      '/v1/me/monetization/settings',
      body: body,
    );
    return mapMonetizationSnapshot(json);
  }

  Future<PushSettingsSnapshot> updatePushSettings({
    bool? pushEnabled,
    PushPermissionStatus? permissionStatus,
  }) async {
    final json = await _putJsonMap(
      '/v1/me/push/settings',
      body: {
        if (pushEnabled != null) 'pushEnabled': pushEnabled,
        if (permissionStatus != null)
          'permissionStatus': _pushPermissionStatusToApi(permissionStatus),
      },
    );
    return mapPushSettingsSnapshot(json);
  }

  Future<PushSettingsSnapshot> registerPushToken({
    required PushPermissionStatus permissionStatus,
    PushTokenPlatform? tokenPlatform,
    String? tokenValue,
  }) async {
    final json = await _putJsonMap(
      '/v1/me/push/token',
      body: {
        'permissionStatus': _pushPermissionStatusToApi(permissionStatus),
        if (tokenPlatform != null) 'tokenPlatform': _pushTokenPlatformToApi(tokenPlatform),
        if (tokenValue != null && tokenValue.isNotEmpty) 'tokenValue': tokenValue,
      },
    );
    return mapPushSettingsSnapshot(json);
  }

  Future<UfcSourcePreview> fetchUfcEventsPreview({
    String timezone = 'Europe/Amsterdam',
    String countryCode = 'NL',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/v1/sources/ufc/events?timezone=$timezone&country=$countryCode',
    );
    final json = await _getJsonMap(uri.path + (uri.hasQuery ? '?${uri.query}' : ''));
    return mapUfcSourcePreview(json);
  }

  Future<List<LeaderboardSummary>> fetchLeaderboards() async {
    return (await fetchLeaderboardsResult()).data;
  }

  Future<ApiFetchResult<List<LeaderboardSummary>>> fetchLeaderboardsResult() async {
    final result = await _getJsonMapResult('/v1/leaderboards');
    return ApiFetchResult(
      data: mapLeaderboardSummaries(result.data),
      isFromCache: result.isFromCache,
      lastSyncedAt: result.lastSyncedAt,
    );
  }

  Future<HomeSnapshot> updatePreferences({
    String? languageCode,
    String? timezone,
    String? viewingCountryCode,
  }) async {
    final body = <String, dynamic>{};
    if (languageCode != null) {
      body['language'] = languageCode;
    }
    if (timezone != null) {
      body['timezone'] = timezone;
    }
    if (viewingCountryCode != null) {
      body['viewingCountryCode'] = viewingCountryCode;
    }

    await _putJsonMap('/v1/me/preferences', body: body);

    return fetchHome();
  }

  Future<EventSummary> setEventFollow(String eventId, bool followed) async {
    final json = await _putJsonMap(
      '/v1/me/follows/events/$eventId',
      body: {'followed': followed},
    );
    return mapEventSummaryItem(json['item'] as Map<String, dynamic>);
  }

  Future<FighterSummary> setFighterFollow(String fighterId, bool followed) async {
    final json = await _putJsonMap(
      '/v1/me/follows/fighters/$fighterId',
      body: {'followed': followed},
    );
    return mapFighterSummaryItem(json['item'] as Map<String, dynamic>);
  }

  Future<AlertsSnapshot> updateFighterAlerts(
    String fighterId,
    Set<AlertPreset> presets,
  ) async {
    final json = await _putJsonMap(
      '/v1/me/alerts/fighters/$fighterId',
      body: {
        'presetKeys': presets.map(alertPresetToApi).toList(),
      },
    );
    return mapAlertsSnapshot(json);
  }

  Future<AlertsSnapshot> updateEventAlerts(
    String eventId,
    Set<AlertPreset> presets,
  ) async {
    final json = await _putJsonMap(
      '/v1/me/alerts/events/$eventId',
      body: {
        'presetKeys': presets.map(alertPresetToApi).toList(),
      },
    );
    return mapAlertsSnapshot(json);
  }

  String calendarUrlForEvent(String eventId, {String? calendarExportPath}) {
    final path = calendarExportPath ?? '/v1/events/$eventId/calendar.ics';
    return '$_baseUrl$path';
  }

  Future<void> prefetchReadSurfaces(HomeSnapshot snapshot) async {
    final eventIds = snapshot.events.take(3).map((event) => event.id);
    final fighterIds = snapshot.followedFighters.take(3).map((fighter) => fighter.id);

    final tasks = <Future<void>>[
      _prefetchPath('/v1/leaderboards'),
      _prefetchPath('/v1/me/alerts'),
      _prefetchPath('/v1/me/monetization'),
      _prefetchPath('/v1/me/push'),
      for (final eventId in eventIds) _prefetchPath('/v1/events/$eventId'),
      for (final fighterId in fighterIds) _prefetchPath('/v1/fighters/$fighterId'),
    ];

    await Future.wait(tasks, eagerError: false);
  }

  Future<void> _prefetchPath(String path) async {
    try {
      await _getJsonMapResult(path, allowCachedFallback: false);
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'api.prefetch.$path');
    }
  }

  Future<http.Response> _sendReadRequestWithRetry(
    Future<http.Response> Function() send,
  ) async {
    Object? lastError;

    for (var attempt = 0; attempt <= _maxReadRetries; attempt += 1) {
      try {
        final response = await send();
        if (_shouldRetryStatusCode(response.statusCode) &&
            attempt < _maxReadRetries) {
          await Future<void>.delayed(_delayForRetry(attempt));
          continue;
        }
        return response;
      } catch (error) {
        lastError = error;
        if (!_shouldRetryError(error) || attempt >= _maxReadRetries) {
          rethrow;
        }
        await Future<void>.delayed(_delayForRetry(attempt));
      }
    }

    throw lastError ?? StateError('Read request failed without a response');
  }

  Duration _delayForRetry(int attempt) {
    final multiplier = 1 << attempt;
    return Duration(
      microseconds: _retryBaseDelay.inMicroseconds * multiplier,
    );
  }
}

bool _shouldRetryStatusCode(int statusCode) {
  return statusCode == 408 || statusCode == 425 || statusCode == 429 || statusCode >= 500;
}

bool _shouldRetryError(Object error) {
  return error is TimeoutException || error is http.ClientException;
}

String _pushPermissionStatusToApi(PushPermissionStatus status) {
  switch (status) {
    case PushPermissionStatus.prompt:
      return 'prompt';
    case PushPermissionStatus.granted:
      return 'granted';
    case PushPermissionStatus.denied:
      return 'denied';
    case PushPermissionStatus.unknown:
      return 'unknown';
  }
}

String _pushTokenPlatformToApi(PushTokenPlatform platform) {
  switch (platform) {
    case PushTokenPlatform.android:
      return 'android';
    case PushTokenPlatform.ios:
      return 'ios';
    case PushTokenPlatform.web:
      return 'web';
  }
}
