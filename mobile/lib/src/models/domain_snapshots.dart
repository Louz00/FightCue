part of 'domain_models.dart';

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

class BillingProviderStatusSnapshot {
  const BillingProviderStatusSnapshot({
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
}

class AdProviderStatusSnapshot {
  const AdProviderStatusSnapshot({
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

class PushProviderStatusSnapshot {
  const PushProviderStatusSnapshot({
    required this.provider,
    required this.supportsDelivery,
    required this.configured,
    required this.description,
  });

  final PushProviderType provider;
  final bool supportsDelivery;
  final bool configured;
  final String description;
}

class PushPreviewItemSummary {
  const PushPreviewItemSummary({
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
}

class PushPreviewSnapshot {
  const PushPreviewSnapshot({
    required this.deliveryReadiness,
    required this.scheduledCount,
    required this.signalCount,
    required this.items,
  });

  final PushDeliveryReadiness deliveryReadiness;
  final int scheduledCount;
  final int signalCount;
  final List<PushPreviewItemSummary> items;

  PushPreviewSnapshot copyWith({
    PushDeliveryReadiness? deliveryReadiness,
    int? scheduledCount,
    int? signalCount,
    List<PushPreviewItemSummary>? items,
  }) {
    return PushPreviewSnapshot(
      deliveryReadiness: deliveryReadiness ?? this.deliveryReadiness,
      scheduledCount: scheduledCount ?? this.scheduledCount,
      signalCount: signalCount ?? this.signalCount,
      items: items ?? this.items,
    );
  }
}

class PushTestDispatchSnapshot {
  const PushTestDispatchSnapshot({
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
}
