part of 'api_models.dart';

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

BillingProviderType _parseBillingProviderType(String? rawValue) {
  switch (rawValue) {
    case 'storekit_play':
      return BillingProviderType.storekitPlay;
    case 'disabled':
    default:
      return BillingProviderType.disabled;
  }
}

AdProviderType _parseAdProviderType(String? rawValue) {
  switch (rawValue) {
    case 'google_admob':
      return AdProviderType.googleAdmob;
    case 'disabled':
    default:
      return AdProviderType.disabled;
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
