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
    id: "evt_glory_107",
    organizationSlug: "glory",
    organizationName: "GLORY",
    sport: "kickboxing",
    title: "GLORY 107",
    tagline: "A Rotterdam fight card anchored by a middleweight title clash.",
    locationLabel: "Rotterdam, Netherlands",
    venueLabel: "Rotterdam Ahoy",
    scheduledStartUtc: "2026-04-25T18:00:00Z",
    scheduledTimezone: "Europe/Amsterdam",
    localDateLabel: "Sat 25 Apr",
    localTimeLabel: "20:00",
    eventLocalTimeLabel: "Sat 25 Apr • 8:00 PM CEST",
    selectedCountryCode: "NL",
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Official GLORY schedule",
    officialUrl: "https://glorykickboxing.com/events/glory-107",
    watchProviders: [],
    bouts: [
      {
        id: "bout_wisse_kwasi",
        slotLabel: "Main event",
        fighterAId: "ftr_donovan_wisse",
        fighterAName: "Donovan Wisse",
        fighterBId: "ftr_michael_kwasi",
        fighterBName: "Michael Kwasi",
        weightClass: "Middleweight",
        isMainEvent: true,
        includesFollowedFighter: false,
      },
      {
        id: "bout_diaz_ouaadar",
        slotLabel: "Co-main",
        fighterAId: "ftr_sergio_diaz",
        fighterAName: "Sergio Diaz",
        fighterBId: "ftr_youssef_ouaadar",
        fighterBName: "Youssef Ouaadar",
        weightClass: "Featherweight",
        isMainEvent: false,
        includesFollowedFighter: false,
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
  createUfcLeaderboard(
    "lb_ufc_men_flyweight",
    "UFC men's flyweight",
    "men",
    "Flyweight",
    [
      createLeaderboardEntry(1, "ftr_alexandre_pantoja", "Alexandre Pantoja", "29-5-0", true),
      createLeaderboardEntry(2, "ftr_brandon_royval", "Brandon Royval", "17-7-0"),
      createLeaderboardEntry(3, "ftr_amir_albazi", "Amir Albazi", "17-1-0"),
      createLeaderboardEntry(4, "ftr_kai_kara_france", "Kai Kara-France", "25-11-0"),
      createLeaderboardEntry(5, "ftr_manuel_kape", "Manel Kape", "21-7-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_men_bantamweight",
    "UFC men's bantamweight",
    "men",
    "Bantamweight",
    [
      createLeaderboardEntry(1, "ftr_merab_dvalishvili", "Merab Dvalishvili", "20-4-0", true),
      createLeaderboardEntry(2, "ftr_sean_omalley", "Sean O'Malley", "18-2-0"),
      createLeaderboardEntry(3, "ftr_petr_yan", "Petr Yan", "18-5-0"),
      createLeaderboardEntry(4, "ftr_umar_nurmagomedov", "Umar Nurmagomedov", "18-0-0"),
      createLeaderboardEntry(5, "ftr_cory_sandhagen", "Cory Sandhagen", "18-5-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_men_featherweight",
    "UFC men's featherweight",
    "men",
    "Featherweight",
    [
      createLeaderboardEntry(1, "ftr_alexander_volkanovski", "Alexander Volkanovski", "27-4-0", true),
      createLeaderboardEntry(2, "ftr_max_holloway", "Max Holloway", "26-8-0"),
      createLeaderboardEntry(3, "ftr_ilia_topuria", "Ilia Topuria", "16-0-0"),
      createLeaderboardEntry(4, "ftr_brian_ortega", "Brian Ortega", "16-4-0"),
      createLeaderboardEntry(5, "ftr_diego_lopes", "Diego Lopes", "26-6-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_men_lightweight",
    "UFC men's lightweight",
    "men",
    "Lightweight",
    [
      createLeaderboardEntry(1, "ftr_islam_makhachev", "Islam Makhachev", "27-1-0", true),
      createLeaderboardEntry(2, "ftr_charles_oliveira", "Charles Oliveira", "35-10-0"),
      createLeaderboardEntry(3, "ftr_arman_tsarukyan", "Arman Tsarukyan", "22-3-0"),
      createLeaderboardEntry(4, "ftr_dustin_poirier", "Dustin Poirier", "30-9-0"),
      createLeaderboardEntry(5, "ftr_justin_gaethje", "Justin Gaethje", "26-5-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_men_welterweight",
    "UFC men's welterweight",
    "men",
    "Welterweight",
    [
      createLeaderboardEntry(1, "ftr_belal_muhammad", "Belal Muhammad", "24-3-0", true),
      createLeaderboardEntry(2, "ftr_shavkat_rakhmonov", "Shavkat Rakhmonov", "19-0-0"),
      createLeaderboardEntry(3, "ftr_leon_edwards", "Leon Edwards", "22-4-0"),
      createLeaderboardEntry(4, "ftr_kamaru_usman", "Kamaru Usman", "20-4-0"),
      createLeaderboardEntry(5, "ftr_jack_della_maddalena", "Jack Della Maddalena", "18-2-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_men_middleweight",
    "UFC men's middleweight",
    "men",
    "Middleweight",
    [
      createLeaderboardEntry(1, "ftr_dricus_du_plessis", "Dricus du Plessis", "23-2-0", true),
      createLeaderboardEntry(2, "ftr_sean_strickland", "Sean Strickland", "29-6-0"),
      createLeaderboardEntry(3, "ftr_israel_adesanya", "Israel Adesanya", "24-4-0"),
      createLeaderboardEntry(4, "ftr_khamzat_chimaev", "Khamzat Chimaev", "14-0-0"),
      createLeaderboardEntry(5, "ftr_nassourdine_imavov", "Nassourdine Imavov", "15-4-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_men_light_heavyweight",
    "UFC men's light heavyweight",
    "men",
    "Light Heavyweight",
    [
      createLeaderboardEntry(1, "ftr_alex_pereira", "Alex Pereira", "11-3-0", true),
      createLeaderboardEntry(2, "ftr_magomed_ankalaev", "Magomed Ankalaev", "21-1-1"),
      createLeaderboardEntry(3, "ftr_jiri_prochazka", "Jiri Prochazka", "31-5-1"),
      createLeaderboardEntry(4, "ftr_jan_blachowicz", "Jan Blachowicz", "29-10-1"),
      createLeaderboardEntry(5, "ftr_carlos_ulberg", "Carlos Ulberg", "13-1-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_men_heavyweight",
    "UFC men's heavyweight",
    "men",
    "Heavyweight",
    [
      createLeaderboardEntry(1, "ftr_jon_jones", "Jon Jones", "28-1-0", true),
      createLeaderboardEntry(2, "ftr_tom_aspinall", "Tom Aspinall", "15-3-0"),
      createLeaderboardEntry(3, "ftr_ciryl_gane", "Ciryl Gane", "12-2-0"),
      createLeaderboardEntry(4, "ftr_sergei_pavlovich", "Sergei Pavlovich", "19-3-0"),
      createLeaderboardEntry(5, "ftr_alexander_volkov", "Alexander Volkov", "38-10-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_women_strawweight",
    "UFC women's strawweight",
    "women",
    "Strawweight",
    [
      createLeaderboardEntry(1, "ftr_zhang_weili", "Zhang Weili", "25-3-0", true),
      createLeaderboardEntry(2, "ftr_virna_jandiroba", "Virna Jandiroba", "23-4-0"),
      createLeaderboardEntry(3, "ftr_tatiana_suarez", "Tatiana Suarez", "10-0-0"),
      createLeaderboardEntry(4, "ftr_tabatha_ricci", "Tabatha Ricci", "12-3-0"),
      createLeaderboardEntry(5, "ftr_yan_xiaonan", "Yan Xiaonan", "19-4-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_women_flyweight",
    "UFC women's flyweight",
    "women",
    "Flyweight",
    [
      createLeaderboardEntry(1, "ftr_valentina_shevchenko", "Valentina Shevchenko", "24-4-1", true),
      createLeaderboardEntry(2, "ftr_alexa_grasso", "Alexa Grasso", "16-4-1"),
      createLeaderboardEntry(3, "ftr_manon_fiorot", "Manon Fiorot", "12-1-0"),
      createLeaderboardEntry(4, "ftr_erin_blanchfield", "Erin Blanchfield", "13-2-0"),
      createLeaderboardEntry(5, "ftr_rose_namajunas", "Rose Namajunas", "13-7-0"),
    ],
  ),
  createUfcLeaderboard(
    "lb_ufc_women_bantamweight",
    "UFC women's bantamweight",
    "women",
    "Bantamweight",
    [
      createLeaderboardEntry(1, "ftr_julianna_pena", "Julianna Pena", "13-5-0", true),
      createLeaderboardEntry(2, "ftr_kayla_harrison", "Kayla Harrison", "18-1-0"),
      createLeaderboardEntry(3, "ftr_raquel_pennington", "Raquel Pennington", "16-10-0"),
      createLeaderboardEntry(4, "ftr_holly_holm", "Holly Holm", "15-7-0"),
      createLeaderboardEntry(5, "ftr_iren_aldana", "Irene Aldana", "15-8-0"),
    ],
  ),
];

function createUfcLeaderboard(
  id: string,
  title: string,
  gender: "men" | "women",
  weightClass: string,
  entries: LeaderboardSummary["entries"],
): LeaderboardSummary {
  return {
    id,
    title,
    organizationSlug: "ufc",
    organizationName: "UFC",
    sourceType: "official",
    gender,
    weightClass,
    sourceLabel: "Official UFC ranking layout preview",
    entries,
  };
}

function createLeaderboardEntry(
  rank: number,
  fighterId: string,
  fighterName: string,
  recordLabel: string,
  isChampion = false,
): LeaderboardSummary["entries"][number] {
  return {
    id: `entry_${fighterId}`,
    rank,
    fighterId,
    fighterName,
    organizationSlug: "ufc",
    recordLabel,
    isChampion,
  };
}

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

export function getGloryFallbackEvents(): EventSummary[] {
  return sampleEvents.filter((event) => event.organizationSlug === "glory");
}

export function getMatchroomFallbackEvents(): EventSummary[] {
  return sampleEvents.filter((event) => event.organizationSlug === "matchroom");
}

export function getQueensberryFallbackEvents(): EventSummary[] {
  return sampleEvents.filter((event) => event.organizationSlug === "queensberry");
}

export function getTopRankFallbackEvents(): EventSummary[] {
  return sampleEvents.filter((event) => event.organizationSlug === "top_rank");
}

export function getPbcFallbackEvents(): EventSummary[] {
  return sampleEvents.filter((event) => event.organizationSlug === "pbc");
}

export function getGoldenBoyFallbackEvents(): EventSummary[] {
  return sampleEvents.filter((event) => event.organizationSlug === "golden_boy");
}
