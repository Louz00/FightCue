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

export const sampleFighters: FighterSummary[] = [
  {
    id: "ftr_katie_taylor",
    name: "Katie Taylor",
    sport: "boxing",
    organizationHints: ["matchroom"],
    recordLabel: "24-1-0",
    nationalityLabel: "Ireland",
    headline: "Undisputed championship-level boxing star.",
    nextAppearanceLabel: "Sat 18 Apr",
    nickname: "The Bray Bomber",
    isFollowed: true,
  },
  {
    id: "ftr_amanda_serrano",
    name: "Amanda Serrano",
    sport: "boxing",
    organizationHints: ["matchroom"],
    recordLabel: "47-3-1",
    nationalityLabel: "Puerto Rico",
    headline: "Multi-division champion with elite volume and pressure.",
    nextAppearanceLabel: "Sat 18 Apr",
    isFollowed: false,
  },
  {
    id: "ftr_alex_pereira",
    name: "Alex Pereira",
    sport: "mma",
    organizationHints: ["ufc"],
    recordLabel: "11-3-0",
    nationalityLabel: "Brazil",
    headline: "Explosive striker with title-fight gravity.",
    nextAppearanceLabel: "Sun 10 May",
    nickname: "Poatan",
    isFollowed: true,
  },
  {
    id: "ftr_magomed_ankalaev",
    name: "Magomed Ankalaev",
    sport: "mma",
    organizationHints: ["ufc"],
    recordLabel: "21-1-1",
    nationalityLabel: "Russia",
    headline: "Calculated pressure fighter with championship upside.",
    nextAppearanceLabel: "Sun 10 May",
    isFollowed: false,
  },
  {
    id: "ftr_renato_moicano",
    name: "Renato Moicano",
    sport: "mma",
    organizationHints: ["ufc"],
    recordLabel: "21-6-1",
    nationalityLabel: "Brazil",
    headline: "Veteran lightweight with slick grappling transitions.",
    nextAppearanceLabel: "Sun 5 Apr",
    isFollowed: false,
  },
  {
    id: "ftr_chris_duncan",
    name: "Chris Duncan",
    sport: "mma",
    organizationHints: ["ufc"],
    recordLabel: "13-2-0",
    nationalityLabel: "Scotland",
    headline: "Aggressive finisher pushing into bigger UFC spots.",
    nextAppearanceLabel: "Sun 5 Apr",
    isFollowed: false,
  },
  {
    id: "ftr_virna_jandiroba",
    name: "Virna Jandiroba",
    sport: "mma",
    organizationHints: ["ufc"],
    recordLabel: "23-4-0",
    nationalityLabel: "Brazil",
    headline: "Elite submission grappler climbing the strawweight ranks.",
    nextAppearanceLabel: "Sun 5 Apr",
    isFollowed: false,
  },
  {
    id: "ftr_tabatha_ricci",
    name: "Tabatha Ricci",
    sport: "mma",
    organizationHints: ["ufc"],
    recordLabel: "12-3-0",
    nationalityLabel: "Brazil",
    headline: "Strong transitional wrestler with steady momentum.",
    nextAppearanceLabel: "Sun 5 Apr",
    nickname: "Baby Shark",
    isFollowed: false,
  },
];

export const sampleFollowedFighters = sampleFighters.filter(
  (fighter) => fighter.isFollowed,
);

export const sampleEvents: EventSummary[] = [
  {
    id: "evt_matchroom_taylor_serrano",
    organizationSlug: "matchroom",
    organizationName: "Matchroom",
    sport: "boxing",
    title: "Taylor vs Serrano III",
    tagline: "A championship rematch built for a major Dublin night.",
    locationLabel: "Dublin, Ireland",
    venueLabel: "3Arena",
    scheduledStartUtc: "2026-04-18T19:00:00Z",
    scheduledTimezone: "Europe/Dublin",
    localDateLabel: "Sat 18 Apr",
    localTimeLabel: "21:00",
    eventLocalTimeLabel: "20:00 local",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: true,
    sourceLabel: "Official promoter schedule",
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
        id: "bout_taylor_serrano",
        slotLabel: "Main event",
        fighterAId: "ftr_katie_taylor",
        fighterAName: "Katie Taylor",
        fighterBId: "ftr_amanda_serrano",
        fighterBName: "Amanda Serrano",
        weightClass: "Lightweight",
        isMainEvent: true,
        includesFollowedFighter: true,
      },
    ],
  },
  {
    id: "evt_ufc_327",
    organizationSlug: "ufc",
    organizationName: "UFC",
    sport: "mma",
    title: "Pereira vs Ankalaev",
    tagline: "A sharp title-fight card with real championship stakes.",
    locationLabel: "Miami, Florida, USA",
    venueLabel: "Kaseya Center",
    scheduledStartUtc: "2026-05-09T02:00:00Z",
    scheduledTimezone: "America/New_York",
    localDateLabel: "Sun 10 May",
    localTimeLabel: "04:00",
    eventLocalTimeLabel: "Sat 9 May • 9:00 PM EDT",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Official UFC schedule",
    officialUrl: "https://www.ufc.com/events",
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
        id: "bout_pereira_ankalaev",
        slotLabel: "Main event",
        fighterAId: "ftr_alex_pereira",
        fighterAName: "Alex Pereira",
        fighterBId: "ftr_magomed_ankalaev",
        fighterBName: "Magomed Ankalaev",
        weightClass: "Light Heavyweight",
        isMainEvent: true,
        includesFollowedFighter: true,
      },
    ],
  },
  {
    id: "evt_ufc_fight_night_moicano_duncan",
    organizationSlug: "ufc",
    organizationName: "UFC",
    sport: "mma",
    title: "Moicano vs Duncan",
    tagline: "A compact UFC Fight Night card with strong lightweight stakes.",
    locationLabel: "Las Vegas, Nevada, USA",
    venueLabel: "Meta APEX",
    scheduledStartUtc: "2026-04-05T00:00:00Z",
    scheduledTimezone: "America/New_York",
    localDateLabel: "Sun 5 Apr",
    localTimeLabel: "02:00",
    eventLocalTimeLabel: "Sat 4 Apr • 8:00 PM EDT",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: true,
    sourceLabel: "Official UFC schedule",
    officialUrl: "https://www.ufc.com/events",
    watchProviders: [
      {
        label: "UFC Fight Pass",
        kind: "streaming",
        countryCode: "NL",
        confidence: "likely",
        lastVerifiedAt: "2026-03-29T16:00:00Z",
        providerUrl: "https://www.ufcfightpass.com",
      },
    ],
    bouts: [
      {
        id: "bout_moicano_duncan",
        slotLabel: "Main event",
        fighterAId: "ftr_renato_moicano",
        fighterAName: "Renato Moicano",
        fighterBId: "ftr_chris_duncan",
        fighterBName: "Chris Duncan",
        weightClass: "Lightweight",
        isMainEvent: true,
        includesFollowedFighter: false,
      },
      {
        id: "bout_jandiroba_ricci",
        slotLabel: "Co-main",
        fighterAId: "ftr_virna_jandiroba",
        fighterAName: "Virna Jandiroba",
        fighterBId: "ftr_tabatha_ricci",
        fighterBName: "Tabatha Ricci",
        weightClass: "Strawweight",
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
      {
        rank: 1,
        fighterName: "Alex Pereira",
        organizationSlug: "ufc",
      },
      {
        rank: 2,
        fighterName: "Islam Makhachev",
        organizationSlug: "ufc",
      },
    ],
  },
];

export function getEventById(eventId: string): EventSummary | undefined {
  return sampleEvents.find((event) => event.id === eventId);
}

export function getFighterById(fighterId: string): FighterSummary | undefined {
  return sampleFighters.find((fighter) => fighter.id === fighterId);
}

export function getEventsForFighter(fighterId: string): EventSummary[] {
  return sampleEvents.filter((event) =>
    event.bouts.some(
      (bout) => bout.fighterAId === fighterId || bout.fighterBId === fighterId,
    ),
  );
}

export function getUfcFallbackEvents(): EventSummary[] {
  return sampleEvents.filter((event) => event.organizationSlug === "ufc");
}
