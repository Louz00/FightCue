import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/domain_models.dart';

class FightCueApi {
  FightCueApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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

  Future<UfcSourcePreview> fetchUfcEventsPreview({
    String timezone = 'Europe/Amsterdam',
    String countryCode = 'NL',
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/v1/sources/ufc/events?timezone=$timezone&country=$countryCode',
    );
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('UFC preview request failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
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
    final response = await _client.get(Uri.parse('$_baseUrl/v1/leaderboards'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Leaderboard request failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LeaderboardSummaryJson.fromJson)
        .map((entry) => entry.toMobile())
        .toList();
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
    required this.title,
    required this.tagline,
    required this.locationLabel,
    required this.venueLabel,
    required this.localDateLabel,
    required this.localTimeLabel,
    required this.eventLocalTimeLabel,
    required this.selectedCountryCode,
    required this.sourceLabel,
    required this.watchProviders,
    required this.bouts,
  });

  final String id;
  final String organizationName;
  final String title;
  final String tagline;
  final String locationLabel;
  final String venueLabel;
  final String localDateLabel;
  final String localTimeLabel;
  final String eventLocalTimeLabel;
  final String selectedCountryCode;
  final String sourceLabel;
  final List<WatchProviderSummary> watchProviders;
  final List<BoutSummary> bouts;

  factory EventSummaryJson.fromJson(Map<String, dynamic> json) {
    return EventSummaryJson(
      id: json['id'] as String? ?? '',
      organizationName: json['organizationName'] as String? ?? 'UFC',
      title: json['title'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      locationLabel: json['locationLabel'] as String? ?? '',
      venueLabel: json['venueLabel'] as String? ?? '',
      localDateLabel: json['localDateLabel'] as String? ?? '',
      localTimeLabel: json['localTimeLabel'] as String? ?? '',
      eventLocalTimeLabel: json['eventLocalTimeLabel'] as String? ?? '',
      selectedCountryCode: json['selectedCountryCode'] as String? ?? 'NL',
      sourceLabel: json['sourceLabel'] as String? ?? 'Official UFC events page',
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
      sport: Sport.mma,
      title: title,
      tagline: tagline,
      locationLabel: locationLabel,
      venueLabel: venueLabel,
      localDateLabel: localDateLabel,
      localTimeLabel: localTimeLabel,
      eventLocalTimeLabel: eventLocalTimeLabel,
      selectedCountryCode: selectedCountryCode,
      isFollowed: false,
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
