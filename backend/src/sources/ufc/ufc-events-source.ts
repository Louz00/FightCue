import {
  getUfcFallbackEvents,
} from "../../domain/mock-data.js";
import type {
  BoutSummary,
  EventSummary,
  WatchProviderSummary,
} from "../../domain/models.js";
import { formatForTimezone, normalizeTimeZone } from "../../domain/time.js";
import { buildSourceHealth } from "../source-health.js";
import type { EventSourcePreview, EventSourceQuery } from "../types.js";
import { loadEspnUfcUpcomingSchedule } from "./espn-ufc-schedule-source.js";
import { buildEspnValidationWarnings } from "./ufc-secondary-validation.js";

const OFFICIAL_UFC_EVENTS_URL = "https://www.ufc.com/events";
const UPCOMING_MARKER = 'id="events-list-upcoming"';
const ROW_MARKER = '<div class="l-listing__item views-row">';
const MAX_UPCOMING_PAGES = 4;

export async function loadUfcEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const preview = await loadAllUpcomingEvents(query, fetchedAt);
    const items = preview.items;

    if (items.length == 0) {
      throw new Error("No UFC upcoming events were parsed");
    }

    const health = buildSourceHealth({
      mode: "live",
      parsedItemCount: items.length,
      reportedItemCount: preview.reportedUpcomingCount,
      checkedPageCount: preview.checkedPageCount,
    });
    const warnings = [
      "Watch provider coverage is using the official UFC page and may still vary by country in this pilot.",
    ];
    if (health.status == "degraded" && preview.reportedUpcomingCount != null) {
      warnings.push(
        `UFC source coverage is below the official upcoming count (${items.length}/${preview.reportedUpcomingCount}).`,
      );
    }
    try {
      const espnUpcomingEvents = await loadEspnUfcUpcomingSchedule();
      warnings.push(...buildEspnValidationWarnings(items, espnUpcomingEvents));
    } catch {
      warnings.push(
        "Secondary UFC validation via ESPN schedule was unavailable for this refresh.",
      );
    }

    return {
      source: "ufc",
      mode: "live",
      officialUrl: OFFICIAL_UFC_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: items.length,
      health,
      warnings,
      items,
    };
  } catch (error) {
    const fallbackItems = getUfcFallbackEvents().map((event) =>
      reformatEventForQuery(event, query),
    );
    const health = buildSourceHealth({
      mode: "fallback",
      parsedItemCount: fallbackItems.length,
      checkedPageCount: 0,
    });

    return {
      source: "ufc",
      mode: "fallback",
      officialUrl: OFFICIAL_UFC_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: fallbackItems.length,
      health,
      warnings: [
        `Live UFC source unavailable, using curated fallback data: ${getErrorMessage(error)}`,
      ],
      items: fallbackItems,
    };
  }
}

async function loadAllUpcomingEvents(
  query: EventSourceQuery,
  fetchedAt: string,
): Promise<{
  items: EventSummary[];
  checkedPageCount: number;
  reportedUpcomingCount?: number;
}> {
  const collectedEvents: EventSummary[] = [];
  const seenEventUrls = new Set<string>();
  const visitedPages = new Set<string>();
  let nextPageUrl: string | undefined = OFFICIAL_UFC_EVENTS_URL;
  let pageCount = 0;
  let reportedUpcomingCount: number | undefined;

  while (nextPageUrl && pageCount < MAX_UPCOMING_PAGES) {
    if (visitedPages.has(nextPageUrl)) {
      break;
    }

    visitedPages.add(nextPageUrl);
    pageCount += 1;

    const html = await fetchUfcPageHtml(nextPageUrl);
    const upcomingSection = extractUpcomingSectionHtml(html);

    if (!upcomingSection) {
      break;
    }
    reportedUpcomingCount ??= extractReportedUpcomingCount(upcomingSection);

    const pageItems = parseUfcUpcomingSection(upcomingSection, query, fetchedAt);

    if (pageItems.length === 0) {
      break;
    }

    for (const item of pageItems) {
      const eventKey = item.officialUrl ?? item.title;
      if (seenEventUrls.has(eventKey)) {
        continue;
      }

      seenEventUrls.add(eventKey);
      collectedEvents.push(item);
    }

    nextPageUrl = findNextPageUrl(upcomingSection);
  }

  return {
    items: collectedEvents,
    checkedPageCount: pageCount,
    reportedUpcomingCount,
  };
}

async function fetchUfcPageHtml(url: string): Promise<string> {
  const response = await fetch(url, {
    headers: {
      "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
    },
  });

  if (!response.ok) {
    throw new Error(`UFC source returned ${response.status}`);
  }

  return response.text();
}

function extractUpcomingSectionHtml(
  html: string,
): string | undefined {
  const upcomingIndex = html.indexOf(UPCOMING_MARKER);
  if (upcomingIndex < 0) {
    return undefined;
  }

  const nextDetailsIndex = html.indexOf("<details", upcomingIndex + UPCOMING_MARKER.length);
  return nextDetailsIndex >= 0
    ? html.slice(upcomingIndex, nextDetailsIndex)
    : html.slice(upcomingIndex);
}

function parseUfcUpcomingSection(
  upcomingSection: string,
  query: EventSourceQuery,
  fetchedAt: string,
): EventSummary[] {
  return upcomingSection
    .split(ROW_MARKER)
    .slice(1)
    .map((rowHtml, index) => parseUfcEventRow(rowHtml, query, fetchedAt, index))
    .filter((event): event is EventSummary => event != null);
}

function extractReportedUpcomingCount(upcomingSection: string): number | undefined {
  const match = upcomingSection.match(/<div class="althelete-total">(\d+)\s+Events<\/div>/i);
  const parsed = Number(match?.[1]);
  return Number.isFinite(parsed) ? parsed : undefined;
}

function findNextPageUrl(upcomingSection: string): string | undefined {
  const nextPageMatch = upcomingSection.match(
    /<a class="button" href="([^"]+)" title="Load more items" rel="next">Load More<\/a>/,
  );

  if (!nextPageMatch) {
    return undefined;
  }

  return absoluteUrl(nextPageMatch[1]);
}

function parseUfcEventRow(
  rowHtml: string,
  query: EventSourceQuery,
  fetchedAt: string,
  index: number,
): EventSummary | null {
  const headlineMatch = rowHtml.match(
    /c-card-event--result__headline"><a href="([^"]+)">([^<]+)<\/a>/,
  );
  const timestampMatch = rowHtml.match(/data-main-card-timestamp="(\d+)"/);

  if (!headlineMatch || !timestampMatch) {
    return null;
  }

  const eventPath = headlineMatch[1];
  const eventTitle = sanitizeText(headlineMatch[2]);
  const scheduledStart = new Date(Number(timestampMatch[1]) * 1000);
  const timezone = normalizeTimeZone(query.timezone);
  const sourceLocalLabel = sanitizeText(
    rowHtml.match(/data-main-card="([^"]+)"/)?.[1] ?? "",
  );
  const venueLabel = sanitizeText(
    rowHtml.match(
      /field--name-taxonomy-term-title[\s\S]*?<h5>\s*([\s\S]*?)\s*<\/h5>/,
    )?.[1] ?? "Venue TBA",
  );
  const locationLabel = parseAddressLabel(
    rowHtml.match(/<p class="address"[^>]*>([\s\S]*?)<\/p>/)?.[1] ?? "",
  );
  const watchProviders = parseWatchProviders(
    rowHtml,
    query.selectedCountryCode,
    fetchedAt,
  );
  const bouts = parseBouts(rowHtml);
  const slug = toSlug(eventPath.split("/").filter(Boolean).pop() ?? `ufc-${index + 1}`);
  const { localDateLabel, localTimeLabel } = formatForTimezone(
    scheduledStart,
    timezone,
  );

  return {
    id: `evt_ufc_${slug}`,
    organizationSlug: "ufc",
    organizationName: "UFC",
    sport: "mma",
    title: eventTitle,
    tagline: buildEventTagline(eventTitle, locationLabel),
    locationLabel: locationLabel || "Location TBA",
    venueLabel,
    scheduledStartUtc: scheduledStart.toISOString(),
    scheduledTimezone: extractSourceTimezone(sourceLocalLabel),
    localDateLabel,
    localTimeLabel,
    eventLocalTimeLabel: sourceLocalLabel || "Official UFC local time",
    selectedCountryCode: query.selectedCountryCode,
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Official UFC events page",
    officialUrl: absoluteUrl(eventPath),
    watchProviders,
    bouts,
  };
}

function parseBouts(rowHtml: string): BoutSummary[] {
  const boutRegex =
    /data-fight-card-name="([^"]+)"[^>]*data-fight-label="([^"]+)"/g;
  const bouts: BoutSummary[] = [];
  let match: RegExpExecArray | null;

  while ((match = boutRegex.exec(rowHtml)) !== null) {
    const cardName = sanitizeText(match[1]);
    const label = sanitizeText(match[2]);
    const fighters = label.split(/\s+vs\s+/i);

    if (fighters.length !== 2) {
      continue;
    }

    const fighterAName = fighters[0];
    const fighterBName = fighters[1];
    const slotLabel =
      bouts.length === 0
        ? "Main event"
        : bouts.length === 1 && cardName.toLowerCase() === "main card"
          ? "Co-main"
          : normalizeCardLabel(cardName);

    bouts.push({
      id: `bout_${toSlug(fighterAName)}_${toSlug(fighterBName)}_${bouts.length + 1}`,
      slotLabel,
      fighterAId: `ftr_${toSlug(fighterAName)}`,
      fighterAName,
      fighterBId: `ftr_${toSlug(fighterBName)}`,
      fighterBName,
      isMainEvent: bouts.length === 0,
      includesFollowedFighter: false,
    });
  }

  return bouts;
}

function parseWatchProviders(
  rowHtml: string,
  selectedCountryCode: string,
  fetchedAt: string,
): WatchProviderSummary[] {
  const providerRegex = /href="([^"]+)"[^>]*>Watch on ([^<]+)<\/a>/g;
  const providers = new Map<string, WatchProviderSummary>();
  let match: RegExpExecArray | null;

  while ((match = providerRegex.exec(rowHtml)) !== null) {
    const providerUrl = match[1];
    const label = sanitizeText(match[2]);

    providers.set(label, {
      label,
      kind: "streaming",
      countryCode: selectedCountryCode,
      confidence: "confirmed",
      lastVerifiedAt: fetchedAt,
      providerUrl: absoluteUrl(providerUrl),
    });
  }

  if (providers.size > 0) {
    return [...providers.values()];
  }

  return [
    {
      label: "UFC Fight Pass",
      kind: "streaming",
      countryCode: selectedCountryCode,
      confidence: "unknown",
      lastVerifiedAt: fetchedAt,
      providerUrl: "https://www.ufcfightpass.com",
    },
  ];
}

function buildEventTagline(title: string, locationLabel: string): string {
  if (locationLabel.length > 0) {
    return `Official UFC card tracked from ${locationLabel} for the first FightCue source pilot.`;
  }

  return `Official UFC card tracked directly from the UFC schedule for the first FightCue source pilot.`;
}

function parseAddressLabel(addressHtml: string): string {
  if (addressHtml.length === 0) {
    return "";
  }

  return sanitizeText(
    addressHtml
      .replace(/<br\s*\/?>/gi, ", ")
      .replace(/<\/span>\s*,\s*<span/gi, "</span>, <span"),
  );
}

function normalizeCardLabel(cardName: string): string {
  if (cardName.toLowerCase() === "prelims") {
    return "Prelims";
  }

  if (cardName.toLowerCase() === "main card") {
    return "Main Card";
  }

  if (cardName.toLowerCase() === "none") {
    return "Featured bout";
  }

  return cardName;
}

function extractSourceTimezone(sourceLocalLabel: string): string {
  const match = sourceLocalLabel.match(/([A-Z]{2,4})$/);
  return match?.[1] ?? "UTC";
}

function absoluteUrl(pathOrUrl: string): string {
  if (pathOrUrl.startsWith("http://") || pathOrUrl.startsWith("https://")) {
    return pathOrUrl;
  }

  return new URL(pathOrUrl, OFFICIAL_UFC_EVENTS_URL).toString();
}

function sanitizeText(input: string): string {
  return decodeHtmlEntities(stripTags(input))
    .replace(/\s+/g, " ")
    .replace(/\s+,/g, ",")
    .trim();
}

function stripTags(input: string): string {
  return input.replace(/<[^>]+>/g, " ");
}

function decodeHtmlEntities(input: string): string {
  return input
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#039;/g, "'")
    .replace(/&rsquo;/g, "'")
    .replace(/&nbsp;/g, " ");
}

function toSlug(input: string): string {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  return "Unknown source error";
}

function reformatEventForQuery(
  event: EventSummary,
  query: EventSourceQuery,
): EventSummary {
  const timezone = normalizeTimeZone(query.timezone);
  const { localDateLabel, localTimeLabel } = formatForTimezone(
    new Date(event.scheduledStartUtc),
    timezone,
  );

  return {
    ...event,
    localDateLabel,
    localTimeLabel,
    selectedCountryCode: query.selectedCountryCode,
    watchProviders: event.watchProviders.map((provider) => ({
      ...provider,
      countryCode: query.selectedCountryCode,
    })),
  };
}
