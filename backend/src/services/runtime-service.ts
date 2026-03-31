import type {
  EventSummary,
  FighterSummary,
  SourcePreview,
  UserProfile,
} from "../domain/models.js";
import {
  buildRuntimeEvents,
  buildRuntimeFightersFromEvents,
  buildRuntimeProfile,
  mergeExternalEvents,
} from "../domain/runtime-data.js";
import { filterUniqueBoxingEventsAgainstExisting } from "../domain/boxing-deduplication.js";
import { loadEspnBoxingRankingsPreview } from "../sources/boxing/espn-boxing-rankings-source.js";
import { loadEspnBoxingSchedulePreview } from "../sources/boxing/espn-boxing-schedule-source.js";
import { loadRingBoxingRatingsPreview } from "../sources/boxing/ring-boxing-ratings-source.js";
import { loadBoxxerEventsPreview } from "../sources/boxxer/boxxer-events-source.js";
import { loadGoldenBoyEventsPreview } from "../sources/golden-boy/golden-boy-events-source.js";
import { loadGloryEventsPreview } from "../sources/glory/glory-events-source.js";
import { loadMatchroomEventsPreview } from "../sources/matchroom/matchroom-events-source.js";
import { loadPbcEventsPreview } from "../sources/pbc/pbc-events-source.js";
import { loadQueensberryEventsPreview } from "../sources/queensberry/queensberry-events-source.js";
import { loadTopRankEventsPreview } from "../sources/top-rank/top-rank-events-source.js";
import { loadUfcEventsPreview } from "../sources/ufc/ufc-events-source.js";
import type { EventSourcePreview } from "../sources/types.js";
import type { UserStateStore } from "../store/user-state-store.js";

const UFC_SOURCE_CACHE_TTL_MS = 2 * 60 * 1000;
const GLORY_SOURCE_CACHE_TTL_MS = 2 * 60 * 1000;
const MATCHROOM_SOURCE_CACHE_TTL_MS = 5 * 60 * 1000;
const QUEENSBERRY_SOURCE_CACHE_TTL_MS = 5 * 60 * 1000;
const TOP_RANK_SOURCE_CACHE_TTL_MS = 5 * 60 * 1000;
const PBC_SOURCE_CACHE_TTL_MS = 5 * 60 * 1000;
const GOLDEN_BOY_SOURCE_CACHE_TTL_MS = 5 * 60 * 1000;
const BOXXER_SOURCE_CACHE_TTL_MS = 5 * 60 * 1000;
const ESPN_BOXING_SOURCE_CACHE_TTL_MS = 10 * 60 * 1000;
const ESPN_BOXING_RANKINGS_SOURCE_CACHE_TTL_MS = 30 * 60 * 1000;
const RING_BOXING_RATINGS_SOURCE_CACHE_TTL_MS = 30 * 60 * 1000;
const RUNTIME_DATA_CACHE_TTL_MS = 20 * 1000;
const RUNTIME_SOURCE_TIMEOUT_MS = 6 * 1000;
const MAX_RUNTIME_CACHE_ENTRIES = 25;

type ResolvedRuntimeData = {
  profile: UserProfile;
  fighters: FighterSummary[];
  events: EventSummary[];
};

type PreviewCacheEntry = {
  cacheKey: string;
  expiresAt: number;
  preview: unknown;
};

type PreviewInFlightEntry = {
  cacheKey: string;
  promise: Promise<unknown>;
};

type TimedRuntimeResolution = {
  data: ResolvedRuntimeData;
  timedOutSourceCount: number;
};

export class RuntimeService {
  constructor(private readonly stateStore: UserStateStore) {}

  private readonly previewCache = new Map<string, PreviewCacheEntry>();
  private readonly previewInFlight = new Map<string, PreviewInFlightEntry>();
  private readonly runtimeDataCache = new Map<
    string,
    {
      expiresAt: number;
      data: ResolvedRuntimeData;
    }
  >();
  private readonly runtimeDataInFlight = new Map<string, Promise<ResolvedRuntimeData>>();

  async resolveRuntimeData(state: Awaited<ReturnType<UserStateStore["read"]>>) {
    const cacheKey = JSON.stringify(state);
    const cached = this.runtimeDataCache.get(cacheKey);

    this.pruneRuntimeDataCache();
    if (cached && cached.expiresAt > Date.now()) {
      return cached.data;
    }

    const inFlight = this.runtimeDataInFlight.get(cacheKey);
    if (inFlight) {
      return inFlight;
    }

    const pending = this.resolveRuntimeDataFresh(state)
      .then(({ data, timedOutSourceCount }) => {
        this.runtimeDataInFlight.delete(cacheKey);
        if (timedOutSourceCount === 0) {
          this.runtimeDataCache.set(cacheKey, {
            expiresAt: Date.now() + RUNTIME_DATA_CACHE_TTL_MS,
            data,
          });
          this.pruneRuntimeDataCache();
        }
        return data;
      })
      .catch((error) => {
        this.runtimeDataInFlight.delete(cacheKey);
        throw error;
      });

    this.runtimeDataInFlight.set(cacheKey, pending);
    return pending;
  }

  async resolveRuntimeDataForCurrentState() {
    return this.resolveRuntimeData(await this.stateStore.read());
  }

  async resolveRuntimeDataForDevice(deviceId: string) {
    return this.resolveRuntimeData(await this.stateStore.read(deviceId));
  }

  async getCachedUfcPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "ufc",
      `${timezone}:${countryCode}`,
      UFC_SOURCE_CACHE_TTL_MS,
      () =>
        loadUfcEventsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedGloryPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "glory",
      `${timezone}:${countryCode}`,
      GLORY_SOURCE_CACHE_TTL_MS,
      () =>
        loadGloryEventsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedMatchroomPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "matchroom",
      `${timezone}:${countryCode}`,
      MATCHROOM_SOURCE_CACHE_TTL_MS,
      () =>
        loadMatchroomEventsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedPbcPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "pbc",
      `${timezone}:${countryCode}`,
      PBC_SOURCE_CACHE_TTL_MS,
      () =>
        loadPbcEventsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedGoldenBoyPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "golden_boy",
      `${timezone}:${countryCode}`,
      GOLDEN_BOY_SOURCE_CACHE_TTL_MS,
      () =>
        loadGoldenBoyEventsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedBoxxerPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "boxxer",
      `${timezone}:${countryCode}`,
      BOXXER_SOURCE_CACHE_TTL_MS,
      () =>
        loadBoxxerEventsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedQueensberryPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "queensberry",
      `${timezone}:${countryCode}`,
      QUEENSBERRY_SOURCE_CACHE_TTL_MS,
      () =>
        loadQueensberryEventsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedTopRankPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "top_rank",
      `${timezone}:${countryCode}`,
      TOP_RANK_SOURCE_CACHE_TTL_MS,
      () =>
        loadTopRankEventsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedEspnBoxingPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "espn_boxing",
      `${timezone}:${countryCode}`,
      ESPN_BOXING_SOURCE_CACHE_TTL_MS,
      () =>
        loadEspnBoxingSchedulePreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedEspnBoxingRankingsPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "espn_boxing_rankings",
      `${timezone}:${countryCode}`,
      ESPN_BOXING_RANKINGS_SOURCE_CACHE_TTL_MS,
      () =>
        loadEspnBoxingRankingsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedRingBoxingRatingsPreview(timezone: string, countryCode: string) {
    return this.loadCachedPreview(
      "ring_boxing_ratings",
      `${timezone}:${countryCode}`,
      RING_BOXING_RATINGS_SOURCE_CACHE_TTL_MS,
      () =>
        loadRingBoxingRatingsPreview({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  private async resolveRuntimeDataFresh(
    state: Awaited<ReturnType<UserStateStore["read"]>>,
  ): Promise<TimedRuntimeResolution> {
    const profile = buildRuntimeProfile(state);
    const baseEvents = buildRuntimeEvents(state, profile);
    const [
      ufcPreview,
      gloryPreview,
      matchroomPreview,
      queensberryPreview,
      topRankPreview,
      pbcPreview,
      goldenBoyPreview,
      boxxerPreview,
      espnBoxingPreview,
    ] = await Promise.all([
      this.loadHomePreviewWithTimeout({
        source: "ufc",
        officialUrl: "https://www.ufc.com/events",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedUfcPreview(profile.timezone, profile.viewingCountryCode),
      }),
      this.loadHomePreviewWithTimeout({
        source: "glory",
        officialUrl: "https://glorykickboxing.com/en/events",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedGloryPreview(profile.timezone, profile.viewingCountryCode),
      }),
      this.loadHomePreviewWithTimeout({
        source: "matchroom",
        officialUrl: "https://www.matchroomboxing.com/events/",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedMatchroomPreview(
            profile.timezone,
            profile.viewingCountryCode,
          ),
      }),
      this.loadHomePreviewWithTimeout({
        source: "queensberry",
        officialUrl: "https://queensberry.co.uk/pages/events",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedQueensberryPreview(
            profile.timezone,
            profile.viewingCountryCode,
          ),
      }),
      this.loadHomePreviewWithTimeout({
        source: "top_rank",
        officialUrl: "https://www.toprank.com/",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedTopRankPreview(profile.timezone, profile.viewingCountryCode),
      }),
      this.loadHomePreviewWithTimeout({
        source: "pbc",
        officialUrl: "https://www.premierboxingchampions.com/boxing-schedule",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedPbcPreview(profile.timezone, profile.viewingCountryCode),
      }),
      this.loadHomePreviewWithTimeout({
        source: "golden_boy",
        officialUrl: "https://www.goldenboy.com/events/",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedGoldenBoyPreview(
            profile.timezone,
            profile.viewingCountryCode,
          ),
      }),
      this.loadHomePreviewWithTimeout({
        source: "boxxer",
        officialUrl: "https://www.boxxer.com/tickets/",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedBoxxerPreview(profile.timezone, profile.viewingCountryCode),
      }),
      this.loadHomePreviewWithTimeout({
        source: "espn_boxing",
        officialUrl: "https://www.espn.com/boxing/story/_/id/12508267/boxing-schedule",
        timezone: profile.timezone,
        countryCode: profile.viewingCountryCode,
        loader: () =>
          this.getCachedEspnBoxingPreview(
            profile.timezone,
            profile.viewingCountryCode,
          ),
      }),
    ]);

    const withUfcEvents = mergeExternalEvents(
      state,
      baseEvents,
      ufcPreview.items,
      "ufc",
      profile,
    );
    const withGloryEvents = mergeExternalEvents(
      state,
      withUfcEvents,
      gloryPreview.items,
      "glory",
      profile,
    );
    const withTopRankEvents = mergeExternalEvents(
      state,
      withGloryEvents,
      topRankPreview.items,
      "top_rank",
      profile,
    );
    const withPbcEvents = mergeExternalEvents(
      state,
      withTopRankEvents,
      filterUniqueBoxingEventsAgainstExisting(withTopRankEvents, pbcPreview.items),
      "pbc",
      profile,
    );
    const withGoldenBoyEvents = mergeExternalEvents(
      state,
      withPbcEvents,
      filterUniqueBoxingEventsAgainstExisting(withPbcEvents, goldenBoyPreview.items),
      "golden_boy",
      profile,
    );
    const withQueensberryEvents = mergeExternalEvents(
      state,
      withGoldenBoyEvents,
      filterUniqueBoxingEventsAgainstExisting(
        withGoldenBoyEvents,
        queensberryPreview.items,
      ),
      "queensberry",
      profile,
    );
    const withMatchroomEvents = mergeExternalEvents(
      state,
      withQueensberryEvents,
      filterUniqueBoxingEventsAgainstExisting(
        withQueensberryEvents,
        matchroomPreview.items,
      ),
      "matchroom",
      profile,
    );
    const withBoxxerEvents = mergeExternalEvents(
      state,
      withMatchroomEvents,
      filterUniqueBoxingEventsAgainstExisting(withMatchroomEvents, boxxerPreview.items),
      "boxxer",
      profile,
    );
    const withEspnBoxingEvents = mergeExternalEvents(
      state,
      withBoxxerEvents,
      filterUniqueBoxingEventsAgainstExisting(
        withBoxxerEvents,
        espnBoxingPreview.items,
      ),
      "espn_boxing",
      profile,
    );
    const fighters = buildRuntimeFightersFromEvents(state, withEspnBoxingEvents);

    return {
      data: {
        profile,
        fighters,
        events: withEspnBoxingEvents,
      },
      timedOutSourceCount: [
        ufcPreview,
        gloryPreview,
        matchroomPreview,
        queensberryPreview,
        topRankPreview,
        pbcPreview,
        goldenBoyPreview,
        boxxerPreview,
        espnBoxingPreview,
      ].filter((preview) => preview.warnings.some((warning) => warning.includes("timed out"))).length,
    };
  }

  private async loadCachedPreview<T extends SourcePreview<unknown>>(
    source: string,
    cacheKey: string,
    ttlMs: number,
    loader: () => Promise<T>,
  ): Promise<T> {
    this.prunePreviewCache();

    const cached = this.previewCache.get(source);
    if (cached && cached.cacheKey === cacheKey && cached.expiresAt > Date.now()) {
      return cached.preview as T;
    }

    const inFlight = this.previewInFlight.get(source);
    if (inFlight && inFlight.cacheKey === cacheKey) {
      return inFlight.promise as Promise<T>;
    }

    const pending = loader()
      .then((preview) => {
        this.previewInFlight.delete(source);
        this.previewCache.set(source, {
          cacheKey,
          expiresAt: Date.now() + ttlMs,
          preview,
        });
        return preview;
      })
      .catch((error) => {
        this.previewInFlight.delete(source);
        throw error;
      });

    this.previewInFlight.set(source, {
      cacheKey,
      promise: pending,
    });

    return pending;
  }

  private prunePreviewCache() {
    const now = Date.now();

    for (const [source, entry] of this.previewCache.entries()) {
      if (entry.expiresAt <= now) {
        this.previewCache.delete(source);
      }
    }
  }

  private pruneRuntimeDataCache() {
    const now = Date.now();

    for (const [cacheKey, entry] of this.runtimeDataCache.entries()) {
      if (entry.expiresAt <= now) {
        this.runtimeDataCache.delete(cacheKey);
      }
    }

    while (this.runtimeDataCache.size > MAX_RUNTIME_CACHE_ENTRIES) {
      const oldestKey = this.runtimeDataCache.keys().next().value;
      if (!oldestKey) {
        break;
      }
      this.runtimeDataCache.delete(oldestKey);
    }
  }

  private async loadHomePreviewWithTimeout<T extends EventSourcePreview>({
    source,
    officialUrl,
    timezone,
    countryCode,
    loader,
  }: {
    source: string;
    officialUrl: string;
    timezone: string;
    countryCode: string;
    loader: () => Promise<T>;
  }): Promise<T> {
    return new Promise<T>((resolve) => {
      let settled = false;
      const timeoutId = setTimeout(() => {
        if (settled) {
          return;
        }
        settled = true;
        resolve(
          this.buildTimedOutPreview({
            source,
            officialUrl,
            timezone,
            countryCode,
          }) as T,
        );
      }, RUNTIME_SOURCE_TIMEOUT_MS);

      loader()
        .then((preview) => {
          if (settled) {
            return;
          }
          settled = true;
          clearTimeout(timeoutId);
          resolve(preview);
        })
        .catch(() => {
          if (settled) {
            return;
          }
          settled = true;
          clearTimeout(timeoutId);
          resolve(
            this.buildTimedOutPreview({
              source,
              officialUrl,
              timezone,
              countryCode,
            }) as T,
          );
        });
    });
  }

  private buildTimedOutPreview({
    source,
    officialUrl,
    timezone,
    countryCode,
  }: {
    source: string;
    officialUrl: string;
    timezone: string;
    countryCode: string;
  }): EventSourcePreview {
    return {
      source,
      mode: "fallback",
      officialUrl,
      timezone,
      selectedCountryCode: countryCode,
      fetchedAt: new Date().toISOString(),
      itemCount: 0,
      health: {
        status: "fallback",
        parsedItemCount: 0,
        checkedPageCount: 0,
        coverageGap: 0,
      },
      warnings: [
        `Home runtime timed out after ${RUNTIME_SOURCE_TIMEOUT_MS}ms while waiting for ${source}.`,
      ],
      items: [],
    };
  }
}
