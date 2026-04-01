part of 'api_models.dart';

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

class BillingProviderStatusSnapshotJson {
  const BillingProviderStatusSnapshotJson({
    required this.provider,
    required this.configured,
    required this.supportsProducts,
    required this.productIds,
    required this.description,
  });

  final BillingProviderType provider;
  final bool configured;
  final bool supportsProducts;
  final List<String> productIds;
  final String description;

  factory BillingProviderStatusSnapshotJson.fromJson(Map<String, dynamic> json) {
    return BillingProviderStatusSnapshotJson(
      provider: _parseBillingProviderType(json['provider'] as String?),
      configured: json['configured'] as bool? ?? false,
      supportsProducts: json['supportsProducts'] as bool? ?? false,
      productIds: (json['productIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      description: json['description'] as String? ?? '',
    );
  }

  BillingProviderStatusSnapshot toMobile() {
    return BillingProviderStatusSnapshot(
      provider: provider,
      configured: configured,
      supportsProducts: supportsProducts,
      productIds: productIds,
      description: description,
    );
  }
}

class AdProviderStatusSnapshotJson {
  const AdProviderStatusSnapshotJson({
    required this.provider,
    required this.configured,
    required this.appIdConfigured,
    required this.bannerUnitConfigured,
    required this.description,
  });

  final AdProviderType provider;
  final bool configured;
  final bool appIdConfigured;
  final bool bannerUnitConfigured;
  final String description;

  factory AdProviderStatusSnapshotJson.fromJson(Map<String, dynamic> json) {
    return AdProviderStatusSnapshotJson(
      provider: _parseAdProviderType(json['provider'] as String?),
      configured: json['configured'] as bool? ?? false,
      appIdConfigured: json['appIdConfigured'] as bool? ?? false,
      bannerUnitConfigured: json['bannerUnitConfigured'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );
  }

  AdProviderStatusSnapshot toMobile() {
    return AdProviderStatusSnapshot(
      provider: provider,
      configured: configured,
      appIdConfigured: appIdConfigured,
      bannerUnitConfigured: bannerUnitConfigured,
      description: description,
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
