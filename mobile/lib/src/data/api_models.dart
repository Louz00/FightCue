import '../models/domain_models.dart';

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

class PushSettingsSnapshotJson {
  const PushSettingsSnapshotJson({
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

  factory PushSettingsSnapshotJson.fromJson(Map<String, dynamic> json) {
    return PushSettingsSnapshotJson(
      pushEnabled: json['pushEnabled'] as bool? ?? false,
      permissionStatus:
          _parsePushPermissionStatus(json['permissionStatus'] as String?),
      tokenRegistered: json['tokenRegistered'] as bool? ?? false,
      tokenPlatform: _parsePushTokenPlatform(json['tokenPlatform'] as String?),
      tokenUpdatedAt: _parseDateTime(json['tokenUpdatedAt'] as String?),
    );
  }

  PushSettingsSnapshot toMobile() {
    return PushSettingsSnapshot(
      pushEnabled: pushEnabled,
      permissionStatus: permissionStatus,
      tokenRegistered: tokenRegistered,
      tokenPlatform: tokenPlatform,
      tokenUpdatedAt: tokenUpdatedAt,
    );
  }
}

class PushProviderStatusSnapshotJson {
  const PushProviderStatusSnapshotJson({
    required this.provider,
    required this.supportsDelivery,
    required this.configured,
    required this.description,
  });

  final PushProviderType provider;
  final bool supportsDelivery;
  final bool configured;
  final String description;

  factory PushProviderStatusSnapshotJson.fromJson(Map<String, dynamic> json) {
    return PushProviderStatusSnapshotJson(
      provider: _parsePushProviderType(json['provider'] as String?),
      supportsDelivery: json['supportsDelivery'] as bool? ?? false,
      configured: json['configured'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );
  }

  PushProviderStatusSnapshot toMobile() {
    return PushProviderStatusSnapshot(
      provider: provider,
      supportsDelivery: supportsDelivery,
      configured: configured,
      description: description,
    );
  }
}

class PushPreviewItemSummaryJson {
  const PushPreviewItemSummaryJson({
    required this.id,
    required this.deliveryKind,
    required this.reasonKey,
    required this.title,
    required this.body,
    this.scheduledLocalLabel,
  });

  final String id;
  final String deliveryKind;
  final String reasonKey;
  final String title;
  final String body;
  final String? scheduledLocalLabel;

  factory PushPreviewItemSummaryJson.fromJson(Map<String, dynamic> json) {
    return PushPreviewItemSummaryJson(
      id: json['id'] as String? ?? '',
      deliveryKind: json['deliveryKind'] as String? ?? 'signal',
      reasonKey: json['reason'] as String? ?? 'time_changes',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      scheduledLocalLabel: json['scheduledLocalLabel'] as String?,
    );
  }

  PushPreviewItemSummary toMobile() {
    return PushPreviewItemSummary(
      id: id,
      deliveryKind: deliveryKind,
      reasonKey: reasonKey,
      title: title,
      body: body,
      scheduledLocalLabel: scheduledLocalLabel,
    );
  }
}

class PushPreviewSnapshotJson {
  const PushPreviewSnapshotJson({
    required this.deliveryReadiness,
    required this.scheduledCount,
    required this.signalCount,
    required this.items,
  });

  final PushDeliveryReadiness deliveryReadiness;
  final int scheduledCount;
  final int signalCount;
  final List<PushPreviewItemSummary> items;

  factory PushPreviewSnapshotJson.fromJson(Map<String, dynamic> json) {
    return PushPreviewSnapshotJson(
      deliveryReadiness:
          _parsePushDeliveryReadiness(json['deliveryReadiness'] as String?),
      scheduledCount: json['scheduledCount'] as int? ?? 0,
      signalCount: json['signalCount'] as int? ?? 0,
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PushPreviewItemSummaryJson.fromJson)
          .map((entry) => entry.toMobile())
          .toList(),
    );
  }

  PushPreviewSnapshot toMobile() {
    return PushPreviewSnapshot(
      deliveryReadiness: deliveryReadiness,
      scheduledCount: scheduledCount,
      signalCount: signalCount,
      items: items,
    );
  }
}

class PushTestDispatchSnapshotJson {
  const PushTestDispatchSnapshotJson({
    required this.provider,
    required this.deliveryReadiness,
    required this.dispatched,
    required this.message,
    this.providerMessageId,
  });

  final PushProviderType provider;
  final PushDeliveryReadiness deliveryReadiness;
  final bool dispatched;
  final String message;
  final String? providerMessageId;

  factory PushTestDispatchSnapshotJson.fromJson(Map<String, dynamic> json) {
    return PushTestDispatchSnapshotJson(
      provider: _parsePushProviderType(json['provider'] as String?),
      deliveryReadiness:
          _parsePushDeliveryReadiness(json['deliveryReadiness'] as String?),
      dispatched: json['dispatched'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      providerMessageId: json['providerMessageId'] as String?,
    );
  }

  PushTestDispatchSnapshot toMobile() {
    return PushTestDispatchSnapshot(
      provider: provider,
      deliveryReadiness: deliveryReadiness,
      dispatched: dispatched,
      message: message,
      providerMessageId: providerMessageId,
    );
  }
}

class MonetizationSnapshotJson {
  const MonetizationSnapshotJson({
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

  factory MonetizationSnapshotJson.fromJson(Map<String, dynamic> json) {
    return MonetizationSnapshotJson(
      premiumState: _parsePremiumState(json['premiumState'] as String?),
      adTier: _parseAdTier(json['adTier'] as String?),
      adConsentRequired: json['adConsentRequired'] as bool? ?? true,
      adConsentGranted: json['adConsentGranted'] as bool? ?? false,
      analyticsConsent: json['analyticsConsent'] as bool? ?? false,
      quietAdsEnabled: json['quietAdsEnabled'] as bool? ?? false,
    );
  }

  MonetizationSnapshot toMobile() {
    return MonetizationSnapshot(
      premiumState: premiumState,
      adTier: adTier,
      adConsentRequired: adConsentRequired,
      adConsentGranted: adConsentGranted,
      analyticsConsent: analyticsConsent,
      quietAdsEnabled: quietAdsEnabled,
    );
  }
}

class HomeSnapshotJson {
  const HomeSnapshotJson({
    required this.languageCode,
    required this.timezone,
    required this.viewingCountryCode,
    required this.premiumState,
    required this.adTier,
    required this.adConsentRequired,
    required this.adConsentGranted,
    required this.analyticsConsent,
    required this.accountModeLabel,
    required this.fighters,
    required this.events,
  });

  final String languageCode;
  final String timezone;
  final String viewingCountryCode;
  final PremiumState premiumState;
  final AdTier adTier;
  final bool adConsentRequired;
  final bool adConsentGranted;
  final bool analyticsConsent;
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
      adTier: _parseAdTier(profile['adTier'] as String?),
      adConsentRequired: profile['adConsentRequired'] as bool? ?? true,
      adConsentGranted: profile['adConsentGranted'] as bool? ?? false,
      analyticsConsent: profile['analyticsConsent'] as bool? ?? false,
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
      adTier: adTier,
      adConsentRequired: adConsentRequired,
      adConsentGranted: adConsentGranted,
      analyticsConsent: analyticsConsent,
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

AdTier _parseAdTier(String? rawTier) {
  switch (rawTier) {
    case 'premium_no_ads':
      return AdTier.premiumNoAds;
    case 'free_with_ads':
    default:
      return AdTier.freeWithAds;
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

PushPermissionStatus _parsePushPermissionStatus(String? rawStatus) {
  switch (rawStatus) {
    case 'prompt':
      return PushPermissionStatus.prompt;
    case 'granted':
      return PushPermissionStatus.granted;
    case 'denied':
      return PushPermissionStatus.denied;
    case 'unknown':
    default:
      return PushPermissionStatus.unknown;
  }
}

PushTokenPlatform? _parsePushTokenPlatform(String? rawPlatform) {
  switch (rawPlatform) {
    case 'android':
      return PushTokenPlatform.android;
    case 'ios':
      return PushTokenPlatform.ios;
    case 'web':
      return PushTokenPlatform.web;
    default:
      return null;
  }
}

PushDeliveryReadiness _parsePushDeliveryReadiness(String? rawValue) {
  switch (rawValue) {
    case 'ready':
      return PushDeliveryReadiness.ready;
    case 'disabled':
      return PushDeliveryReadiness.disabled;
    case 'permission_required':
      return PushDeliveryReadiness.permissionRequired;
    case 'token_missing':
    default:
      return PushDeliveryReadiness.tokenMissing;
  }
}

PushProviderType _parsePushProviderType(String? rawValue) {
  switch (rawValue) {
    case 'disabled':
      return PushProviderType.disabled;
    case 'firebase':
      return PushProviderType.firebase;
    case 'log':
    default:
      return PushProviderType.log;
  }
}

DateTime? _parseDateTime(String? rawValue) {
  if (rawValue == null || rawValue.isEmpty) {
    return null;
  }

  return DateTime.tryParse(rawValue);
}

String alertPresetToApi(AlertPreset preset) {
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
