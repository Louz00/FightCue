import { loadEspnBoxingRankingsPreview } from "./boxing/espn-boxing-rankings-source.js";
import { loadEspnBoxingSchedulePreview } from "./boxing/espn-boxing-schedule-source.js";
import { loadRingBoxingRatingsPreview } from "./boxing/ring-boxing-ratings-source.js";
import { loadBoxxerEventsPreview } from "./boxxer/boxxer-events-source.js";
import { loadGloryEventsPreview } from "./glory/glory-events-source.js";
import { loadGoldenBoyEventsPreview } from "./golden-boy/golden-boy-events-source.js";
import { loadMatchroomEventsPreview } from "./matchroom/matchroom-events-source.js";
import { loadOneEventsPreview } from "./one/one-events-source.js";
import { loadPbcEventsPreview } from "./pbc/pbc-events-source.js";
import { loadQueensberryEventsPreview } from "./queensberry/queensberry-events-source.js";
import { loadTopRankEventsPreview } from "./top-rank/top-rank-events-source.js";
import type {
  EventSourcePreview,
  EventSourceQuery,
  LeaderboardSourcePreview,
  LeaderboardSourceQuery,
} from "./types.js";
import { loadUfcEventsPreview } from "./ufc/ufc-events-source.js";

export type EventSourceKey =
  | "ufc"
  | "glory"
  | "one"
  | "matchroom"
  | "queensberry"
  | "top_rank"
  | "pbc"
  | "golden_boy"
  | "boxxer"
  | "espn_boxing";

export type LeaderboardSourceKey =
  | "espn_boxing_rankings"
  | "ring_boxing_ratings";

export type EventMergeStrategy = "direct" | "dedupe_boxing";

export type EventSourceDefinition = {
  key: EventSourceKey;
  routePath: string;
  officialUrl: string;
  ttlMs: number;
  includeInHome: boolean;
  mergeStrategy: EventMergeStrategy;
  loader: (query: EventSourceQuery) => Promise<EventSourcePreview>;
};

export type LeaderboardSourceDefinition = {
  key: LeaderboardSourceKey;
  routePath: string;
  officialUrl: string;
  ttlMs: number;
  loader: (query: LeaderboardSourceQuery) => Promise<LeaderboardSourcePreview>;
};

export const EVENT_SOURCE_DEFINITIONS: EventSourceDefinition[] = [
  {
    key: "ufc",
    routePath: "/v1/sources/ufc/events",
    officialUrl: "https://www.ufc.com/events",
    ttlMs: 2 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "direct",
    loader: loadUfcEventsPreview,
  },
  {
    key: "glory",
    routePath: "/v1/sources/glory/events",
    officialUrl: "https://glorykickboxing.com/en/events",
    ttlMs: 2 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "direct",
    loader: loadGloryEventsPreview,
  },
  {
    key: "one",
    routePath: "/v1/sources/one/events",
    officialUrl: "https://www.onefc.com/events/",
    ttlMs: 5 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "direct",
    loader: loadOneEventsPreview,
  },
  {
    key: "matchroom",
    routePath: "/v1/sources/matchroom/events",
    officialUrl: "https://www.matchroomboxing.com/events/",
    ttlMs: 5 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "dedupe_boxing",
    loader: loadMatchroomEventsPreview,
  },
  {
    key: "queensberry",
    routePath: "/v1/sources/queensberry/events",
    officialUrl: "https://queensberry.co.uk/pages/events",
    ttlMs: 5 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "dedupe_boxing",
    loader: loadQueensberryEventsPreview,
  },
  {
    key: "top_rank",
    routePath: "/v1/sources/top-rank/events",
    officialUrl: "https://www.toprank.com/",
    ttlMs: 5 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "direct",
    loader: loadTopRankEventsPreview,
  },
  {
    key: "pbc",
    routePath: "/v1/sources/pbc/events",
    officialUrl: "https://www.premierboxingchampions.com/boxing-schedule",
    ttlMs: 5 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "dedupe_boxing",
    loader: loadPbcEventsPreview,
  },
  {
    key: "golden_boy",
    routePath: "/v1/sources/golden-boy/events",
    officialUrl: "https://www.goldenboy.com/events/",
    ttlMs: 5 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "dedupe_boxing",
    loader: loadGoldenBoyEventsPreview,
  },
  {
    key: "boxxer",
    routePath: "/v1/sources/boxxer/events",
    officialUrl: "https://www.boxxer.com/tickets/",
    ttlMs: 5 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "dedupe_boxing",
    loader: loadBoxxerEventsPreview,
  },
  {
    key: "espn_boxing",
    routePath: "/v1/sources/espn/boxing-schedule",
    officialUrl: "https://www.espn.com/boxing/story/_/id/12508267/boxing-schedule",
    ttlMs: 10 * 60 * 1000,
    includeInHome: true,
    mergeStrategy: "dedupe_boxing",
    loader: loadEspnBoxingSchedulePreview,
  },
];

export const HOME_EVENT_SOURCE_KEYS: EventSourceKey[] = [
  "ufc",
  "one",
  "glory",
  "top_rank",
  "pbc",
  "golden_boy",
  "queensberry",
  "matchroom",
  "boxxer",
  "espn_boxing",
];

export const LEADERBOARD_SOURCE_DEFINITIONS: LeaderboardSourceDefinition[] = [
  {
    key: "espn_boxing_rankings",
    routePath: "/v1/sources/espn/boxing-rankings",
    officialUrl:
      "https://www.espn.com/boxing/story/_/id/21675272/divisional-rankings-best-top-10-fighters-per-division",
    ttlMs: 30 * 60 * 1000,
    loader: loadEspnBoxingRankingsPreview,
  },
  {
    key: "ring_boxing_ratings",
    routePath: "/v1/sources/ring/boxing-ratings",
    officialUrl: "https://www.ringmagazine.com/",
    ttlMs: 30 * 60 * 1000,
    loader: loadRingBoxingRatingsPreview,
  },
];

export const EVENT_SOURCE_DEFINITION_BY_KEY = new Map(
  EVENT_SOURCE_DEFINITIONS.map((definition) => [definition.key, definition]),
);

export const LEADERBOARD_SOURCE_DEFINITION_BY_KEY = new Map(
  LEADERBOARD_SOURCE_DEFINITIONS.map((definition) => [definition.key, definition]),
);
