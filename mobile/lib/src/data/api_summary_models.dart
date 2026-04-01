part of 'api_models.dart';

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
