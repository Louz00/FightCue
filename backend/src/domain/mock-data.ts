import type {
  EventSummary,
  FighterSummary,
  LeaderboardSummary,
  UserProfile,
} from "./models.js";

export const sampleUserProfile: UserProfile = {
  id: "usr_demo_001",
  isAnonymous: true,
  language: "en",
  timezone: "Europe/Amsterdam",
  viewingCountryCode: "NL",
  premiumState: "free",
  adTier: "free_with_ads",
  analyticsConsent: false,
  adConsentRequired: true,
  adConsentGranted: false,
};

export const sampleFollowedFighters: FighterSummary[] = [
  {
    id: "ftr_001",
    name: "Katie Taylor",
    organizationHints: ["matchroom"],
    isFollowed: true,
  },
  {
    id: "ftr_002",
    name: "Alex Pereira",
    organizationHints: ["ufc"],
    isFollowed: true,
  },
];

export const sampleEvents: EventSummary[] = [
  {
    id: "evt_matchroom_001",
    organizationSlug: "matchroom",
    organizationName: "Matchroom",
    sport: "boxing",
    title: "Taylor vs Serrano III",
    locationLabel: "Dublin, Ireland",
    scheduledStartUtc: "2026-04-18T19:00:00Z",
    scheduledTimezone: "Europe/Dublin",
    localDateLabel: "Sat 18 Apr",
    localTimeLabel: "21:00",
    eventLocalTimeLabel: "20:00 local",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: true,
    watchProviders: [
      {
        label: "DAZN",
        kind: "streaming",
        countryCode: "NL",
        confidence: "confirmed",
        lastVerifiedAt: "2026-03-29T16:00:00Z",
      },
    ],
    bouts: [
      {
        id: "bout_001",
        slotLabel: "Main event",
        fighterAName: "Katie Taylor",
        fighterBName: "Amanda Serrano",
        weightClass: "Lightweight",
        isMainEvent: true,
        includesFollowedFighter: true,
      },
      {
        id: "bout_002",
        slotLabel: "Co-main",
        fighterAName: "Fighter A",
        fighterBName: "Fighter B",
        weightClass: "Welterweight",
        isMainEvent: false,
        includesFollowedFighter: false,
      },
    ],
  },
  {
    id: "evt_ufc_001",
    organizationSlug: "ufc",
    organizationName: "UFC",
    sport: "mma",
    title: "Pereira vs Ankalaev",
    locationLabel: "Las Vegas, USA",
    scheduledStartUtc: "2026-05-09T02:00:00Z",
    scheduledTimezone: "America/Los_Angeles",
    localDateLabel: "Sun 10 May",
    localTimeLabel: "04:00",
    eventLocalTimeLabel: "19:00 local",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: false,
    watchProviders: [
      {
        label: "Discovery+ / TNT Sports",
        kind: "streaming",
        countryCode: "NL",
        confidence: "likely",
        lastVerifiedAt: "2026-03-29T16:00:00Z",
      },
    ],
    bouts: [
      {
        id: "bout_003",
        slotLabel: "Main event",
        fighterAName: "Alex Pereira",
        fighterBName: "Magomed Ankalaev",
        weightClass: "Light Heavyweight",
        isMainEvent: true,
        includesFollowedFighter: true,
      },
      {
        id: "bout_004",
        slotLabel: "Co-main",
        fighterAName: "Fighter C",
        fighterBName: "Fighter D",
        weightClass: "Flyweight",
        isMainEvent: false,
        includesFollowedFighter: false,
      },
    ],
  },
];

export const sampleLeaderboards: LeaderboardSummary[] = [
  {
    id: "lb_ufc_official",
    title: "UFC rankings",
    organizationSlug: "ufc",
    sourceType: "official",
    sourceLabel: "Official UFC ranking direction",
    entries: [
      { rank: 1, fighterName: "Alex Pereira", organizationSlug: "ufc" },
      { rank: 2, fighterName: "Islam Makhachev", organizationSlug: "ufc" },
    ],
  },
];
