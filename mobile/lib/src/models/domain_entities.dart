part of 'domain_models.dart';

class FighterSummary {
  const FighterSummary({
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

  FighterSummary copyWith({
    String? id,
    String? name,
    Sport? sport,
    String? organizationHint,
    String? recordLabel,
    String? nationalityLabel,
    String? headline,
    String? nextAppearanceLabel,
    String? nickname,
    bool? isFollowed,
  }) {
    return FighterSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      organizationHint: organizationHint ?? this.organizationHint,
      recordLabel: recordLabel ?? this.recordLabel,
      nationalityLabel: nationalityLabel ?? this.nationalityLabel,
      headline: headline ?? this.headline,
      nextAppearanceLabel: nextAppearanceLabel ?? this.nextAppearanceLabel,
      nickname: nickname ?? this.nickname,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}

class BoutSummary {
  const BoutSummary({
    required this.id,
    required this.slotLabel,
    required this.fighterAId,
    required this.fighterAName,
    required this.fighterBId,
    required this.fighterBName,
    required this.isMainEvent,
    required this.includesFollowedFighter,
    this.weightClass,
  });

  final String id;
  final String slotLabel;
  final String fighterAId;
  final String fighterAName;
  final String fighterBId;
  final String fighterBName;
  final String? weightClass;
  final bool isMainEvent;
  final bool includesFollowedFighter;

  BoutSummary copyWith({
    String? id,
    String? slotLabel,
    String? fighterAId,
    String? fighterAName,
    String? fighterBId,
    String? fighterBName,
    String? weightClass,
    bool? isMainEvent,
    bool? includesFollowedFighter,
  }) {
    return BoutSummary(
      id: id ?? this.id,
      slotLabel: slotLabel ?? this.slotLabel,
      fighterAId: fighterAId ?? this.fighterAId,
      fighterAName: fighterAName ?? this.fighterAName,
      fighterBId: fighterBId ?? this.fighterBId,
      fighterBName: fighterBName ?? this.fighterBName,
      weightClass: weightClass ?? this.weightClass,
      isMainEvent: isMainEvent ?? this.isMainEvent,
      includesFollowedFighter:
          includesFollowedFighter ?? this.includesFollowedFighter,
    );
  }
}

class WatchProviderSummary {
  const WatchProviderSummary({
    required this.label,
    required this.countryCode,
    required this.kind,
    required this.confidenceLabel,
  });

  final String label;
  final String countryCode;
  final ProviderKind kind;
  final String confidenceLabel;
}

class EventSummary {
  const EventSummary({
    required this.id,
    required this.organization,
    required this.sport,
    required this.title,
    required this.tagline,
    required this.locationLabel,
    required this.venueLabel,
    required this.localDateLabel,
    required this.localTimeLabel,
    required this.eventLocalTimeLabel,
    required this.selectedCountryCode,
    required this.isFollowed,
    required this.sourceLabel,
    required this.watchProviders,
    required this.bouts,
  });

  final String id;
  final String organization;
  final Sport sport;
  final String title;
  final String tagline;
  final String locationLabel;
  final String venueLabel;
  final String localDateLabel;
  final String localTimeLabel;
  final String eventLocalTimeLabel;
  final String selectedCountryCode;
  final bool isFollowed;
  final String sourceLabel;
  final List<WatchProviderSummary> watchProviders;
  final List<BoutSummary> bouts;

  EventSummary copyWith({
    String? id,
    String? organization,
    Sport? sport,
    String? title,
    String? tagline,
    String? locationLabel,
    String? venueLabel,
    String? localDateLabel,
    String? localTimeLabel,
    String? eventLocalTimeLabel,
    String? selectedCountryCode,
    bool? isFollowed,
    String? sourceLabel,
    List<WatchProviderSummary>? watchProviders,
    List<BoutSummary>? bouts,
  }) {
    return EventSummary(
      id: id ?? this.id,
      organization: organization ?? this.organization,
      sport: sport ?? this.sport,
      title: title ?? this.title,
      tagline: tagline ?? this.tagline,
      locationLabel: locationLabel ?? this.locationLabel,
      venueLabel: venueLabel ?? this.venueLabel,
      localDateLabel: localDateLabel ?? this.localDateLabel,
      localTimeLabel: localTimeLabel ?? this.localTimeLabel,
      eventLocalTimeLabel: eventLocalTimeLabel ?? this.eventLocalTimeLabel,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      isFollowed: isFollowed ?? this.isFollowed,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      watchProviders: watchProviders ?? this.watchProviders,
      bouts: bouts ?? this.bouts,
    );
  }
}

class LeaderboardEntrySummary {
  const LeaderboardEntrySummary({
    required this.id,
    required this.rank,
    required this.fighterId,
    required this.fighterName,
    required this.recordLabel,
    required this.organization,
    required this.isChampion,
    this.pointsLabel,
  });

  final String id;
  final int rank;
  final String fighterId;
  final String fighterName;
  final String recordLabel;
  final String organization;
  final bool isChampion;
  final String? pointsLabel;
}

class LeaderboardSummary {
  const LeaderboardSummary({
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
}
