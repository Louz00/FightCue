enum Sport { boxing, mma, kickboxing }

enum PremiumState { free, premium }

enum ProviderKind { streaming, tv, ppv, network }

class FighterSummary {
  const FighterSummary({
    required this.id,
    required this.name,
    required this.organizationHint,
    required this.nextAppearanceLabel,
  });

  final String id;
  final String name;
  final String organizationHint;
  final String nextAppearanceLabel;
}

class BoutSummary {
  const BoutSummary({
    required this.id,
    required this.slotLabel,
    required this.fighterAName,
    required this.fighterBName,
    required this.isMainEvent,
    required this.includesFollowedFighter,
    this.weightClass,
  });

  final String id;
  final String slotLabel;
  final String fighterAName;
  final String fighterBName;
  final String? weightClass;
  final bool isMainEvent;
  final bool includesFollowedFighter;
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
    required this.locationLabel,
    required this.localDateLabel,
    required this.localTimeLabel,
    required this.eventLocalTimeLabel,
    required this.selectedCountryCode,
    required this.isFollowed,
    required this.watchProviders,
    required this.bouts,
  });

  final String id;
  final String organization;
  final Sport sport;
  final String title;
  final String locationLabel;
  final String localDateLabel;
  final String localTimeLabel;
  final String eventLocalTimeLabel;
  final String selectedCountryCode;
  final bool isFollowed;
  final List<WatchProviderSummary> watchProviders;
  final List<BoutSummary> bouts;
}

class HomeSnapshot {
  const HomeSnapshot({
    required this.followedFighters,
    required this.events,
    required this.premiumState,
    required this.accountModeLabel,
  });

  final List<FighterSummary> followedFighters;
  final List<EventSummary> events;
  final PremiumState premiumState;
  final String accountModeLabel;
}
