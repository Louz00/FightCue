part of 'domain_models.dart';

enum Sport { boxing, mma, kickboxing }

enum PremiumState { free, premium }

enum AdTier { freeWithAds, premiumNoAds }

enum ProviderKind { streaming, tv, ppv, network }

enum RankingGroup { men, women }

enum AlertPreset { before24h, before1h, timeChanges, watchUpdates }

enum PushPermissionStatus { unknown, prompt, granted, denied }

enum PushTokenPlatform { android, ios, web }

enum PushDeliveryReadiness {
  ready,
  disabled,
  permissionRequired,
  tokenMissing,
}

enum PushProviderType { disabled, log, firebase }

enum BillingProviderType { disabled, storekitPlay }

enum AdProviderType { disabled, googleAdmob }
