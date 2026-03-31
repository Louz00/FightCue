enum Sport { boxing, mma, kickboxing }

enum PremiumState { free, premium }

enum AdTier { freeWithAds, premiumNoAds }

enum ProviderKind { streaming, tv, ppv, network }

enum RankingGroup { men, women }

enum AlertPreset { before24h, before1h, timeChanges, watchUpdates }

enum PushPermissionStatus { unknown, prompt, granted, denied }

enum PushTokenPlatform { android, ios, web }

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

class EventDetailSnapshot {
  const EventDetailSnapshot({
    required this.event,
    required this.calendarExportPath,
  });

  final EventSummary event;
  final String calendarExportPath;
}

class FighterDetailSnapshot {
  const FighterDetailSnapshot({
    required this.fighter,
    required this.relatedEvents,
  });

  final FighterSummary fighter;
  final List<EventSummary> relatedEvents;
}

class AlertsSnapshot {
  const AlertsSnapshot({
    required this.fighterPresetsById,
    required this.eventPresetsById,
  });

  final Map<String, Set<AlertPreset>> fighterPresetsById;
  final Map<String, Set<AlertPreset>> eventPresetsById;

  Set<AlertPreset> fighterPresetsFor(String fighterId) {
    return fighterPresetsById[fighterId] ?? const {};
  }

  Set<AlertPreset> eventPresetsFor(String eventId) {
    return eventPresetsById[eventId] ?? const {};
  }

  AlertsSnapshot copyWith({
    Map<String, Set<AlertPreset>>? fighterPresetsById,
    Map<String, Set<AlertPreset>>? eventPresetsById,
  }) {
    return AlertsSnapshot(
      fighterPresetsById: fighterPresetsById ?? this.fighterPresetsById,
      eventPresetsById: eventPresetsById ?? this.eventPresetsById,
    );
  }
}

class HomeSnapshot {
  const HomeSnapshot({
    required this.fighters,
    required this.events,
    required this.premiumState,
    required this.adTier,
    required this.adConsentRequired,
    required this.adConsentGranted,
    required this.analyticsConsent,
    required this.accountModeLabel,
    required this.languageCode,
    required this.timezone,
    required this.viewingCountryCode,
  });

  final List<FighterSummary> fighters;
  final List<EventSummary> events;
  final PremiumState premiumState;
  final AdTier adTier;
  final bool adConsentRequired;
  final bool adConsentGranted;
  final bool analyticsConsent;
  final String accountModeLabel;
  final String languageCode;
  final String timezone;
  final String viewingCountryCode;

  bool get quietAdsEnabled =>
      premiumState == PremiumState.free &&
      (!adConsentRequired || adConsentGranted);

  List<FighterSummary> get followedFighters =>
      fighters.where((fighter) => fighter.isFollowed).toList();

  List<EventSummary> get followedEvents =>
      events.where((event) => event.isFollowed).toList();

  FighterSummary? fighterById(String id) {
    for (final fighter in fighters) {
      if (fighter.id == id) {
        return fighter;
      }
    }
    return null;
  }

  EventSummary? eventById(String id) {
    for (final event in events) {
      if (event.id == id) {
        return event;
      }
    }
    return null;
  }

  List<EventSummary> relatedEventsForFighter(String fighterId) {
    return events
        .where(
          (event) => event.bouts.any(
            (bout) => bout.fighterAId == fighterId || bout.fighterBId == fighterId,
          ),
        )
        .toList();
  }

  HomeSnapshot copyWith({
    List<FighterSummary>? fighters,
    List<EventSummary>? events,
    PremiumState? premiumState,
    AdTier? adTier,
    bool? adConsentRequired,
    bool? adConsentGranted,
    bool? analyticsConsent,
    String? accountModeLabel,
    String? languageCode,
    String? timezone,
    String? viewingCountryCode,
  }) {
    return HomeSnapshot(
      fighters: fighters ?? this.fighters,
      events: events ?? this.events,
      premiumState: premiumState ?? this.premiumState,
      adTier: adTier ?? this.adTier,
      adConsentRequired: adConsentRequired ?? this.adConsentRequired,
      adConsentGranted: adConsentGranted ?? this.adConsentGranted,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      accountModeLabel: accountModeLabel ?? this.accountModeLabel,
      languageCode: languageCode ?? this.languageCode,
      timezone: timezone ?? this.timezone,
      viewingCountryCode: viewingCountryCode ?? this.viewingCountryCode,
    );
  }
}

class MonetizationSnapshot {
  const MonetizationSnapshot({
    required this.premiumState,
    required this.adTier,
    required this.adConsentRequired,
    required this.adConsentGranted,
    required this.analyticsConsent,
    required this.quietAdsEnabled,
  });

  final PremiumState premiumState;
  final AdTier adTier;
  final bool adConsentRequired;
  final bool adConsentGranted;
  final bool analyticsConsent;
  final bool quietAdsEnabled;

  MonetizationSnapshot copyWith({
    PremiumState? premiumState,
    AdTier? adTier,
    bool? adConsentRequired,
    bool? adConsentGranted,
    bool? analyticsConsent,
    bool? quietAdsEnabled,
  }) {
    return MonetizationSnapshot(
      premiumState: premiumState ?? this.premiumState,
      adTier: adTier ?? this.adTier,
      adConsentRequired: adConsentRequired ?? this.adConsentRequired,
      adConsentGranted: adConsentGranted ?? this.adConsentGranted,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      quietAdsEnabled: quietAdsEnabled ?? this.quietAdsEnabled,
    );
  }
}

class PushSettingsSnapshot {
  const PushSettingsSnapshot({
    required this.pushEnabled,
    required this.permissionStatus,
    required this.tokenRegistered,
    this.tokenPlatform,
    this.tokenUpdatedAt,
  });

  final bool pushEnabled;
  final PushPermissionStatus permissionStatus;
  final bool tokenRegistered;
  final PushTokenPlatform? tokenPlatform;
  final DateTime? tokenUpdatedAt;

  PushSettingsSnapshot copyWith({
    bool? pushEnabled,
    PushPermissionStatus? permissionStatus,
    bool? tokenRegistered,
    PushTokenPlatform? tokenPlatform,
    DateTime? tokenUpdatedAt,
  }) {
    return PushSettingsSnapshot(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      tokenRegistered: tokenRegistered ?? this.tokenRegistered,
      tokenPlatform: tokenPlatform ?? this.tokenPlatform,
      tokenUpdatedAt: tokenUpdatedAt ?? this.tokenUpdatedAt,
    );
  }
}
