export type SupportedLanguage = "en" | "nl" | "es";
export type Sport = "boxing" | "mma" | "kickboxing";
export type PremiumState = "free" | "premium";
export type AccountProvider = "email_magic_link";
export type FollowTarget = "fighter" | "event";
export type ProviderKind = "streaming" | "tv" | "ppv" | "network";
export type ProviderConfidence = "confirmed" | "likely" | "unknown";
export type ProviderVerificationSource =
  | "source"
  | "event_override"
  | "organization_default"
  | "official_page_fallback";
export type LeaderboardSourceType =
  | "official"
  | "editorial"
  | "fightcue_trending";
export type LeaderboardGender = "men" | "women";
export type EventStatus =
  | "scheduled"
  | "estimated"
  | "changed"
  | "cancelled"
  | "completed";
export type SourceMode = "live" | "fallback";
export type SourceHealthStatus = "healthy" | "degraded" | "fallback";
export type AlertPresetKey =
  | "before_24h"
  | "before_1h"
  | "time_changes"
  | "watch_updates";
export type PushPermissionStatus =
  | "unknown"
  | "prompt"
  | "granted"
  | "denied";
export type PushTokenPlatform = "android" | "ios" | "web";
export type PushDeliveryReadiness =
  | "ready"
  | "disabled"
  | "permission_required"
  | "token_missing";
export type PushPreviewTargetType = "fighter" | "event";
export type PushPreviewDeliveryKind = "scheduled" | "signal";

export type UserProfile = {
  id: string;
  isAnonymous: boolean;
  language: SupportedLanguage;
  timezone: string;
  viewingCountryCode: string;
  premiumState: PremiumState;
  adTier: "free_with_ads" | "premium_no_ads";
  analyticsConsent: boolean;
  adConsentRequired: boolean;
  adConsentGranted: boolean;
};

export type UserAccount = {
  id: string;
  userProfileId: string;
  provider: AccountProvider;
  email: string;
  createdAt: string;
};

export type Organization = {
  id: string;
  slug: string;
  name: string;
  sport: Sport;
};

export type FighterSummary = {
  id: string;
  name: string;
  sport: Sport;
  organizationHints: string[];
  recordLabel: string;
  nationalityLabel: string;
  headline: string;
  nextAppearanceLabel: string;
  nickname?: string;
  isFollowed: boolean;
};

export type BoutSummary = {
  id: string;
  slotLabel: string;
  fighterAId: string;
  fighterAName: string;
  fighterBId: string;
  fighterBName: string;
  weightClass?: string;
  isMainEvent: boolean;
  includesFollowedFighter: boolean;
};

export type WatchProviderSummary = {
  label: string;
  kind: ProviderKind;
  countryCode: string;
  confidence: ProviderConfidence;
  lastVerifiedAt: string;
  providerUrl?: string;
  verificationSource?: ProviderVerificationSource;
};

export type EventSummary = {
  id: string;
  organizationSlug: string;
  organizationName: string;
  sport: Sport;
  title: string;
  tagline: string;
  locationLabel: string;
  venueLabel: string;
  scheduledStartUtc: string;
  scheduledTimezone: string;
  localDateLabel: string;
  localTimeLabel: string;
  eventLocalTimeLabel: string;
  selectedCountryCode: string;
  status: EventStatus;
  isFollowed: boolean;
  sourceLabel: string;
  officialUrl?: string;
  watchProviders: WatchProviderSummary[];
  bouts: BoutSummary[];
};

export type FollowRecord = {
  id: string;
  userProfileId: string;
  target: FollowTarget;
  targetId: string;
  createdAt: string;
};

export type AlertPreferenceSummary = {
  targetId: string;
  presetKeys: AlertPresetKey[];
};

export type PushSettingsSummary = {
  pushEnabled: boolean;
  permissionStatus: PushPermissionStatus;
  tokenPlatform?: PushTokenPlatform;
  tokenRegistered: boolean;
  tokenUpdatedAt?: string;
};

export type PushPreviewItem = {
  id: string;
  deliveryKind: PushPreviewDeliveryKind;
  reason: AlertPresetKey;
  targetType: PushPreviewTargetType;
  targetId: string;
  eventId?: string;
  title: string;
  body: string;
  scheduledForUtc?: string;
  scheduledLocalLabel?: string;
};

export type PushPreviewSummary = PushSettingsSummary & {
  deliveryReadiness: PushDeliveryReadiness;
  scheduledCount: number;
  signalCount: number;
  items: PushPreviewItem[];
};

export type MonetizationSummary = {
  premiumState: PremiumState;
  adTier: UserProfile["adTier"];
  adConsentRequired: boolean;
  adConsentGranted: boolean;
  analyticsConsent: boolean;
  quietAdsEnabled: boolean;
};

export type LeaderboardEntry = {
  id: string;
  rank: number;
  fighterId: string;
  fighterName: string;
  organizationSlug: string;
  recordLabel?: string;
  isChampion?: boolean;
  pointsLabel?: string;
};

export type LeaderboardSummary = {
  id: string;
  title: string;
  organizationSlug: string;
  organizationName: string;
  sourceType: LeaderboardSourceType;
  gender: LeaderboardGender;
  weightClass: string;
  sourceLabel: string;
  entries: LeaderboardEntry[];
};

export type SourcePreview<T> = {
  source: string;
  mode: SourceMode;
  officialUrl: string;
  timezone: string;
  selectedCountryCode: string;
  fetchedAt: string;
  itemCount: number;
  health: SourceHealth;
  warnings: string[];
  items: T[];
};

export type SourceHealth = {
  status: SourceHealthStatus;
  parsedItemCount: number;
  reportedItemCount?: number;
  checkedPageCount: number;
  coverageGap: number;
  coverageRatio?: number;
};

export const fightCueRuntimeProfile = {
  authStrategy: {
    anonymousByDefault: true,
    optionalAccountProvider: "email_magic_link" as AccountProvider,
  },
  monetization: {
    adNetwork: "google_admob",
    quietAdsOnly: true,
    premiumRemovesAds: true,
  },
  leaderboards: {
    boxingEnabledInMvp: false,
    boxingPolicy: "official-source-only-later",
  },
};
