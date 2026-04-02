import type {
  EventSummary,
  FighterSummary,
  SourcePreview,
  SourceHealthStatus,
  SourceMode,
  UserProfile,
} from "../domain/models.js";
import {
  buildRuntimeEvents,
  buildRuntimeFightersFromEvents,
  buildRuntimeProfile,
  mergeExternalEvents,
} from "../domain/runtime-data.js";
import { filterUniqueBoxingEventsAgainstExisting } from "../domain/boxing-deduplication.js";
import type { EventSourcePreview } from "../sources/types.js";
import type { LeaderboardSourcePreview } from "../sources/types.js";
import {
  EVENT_SOURCE_DEFINITION_BY_KEY,
  HOME_EVENT_SOURCE_KEYS,
  LEADERBOARD_SOURCE_DEFINITION_BY_KEY,
  type EventSourceKey,
  type LeaderboardSourceKey,
} from "../sources/source-registry.js";
import type { UserStateStore } from "../store/user-state-store.js";
import { logError, logInfo, logWarn } from "../observability/logger.js";

const RUNTIME_DATA_CACHE_TTL_MS = 20 * 1000;
const RUNTIME_SOURCE_TIMEOUT_MS = 6 * 1000;
const MAX_RUNTIME_CACHE_ENTRIES = 25;
const SLOW_RUNTIME_RESOLUTION_MS = 1_500;
const SLOW_SOURCE_PREVIEW_LOAD_MS = 1_200;

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

type RuntimeCacheCounters = {
  hitCount: number;
  missCount: number;
  inflightReuseCount: number;
};

type SourceHealthSnapshot = {
  source: string;
  mode: SourceMode;
  healthStatus: SourceHealthStatus;
  itemCount: number;
  warningCount: number;
  fetchedAt: string;
  observedAt: string;
};

export type RuntimeObservabilitySnapshot = {
  runtimeSnapshotCache: RuntimeCacheCounters & {
    entryCount: number;
    inFlightCount: number;
  };
  sourcePreviewCache: RuntimeCacheCounters & {
    entryCount: number;
    inFlightCount: number;
  };
  sourceHealth: {
    sourceCount: number;
    degradedCount: number;
    fallbackCount: number;
    items: SourceHealthSnapshot[];
  };
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
  private readonly runtimeCacheCounters: RuntimeCacheCounters = {
    hitCount: 0,
    missCount: 0,
    inflightReuseCount: 0,
  };
  private readonly sourcePreviewCacheCounters: RuntimeCacheCounters = {
    hitCount: 0,
    missCount: 0,
    inflightReuseCount: 0,
  };
  private readonly sourceHealthBySource = new Map<string, SourceHealthSnapshot>();

  async resolveRuntimeData(state: Awaited<ReturnType<UserStateStore["read"]>>) {
    const cacheKey = buildRuntimeStateCacheKey(state);
    const cached = this.runtimeDataCache.get(cacheKey);

    this.pruneRuntimeDataCache();
    if (cached && cached.expiresAt > Date.now()) {
      this.runtimeCacheCounters.hitCount += 1;
      logInfo("runtime.cache_hit", {
        cache: "runtime_snapshot",
      });
      return cached.data;
    }

    const inFlight = this.runtimeDataInFlight.get(cacheKey);
    if (inFlight) {
      this.runtimeCacheCounters.inflightReuseCount += 1;
      logInfo("runtime.inflight_reused", {
        cache: "runtime_snapshot",
      });
      return inFlight;
    }

    this.runtimeCacheCounters.missCount += 1;
    logInfo("runtime.cache_miss", {
      cache: "runtime_snapshot",
    });

    const startedAt = Date.now();
    const pending = this.resolveRuntimeDataFresh(state)
      .then(({ data, timedOutSourceCount }) => {
        this.runtimeDataInFlight.delete(cacheKey);
        const durationMs = Date.now() - startedAt;
        if (timedOutSourceCount === 0) {
          this.runtimeDataCache.set(cacheKey, {
            expiresAt: Date.now() + RUNTIME_DATA_CACHE_TTL_MS,
            data,
          });
          this.pruneRuntimeDataCache();
        }
        if (durationMs >= SLOW_RUNTIME_RESOLUTION_MS) {
          logWarn("runtime.resolve_slow", {
            durationMs,
            timedOutSourceCount,
            eventCount: data.events.length,
            fighterCount: data.fighters.length,
          });
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

  async getCachedEventPreview(
    source: EventSourceKey,
    timezone: string,
    countryCode: string,
  ): Promise<EventSourcePreview> {
    const definition = EVENT_SOURCE_DEFINITION_BY_KEY.get(source);
    if (!definition) {
      throw new Error(`Unknown event source: ${source}`);
    }

    return this.loadCachedPreview(
      source,
      `${timezone}:${countryCode}`,
      definition.ttlMs,
      () =>
        definition.loader({
          timezone,
          selectedCountryCode: countryCode,
        }),
    );
  }

  async getCachedLeaderboardPreview(
    source: LeaderboardSourceKey,
    timezone: string,
    countryCode: string,
  ): Promise<LeaderboardSourcePreview> {
    const definition = LEADERBOARD_SOURCE_DEFINITION_BY_KEY.get(source);
    if (!definition) {
      throw new Error(`Unknown leaderboard source: ${source}`);
    }

    return this.loadCachedPreview(
      source,
      `${timezone}:${countryCode}`,
      definition.ttlMs,
      () =>
        definition.loader({
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
    const homeSourceDefinitions = HOME_EVENT_SOURCE_KEYS.map((key) => {
      const definition = EVENT_SOURCE_DEFINITION_BY_KEY.get(key);
      if (!definition) {
        throw new Error(`Missing home source definition for ${key}`);
      }
      return definition;
    });
    const previews = await Promise.all(
      homeSourceDefinitions.map((definition) =>
        this.loadHomePreviewWithTimeout({
          source: definition.key,
          officialUrl: definition.officialUrl,
          timezone: profile.timezone,
          countryCode: profile.viewingCountryCode,
          loader: () =>
            this.getCachedEventPreview(
              definition.key,
              profile.timezone,
              profile.viewingCountryCode,
            ),
        }),
      ),
    );

    for (const preview of previews) {
      this.recordSourceHealth(preview);
    }

    logSourcePreviewIssues(previews);

    const mergedEvents = homeSourceDefinitions.reduce((currentEvents, definition, index) => {
      const preview = previews[index];
      if (!preview) {
        return currentEvents;
      }

      const incomingItems =
        definition.mergeStrategy === "dedupe_boxing"
          ? filterUniqueBoxingEventsAgainstExisting(currentEvents, preview.items)
          : preview.items;

      return mergeExternalEvents(
        state,
        currentEvents,
        incomingItems,
        definition.key,
        profile,
      );
    }, baseEvents);
    const fighters = buildRuntimeFightersFromEvents(state, mergedEvents);

    return {
      data: {
        profile,
        fighters,
        events: mergedEvents,
      },
      timedOutSourceCount: previews.filter((preview) =>
        preview.warnings.some((warning) => warning.includes("timed out")),
      ).length,
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
      this.sourcePreviewCacheCounters.hitCount += 1;
      logInfo("source.preview_cache_hit", {
        source,
      });
      return cached.preview as T;
    }

    const inFlight = this.previewInFlight.get(source);
    if (inFlight && inFlight.cacheKey === cacheKey) {
      this.sourcePreviewCacheCounters.inflightReuseCount += 1;
      logInfo("source.preview_inflight_reused", {
        source,
      });
      return inFlight.promise as Promise<T>;
    }

    this.sourcePreviewCacheCounters.missCount += 1;
    logInfo("source.preview_cache_miss", {
      source,
    });

    const startedAt = Date.now();
    const pending = loader()
      .then((preview) => {
        this.previewInFlight.delete(source);
        this.previewCache.set(source, {
          cacheKey,
          expiresAt: Date.now() + ttlMs,
          preview,
        });
        this.recordSourceHealth(preview);
        const durationMs = Date.now() - startedAt;
        if (durationMs >= SLOW_SOURCE_PREVIEW_LOAD_MS) {
          logWarn("source.preview_load_slow", {
            source,
            durationMs,
            ttlMs,
          });
        }
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

  getObservabilitySnapshot(): RuntimeObservabilitySnapshot {
    const sourceHealthItems = [...this.sourceHealthBySource.values()].sort((left, right) =>
      left.source.localeCompare(right.source),
    );

    return {
      runtimeSnapshotCache: {
        ...this.runtimeCacheCounters,
        entryCount: this.runtimeDataCache.size,
        inFlightCount: this.runtimeDataInFlight.size,
      },
      sourcePreviewCache: {
        ...this.sourcePreviewCacheCounters,
        entryCount: this.previewCache.size,
        inFlightCount: this.previewInFlight.size,
      },
      sourceHealth: {
        sourceCount: sourceHealthItems.length,
        degradedCount: sourceHealthItems.filter((item) => item.healthStatus === "degraded")
          .length,
        fallbackCount: sourceHealthItems.filter((item) => item.mode === "fallback").length,
        items: sourceHealthItems,
      },
    };
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
        .catch((error) => {
          if (settled) {
            return;
          }
          settled = true;
          clearTimeout(timeoutId);
          logError("source.loader_failed", {
            source,
            timezone,
            countryCode,
            officialUrl,
            errorMessage: getErrorMessage(error),
          });
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

  private recordSourceHealth(preview: SourcePreview<unknown>): void {
    this.sourceHealthBySource.set(preview.source, {
      source: preview.source,
      mode: preview.mode,
      healthStatus: preview.health.status,
      itemCount: preview.itemCount,
      warningCount: preview.warnings.length,
      fetchedAt: preview.fetchedAt,
      observedAt: new Date().toISOString(),
    });
  }
}

function buildRuntimeStateCacheKey(
  state: Awaited<ReturnType<UserStateStore["read"]>>,
): string {
  return JSON.stringify({
    timezone: state.profile.timezone,
    viewingCountryCode: state.profile.viewingCountryCode,
    followedFighterIds: [...state.follows.fighterIds].sort(),
    followedEventIds: [...state.follows.eventIds].sort(),
  });
}

function logSourcePreviewIssues(previews: EventSourcePreview[]): void {
  for (const preview of previews) {
    const warningMessages = preview.warnings
      .filter((warning) => !warning.includes("disabled for route tests"))
      .slice(0, 3);
    const shouldWarn =
      preview.health.status === "degraded" ||
      (preview.mode === "fallback" && warningMessages.length > 0);

    if (!shouldWarn) {
      continue;
    }

    const payload = {
      source: preview.source,
      mode: preview.mode,
      healthStatus: preview.health.status,
      itemCount: preview.itemCount,
      parsedItemCount: preview.health.parsedItemCount,
      reportedItemCount: preview.health.reportedItemCount ?? null,
      checkedPageCount: preview.health.checkedPageCount,
      coverageGap: preview.health.coverageGap,
      warnings: warningMessages,
      fetchedAt: preview.fetchedAt,
    };

    logWarn("source.preview_issue", payload);
  }
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  return "Unknown source loader error";
}
