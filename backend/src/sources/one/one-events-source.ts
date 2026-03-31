import type {
  BoutSummary,
  EventSummary,
  WatchProviderSummary,
} from "../../domain/models.js";
import { formatForTimezone, normalizeTimeZone } from "../../domain/time.js";
import {
  absoluteUrl as sharedAbsoluteUrl,
  matchSingle as sharedMatchSingle,
  sanitizeText as sharedSanitizeText,
  toSlug as sharedToSlug,
} from "../parse-utils.js";
import { buildSourceHealth } from "../source-health.js";
import type { EventSourcePreview, EventSourceQuery } from "../types.js";

const ONE_EVENTS_URL = "https://www.onefc.com/events/";

export async function loadOneEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const response = await fetch(ONE_EVENTS_URL, {
      headers: {
        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) FightCue/0.1",
        accept: "text/html,application/xhtml+xml",
      },
    });

    if (!response.ok) {
      throw new Error(`ONE events page returned ${response.status}`);
    }

    const html = await response.text();
    const parsed = parseOneEventsHtml(html, query, fetchedAt);

    if (parsed.items.length === 0) {
      throw new Error("No ONE upcoming events were parsed");
    }

    const health = buildSourceHealth({
      mode: "live",
      parsedItemCount: parsed.items.length,
      reportedItemCount: parsed.reportedItemCount,
      checkedPageCount: 1,
    });

    return {
      source: "one",
      mode: "live",
      officialUrl: ONE_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: parsed.items.length,
      health,
      warnings: [
        "ONE event cards are parsed from the official ONE events page and may have limited bout detail until per-event parsing is expanded.",
      ],
      items: parsed.items,
    };
  } catch (error) {
    return {
      source: "one",
      mode: "fallback",
      officialUrl: ONE_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: 0,
      health: buildSourceHealth({
        mode: "fallback",
        parsedItemCount: 0,
        checkedPageCount: 0,
      }),
      warnings: [`Live ONE events unavailable: ${getErrorMessage(error)}`],
      items: [],
    };
  }
}

export function parseOneEventsHtml(
  html: string,
  query: EventSourceQuery,
  fetchedAt: string,
): {
  items: EventSummary[];
  reportedItemCount: number;
} {
  const blocks = [
    ...html.matchAll(
      /<div class="simple-post-card is-event is-image-zoom-area">([\s\S]*?)<\/div>\s*<\/div>\s*<\/div>/g,
    ),
  ];
  const items = blocks
    .map((match, index) =>
      parseOneEventBlock(match[1] ?? "", query, fetchedAt, index),
    )
    .filter((event): event is EventSummary => event != null);

  return {
    items,
    reportedItemCount: blocks.length,
  };
}

function parseOneEventBlock(
  blockHtml: string,
  query: EventSourceQuery,
  fetchedAt: string,
  index: number,
): EventSummary | null {
  const title = sanitizeText(
    matchSingle(blockHtml, /<h3>([^<]+)<\/h3>/i) ?? "",
  );
  const href = absoluteUrl(
    matchSingle(blockHtml, /<a class="title" href="([^"]+)"/i) ?? "",
  );
  const timestamp = Number(
    matchSingle(blockHtml, /data-timestamp="(\d+)"/i) ?? "",
  );
  const locationLabel = sanitizeText(
    matchSingle(blockHtml, /<div class="location">([^<]+)<\/div>/i) ?? "",
  );

  if (!title || !href || Number.isNaN(timestamp)) {
    return null;
  }

  const scheduledStartUtc = new Date(timestamp * 1000).toISOString();
  const localTime = formatForTimezone(
    new Date(scheduledStartUtc),
    normalizeTimeZone(query.timezone),
  );
  const mainBout = parseOneHeadlineBout(title);
  const watchProviders = buildWatchProviders(
    title,
    href,
    query.selectedCountryCode,
    fetchedAt,
  );

  return {
    id: `evt_one_${toSlug(href.split("/").filter(Boolean).pop() ?? `${title}_${index + 1}`)}`,
    organizationSlug: "one",
    organizationName: "ONE Championship",
    sport: title.toLowerCase().includes("muay thai") ||
            title.toLowerCase().includes("kickboxing")
        ? "kickboxing"
        : "mma",
    title,
    tagline: "Official ONE Championship event listing.",
    locationLabel: locationLabel || "Location TBA",
    venueLabel: extractVenueLabel(locationLabel),
    scheduledStartUtc,
    scheduledTimezone: "Asia/Bangkok",
    localDateLabel: localTime.localDateLabel,
    localTimeLabel: localTime.localTimeLabel,
    eventLocalTimeLabel: "Official ONE local schedule",
    selectedCountryCode: query.selectedCountryCode,
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Official ONE events page",
    officialUrl: href,
    watchProviders,
    bouts: mainBout == null ? [] : [mainBout],
  };
}

function parseOneHeadlineBout(title: string): BoutSummary | null {
  const parts = title.split(":");
  const headline = (parts.length > 1 ? parts.slice(1).join(":").trim() : title).replace(
    /\s+on\s+prime\s+video$/i,
    "",
  );
  const matchup = headline.match(/^(.+?)\s+vs\.?\s+(.+)$/i);
  if (!matchup) {
    return null;
  }

  const fighterAName = sanitizeText(matchup[1] ?? "");
  const fighterBName = sanitizeText(matchup[2] ?? "");

  if (!fighterAName || !fighterBName) {
    return null;
  }

  return {
    id: `bout_${toSlug(fighterAName)}_${toSlug(fighterBName)}_1`,
    slotLabel: "Main event",
    fighterAId: `ftr_${toSlug(fighterAName)}`,
    fighterAName,
    fighterBId: `ftr_${toSlug(fighterBName)}`,
    fighterBName,
    isMainEvent: true,
    includesFollowedFighter: false,
  };
}

function buildWatchProviders(
  title: string,
  officialUrl: string,
  countryCode: string,
  fetchedAt: string,
): WatchProviderSummary[] {
  const normalizedTitle = title.toLowerCase();
  const providers = new Map<string, WatchProviderSummary>();

  if (normalizedTitle.includes("prime video")) {
    providers.set("Prime Video", {
      label: "Prime Video",
      kind: "streaming",
      countryCode,
      confidence: "likely",
      lastVerifiedAt: fetchedAt,
      providerUrl: officialUrl,
    });
  }

  providers.set("ONE event page", {
    label: "ONE event page",
    kind: "streaming",
    countryCode,
    confidence: "unknown",
    lastVerifiedAt: fetchedAt,
    providerUrl: officialUrl,
  });

  return [...providers.values()];
}

function extractVenueLabel(locationLabel: string): string {
  return sanitizeText(locationLabel.split(",")[0] ?? "") || "Venue TBA";
}

function absoluteUrl(value: string): string {
  return sharedAbsoluteUrl(value, ONE_EVENTS_URL);
}

function matchSingle(input: string, pattern: RegExp): string | undefined {
  return sharedMatchSingle(input, pattern);
}

function sanitizeText(input: string): string {
  return sharedSanitizeText(input);
}

function toSlug(input: string): string {
  return sharedToSlug(input);
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  return "Unknown ONE events error";
}
