import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/runtime/app_diagnostics.dart';
import 'api_response_cache.dart';
import 'device_identity.dart';
import '../models/domain_models.dart';

class FightCueApi {
  FightCueApi({
    http.Client? client,
    DeviceIdentityStore? deviceIdentityStore,
    ApiResponseCacheStore? responseCacheStore,
  })  : _client = client ?? http.Client(),
        _deviceIdentityStore = deviceIdentityStore ?? DeviceIdentityStore(),
        _responseCacheStore = responseCacheStore ?? ApiResponseCacheStore();

  final http.Client _client;
  final DeviceIdentityStore _deviceIdentityStore;
  final ApiResponseCacheStore _responseCacheStore;
  static const Duration _requestTimeout = Duration(seconds: 8);

  String get _baseUrl {
    const configuredBaseUrl = String.fromEnvironment('FIGHTCUE_API_BASE_URL');
    if (configuredBaseUrl.isNotEmpty) {
      return configuredBaseUrl;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:3000';
    }

    return 'http://127.0.0.1:3000';
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
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/v1/session/bootstrap'),
            headers: {
              'x-fightcue-device-id': deviceId,
            },
          )
          .timeout(_requestTimeout);

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
    final uri = Uri.parse('$_baseUrl$path');

    try {
      final response = await _client
          .get(
            uri,
            headers: await _defaultHeaders(),
          )
          .timeout(_requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('GET $path failed: ${response.statusCode}');
      }

      await _responseCacheStore.write(path, response.body);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'api.get.$path');

      if (allowCachedFallback) {
        final cached = await _responseCacheStore.read(path);
        if (cached != null && cached.isNotEmpty) {
          return jsonDecode(cached) as Map<String, dynamic>;
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

  Future<HomeSnapshot> fetchHome() async {
    final json = await _getJsonMap('/v1/home');
    return HomeSnapshotJson.fromJson(json).toMobile();
  }

  Future<EventDetailSnapshot> fetchEventDetail(String eventId) async {
    final json = await _getJsonMap('/v1/events/$eventId');
    return EventDetailSnapshotJson.fromJson(json).toMobile();
  }

  Future<FighterDetailSnapshot> fetchFighterDetail(String fighterId) async {
    final json = await _getJsonMap('/v1/fighters/$fighterId');
    return FighterDetailSnapshotJson.fromJson(json).toMobile();
  }

  Future<AlertsSnapshot> fetchAlerts() async {
    final json = await _getJsonMap('/v1/me/alerts');
    return AlertsSnapshotJson.fromJson(json).toMobile();
  }

  Future<UfcSourcePreview> fetchUfcEventsPreview({
    String timezone = 'Europe/Amsterdam',
    String countryCode = 'NL',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/v1/sources/ufc/events?timezone=$timezone&country=$countryCode',
    );
    final json = await _getJsonMap(uri.path + (uri.hasQuery ? '?${uri.query}' : ''));
    final items = (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(EventSummaryJson.fromJson)
        .map((entry) => entry.toMobile())
        .toList();

    return UfcSourcePreview(
      mode: json['mode'] as String? ?? 'fallback',
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      items: items,
    );
  }

  Future<List<LeaderboardSummary>> fetchLeaderboards() async {
    final json = await _getJsonMap('/v1/leaderboards');
    return (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LeaderboardSummaryJson.fromJson)
        .map((entry) => entry.toMobile())
        .toList();
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
    return EventSummaryJson.fromJson(json['item'] as Map<String, dynamic>).toMobile();
  }

  Future<FighterSummary> setFighterFollow(String fighterId, bool followed) async {
    final json = await _putJsonMap(
      '/v1/me/follows/fighters/$fighterId',
      body: {'followed': followed},
    );
    return FighterSummaryJson.fromJson(json['item'] as Map<String, dynamic>).toMobile();
  }

  Future<AlertsSnapshot> updateFighterAlerts(
    String fighterId,
    Set<AlertPreset> presets,
  ) async {
    final json = await _putJsonMap(
      '/v1/me/alerts/fighters/$fighterId',
      body: {
        'presetKeys': presets.map(_alertPresetToApi).toList(),
      },
    );
    return AlertsSnapshotJson.fromJson(json).toMobile();
  }

  Future<AlertsSnapshot> updateEventAlerts(
    String eventId,
    Set<AlertPreset> presets,
  ) async {
    final json = await _putJsonMap(
      '/v1/me/alerts/events/$eventId',
      body: {
        'presetKeys': presets.map(_alertPresetToApi).toList(),
      },
    );
    return AlertsSnapshotJson.fromJson(json).toMobile();
  }

  String calendarUrlForEvent(String eventId, {String? calendarExportPath}) {
    final path = calendarExportPath ?? '/v1/events/$eventId/calendar.ics';
    return '$_baseUrl$path';
  }
}

class EventDetailSnapshotJson {
  const EventDetailSnapshotJson({
    required this.event,
    required this.calendarExportPath,
  });

  final EventSummary event;
  final String calendarExportPath;

  factory EventDetailSnapshotJson.fromJson(Map<String, dynamic> json) {
    return EventDetailSnapshotJson(
      event: EventSummaryJson.fromJson(
        json['item'] as Map<String, dynamic>? ?? const {},
      ).toMobile(),
      calendarExportPath:
          json['calendarExportPath'] as String? ?? '/v1/events/unknown/calendar.ics',
    );
  }

  EventDetailSnapshot toMobile() {
    return EventDetailSnapshot(
      event: event,
      calendarExportPath: calendarExportPath,
    );
  }
}

class FighterDetailSnapshotJson {
  const FighterDetailSnapshotJson({
    required this.fighter,
    required this.relatedEvents,
  });

  final FighterSummary fighter;
  final List<EventSummary> relatedEvents;

  factory FighterDetailSnapshotJson.fromJson(Map<String, dynamic> json) {
    return FighterDetailSnapshotJson(
      fighter: FighterSummaryJson.fromJson(
        json['item'] as Map<String, dynamic>? ?? const {},
      ).toMobile(),
      relatedEvents: (json['relatedEvents'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EventSummaryJson.fromJson)
          .map((entry) => entry.toMobile())
          .toList(),
    );
  }

  FighterDetailSnapshot toMobile() {
    return FighterDetailSnapshot(
      fighter: fighter,
      relatedEvents: relatedEvents,
    );
  }
}

class AlertsSnapshotJson {
  const AlertsSnapshotJson({
    required this.fighterPresetsById,
    required this.eventPresetsById,
  });

  final Map<String, Set<AlertPreset>> fighterPresetsById;
  final Map<String, Set<AlertPreset>> eventPresetsById;

  factory AlertsSnapshotJson.fromJson(Map<String, dynamic> json) {
    Map<String, Set<AlertPreset>> parseTargetPresets(String key) {
      final items = (json[key] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>();

      return {
        for (final item in items)
          (item['targetId'] as String? ?? ''): ((item['presetKeys'] as List<dynamic>? ?? const [])
              .map((value) => _parseAlertPreset(value as String?))
              .toSet()),
      };
    }

    return AlertsSnapshotJson(
      fighterPresetsById: parseTargetPresets('fighters'),
      eventPresetsById: parseTargetPresets('events'),
    );
  }

  AlertsSnapshot toMobile() {
    return AlertsSnapshot(
      fighterPresetsById: fighterPresetsById,
      eventPresetsById: eventPresetsById,
    );
  }
}

class HomeSnapshotJson {
  const HomeSnapshotJson({
    required this.languageCode,
    required this.timezone,
    required this.viewingCountryCode,
    required this.premiumState,
    required this.accountModeLabel,
    required this.fighters,
    required this.events,
  });

  final String languageCode;
  final String timezone;
  final String viewingCountryCode;
  final PremiumState premiumState;
  final String accountModeLabel;
  final List<FighterSummary> fighters;
  final List<EventSummary> events;

  factory HomeSnapshotJson.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>? ?? const {};

    return HomeSnapshotJson(
      languageCode: profile['language'] as String? ?? 'en',
      timezone: profile['timezone'] as String? ?? 'Europe/Amsterdam',
      viewingCountryCode: profile['viewingCountryCode'] as String? ?? 'NL',
      premiumState: _parsePremiumState(profile['premiumState'] as String?),
      accountModeLabel:
          profile['isAnonymous'] as bool? ?? true
              ? 'Anonymous by default, email login optional'
              : 'Email account active',
      fighters: (json['fighters'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(FighterSummaryJson.fromJson)
          .map((entry) => entry.toMobile())
          .toList(),
      events: (json['events'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EventSummaryJson.fromJson)
          .map((entry) => entry.toMobile())
          .toList(),
    );
  }

  HomeSnapshot toMobile() {
    return HomeSnapshot(
      fighters: fighters,
      events: events,
      premiumState: premiumState,
      accountModeLabel: accountModeLabel,
      languageCode: languageCode,
      timezone: timezone,
      viewingCountryCode: viewingCountryCode,
    );
  }
}

class FighterSummaryJson {
  const FighterSummaryJson({
    required this.id,
    required this.name,
    required this.sport,
    required this.organizationHint,
    required this.recordLabel,
    required this.nationalityLabel,
    required this.headline,
    required this.nextAppearanceLabel,
    required this.isFollowed,
    this.nickname,
  });

  final String id;
  final String name;
  final Sport sport;
  final String organizationHint;
  final String recordLabel;
  final String nationalityLabel;
  final String headline;
  final String nextAppearanceLabel;
  final String? nickname;
  final bool isFollowed;

  factory FighterSummaryJson.fromJson(Map<String, dynamic> json) {
    final organizationHints = (json['organizationHints'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList();

    return FighterSummaryJson(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sport: _parseSport(json['sport'] as String?),
      organizationHint: _organizationLabelFromHints(organizationHints),
      recordLabel: json['recordLabel'] as String? ?? 'Record pending',
      nationalityLabel: json['nationalityLabel'] as String? ?? 'TBD',
      headline: json['headline'] as String? ?? '',
      nextAppearanceLabel: json['nextAppearanceLabel'] as String? ?? '',
      nickname: json['nickname'] as String?,
      isFollowed: json['isFollowed'] as bool? ?? false,
    );
  }

  FighterSummary toMobile() {
    return FighterSummary(
      id: id,
      name: name,
      sport: sport,
      organizationHint: organizationHint,
      recordLabel: recordLabel,
      nationalityLabel: nationalityLabel,
      headline: headline,
      nextAppearanceLabel: nextAppearanceLabel,
      nickname: nickname,
      isFollowed: isFollowed,
    );
  }
}

class UfcSourcePreview {
  const UfcSourcePreview({
    required this.mode,
    required this.warnings,
    required this.items,
  });

  final String mode;
  final List<String> warnings;
  final List<EventSummary> items;
}

class EventSummaryJson {
  const EventSummaryJson({
    required this.id,
    required this.organizationName,
    required this.sport,
    required this.title,
    required this.tagline,
    required this.locationLabel,
    required this.venueLabel,
    required this.localDateLabel,
    required this.localTimeLabel,
    required this.eventLocalTimeLabel,
    required this.selectedCountryCode,
    required this.sourceLabel,
    required this.isFollowed,
    required this.watchProviders,
    required this.bouts,
  });

  final String id;
  final String organizationName;
  final Sport sport;
  final String title;
  final String tagline;
  final String locationLabel;
  final String venueLabel;
  final String localDateLabel;
  final String localTimeLabel;
  final String eventLocalTimeLabel;
  final String selectedCountryCode;
  final String sourceLabel;
  final bool isFollowed;
  final List<WatchProviderSummary> watchProviders;
  final List<BoutSummary> bouts;

  factory EventSummaryJson.fromJson(Map<String, dynamic> json) {
    return EventSummaryJson(
      id: json['id'] as String? ?? '',
      organizationName: json['organizationName'] as String? ?? 'UFC',
      sport: _parseSport(json['sport'] as String?),
      title: json['title'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      venueLabel: json['venueLabel'] as String? ?? '',
      localDateLabel: json['localDateLabel'] as String? ?? '',
      localTimeLabel: json['localTimeLabel'] as String? ?? '',
      eventLocalTimeLabel: json['eventLocalTimeLabel'] as String? ?? '',
      selectedCountryCode: json['selectedCountryCode'] as String? ?? 'NL',
      sourceLabel: json['sourceLabel'] as String? ?? 'Official UFC events page',
      isFollowed: json['isFollowed'] as bool? ?? false,
      watchProviders: (json['watchProviders'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (provider) => WatchProviderSummary(
              label: provider['label'] as String? ?? 'UFC Fight Pass',
              countryCode: provider['countryCode'] as String? ?? 'NL',
              kind: _parseProviderKind(provider['kind'] as String?),
              confidenceLabel:
                  _confidenceLabelFromApi(provider['confidence'] as String?),
            ),
          )
          .toList(),
      bouts: (json['bouts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (bout) => BoutSummary(
              id: bout['id'] as String? ?? '',
              slotLabel: bout['slotLabel'] as String? ?? 'Featured bout',
              fighterAId: bout['fighterAId'] as String? ?? '',
              fighterAName: bout['fighterAName'] as String? ?? '',
              fighterBId: bout['fighterBId'] as String? ?? '',
              fighterBName: bout['fighterBName'] as String? ?? '',
              weightClass: bout['weightClass'] as String?,
              isMainEvent: bout['isMainEvent'] as bool? ?? false,
              includesFollowedFighter:
                  bout['includesFollowedFighter'] as bool? ?? false,
            ),
          )
          .toList(),
    );
  }

  EventSummary toMobile() {
    return EventSummary(
      id: id,
      organization: organizationName,
      sport: sport,
      title: title,
      tagline: tagline,
      locationLabel: locationLabel,
      venueLabel: venueLabel,
      localDateLabel: localDateLabel,
      localTimeLabel: localTimeLabel,
      eventLocalTimeLabel: eventLocalTimeLabel,
      selectedCountryCode: selectedCountryCode,
      isFollowed: isFollowed,
      sourceLabel: sourceLabel,
      watchProviders: watchProviders,
      bouts: bouts,
    );
  }
}

class LeaderboardSummaryJson {
  const LeaderboardSummaryJson({
    required this.id,
    required this.title,
    required this.organization,
    required this.group,
    required this.weightClass,
    required this.sourceLabel,
    required this.entries,
  });

  final String id;
  final String title;
  final String organization;
  final RankingGroup group;
  final String weightClass;
  final String sourceLabel;
  final List<LeaderboardEntrySummary> entries;

  factory LeaderboardSummaryJson.fromJson(Map<String, dynamic> json) {
    return LeaderboardSummaryJson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      organization: json['organizationName'] as String? ?? 'UFC',
      group: _parseRankingGroup(json['gender'] as String?),
      weightClass: json['weightClass'] as String? ?? '',
      sourceLabel: json['sourceLabel'] as String? ?? '',
      entries: (json['entries'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (entry) => LeaderboardEntrySummary(
              id: entry['id'] as String? ??
                  '${json['id'] ?? 'lb'}_${entry['fighterName'] ?? 'fighter'}',
              rank: entry['rank'] as int? ?? 0,
              fighterId: entry['fighterId'] as String? ?? '',
              fighterName: entry['fighterName'] as String? ?? '',
              recordLabel: entry['recordLabel'] as String? ?? 'Record pending',
              organization: json['organizationName'] as String? ?? 'UFC',
              isChampion: entry['isChampion'] as bool? ?? false,
              pointsLabel: entry['pointsLabel'] as String?,
            ),
          )
          .toList(),
    );
  }

  LeaderboardSummary toMobile() {
    return LeaderboardSummary(
      id: id,
      title: title,
      organization: organization,
      group: group,
      weightClass: weightClass,
      sourceLabel: sourceLabel,
      entries: entries,
    );
  }
}

ProviderKind _parseProviderKind(String? rawKind) {
  switch (rawKind) {
    case 'tv':
      return ProviderKind.tv;
    case 'ppv':
      return ProviderKind.ppv;
    case 'network':
      return ProviderKind.network;
    case 'streaming':
    default:
      return ProviderKind.streaming;
  }
}

String _confidenceLabelFromApi(String? rawConfidence) {
  switch (rawConfidence) {
    case 'confirmed':
      return 'Confirmed';
    case 'likely':
      return 'Likely';
    default:
      return 'Unknown';
  }
}

RankingGroup _parseRankingGroup(String? rawGroup) {
  switch (rawGroup) {
    case 'women':
      return RankingGroup.women;
    case 'men':
    default:
      return RankingGroup.men;
  }
}

PremiumState _parsePremiumState(String? rawState) {
  switch (rawState) {
    case 'premium':
      return PremiumState.premium;
    case 'free':
    default:
      return PremiumState.free;
  }
}

Sport _parseSport(String? rawSport) {
  switch (rawSport) {
    case 'boxing':
      return Sport.boxing;
    case 'kickboxing':
      return Sport.kickboxing;
    case 'mma':
    default:
      return Sport.mma;
  }
}

String _organizationLabelFromHints(List<String> organizationHints) {
  final primary = organizationHints.isEmpty ? 'fightcue' : organizationHints.first;

  switch (primary.toLowerCase()) {
    case 'ufc':
      return 'UFC';
    case 'matchroom':
      return 'Matchroom';
    case 'glory':
      return 'GLORY';
    default:
      return primary.isEmpty
          ? 'FightCue'
          : '${primary[0].toUpperCase()}${primary.substring(1)}';
  }
}

AlertPreset _parseAlertPreset(String? rawPreset) {
  switch (rawPreset) {
    case 'before_1h':
      return AlertPreset.before1h;
    case 'time_changes':
      return AlertPreset.timeChanges;
    case 'watch_updates':
      return AlertPreset.watchUpdates;
    case 'before_24h':
    default:
      return AlertPreset.before24h;
  }
}

String _alertPresetToApi(AlertPreset preset) {
  switch (preset) {
    case AlertPreset.before24h:
      return 'before_24h';
    case AlertPreset.before1h:
      return 'before_1h';
    case AlertPreset.timeChanges:
      return 'time_changes';
    case AlertPreset.watchUpdates:
      return 'watch_updates';
  }
}
