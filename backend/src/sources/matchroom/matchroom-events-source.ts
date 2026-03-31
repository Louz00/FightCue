import type {
  BoutSummary,
  EventSummary,
  WatchProviderSummary,
} from "../../domain/models.js";
import { getMatchroomFallbackEvents } from "../../domain/mock-data.js";
import { formatForTimezone, normalizeTimeZone } from "../../domain/time.js";
import {
  matchSingle as sharedMatchSingle,
  sanitizeText as sharedSanitizeText,
  toSlug as sharedToSlug,
} from "../parse-utils.js";
import { buildSourceHealth } from "../source-health.js";
import type { EventSourcePreview, EventSourceQuery } from "../types.js";
import {
  buildMatchroomValidationWarnings,
  countMatchroomUpcomingCards,
} from "./matchroom-validation.js";

const OFFICIAL_MATCHROOM_EVENTS_URL = "https://www.matchroomboxing.com/events/";
const UPCOMING_SECTION_MARKER = "<h2>Upcoming</h2>";
const FIGHT_CARD_MARKER = '<div class="fight-card">';

export async function loadMatchroomEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const preview = await loadUpcomingEvents(query, fetchedAt);
    const items = preview.items;

    if (items.length === 0) {
      throw new Error("No Matchroom upcoming events were parsed");
    }

    const health = buildSourceHealth({
      mode: "live",
      parsedItemCount: items.length,
      reportedItemCount: preview.reportedUpcomingCount,
      checkedPageCount: 1,
    });

    return {
      source: "matchroom",
      mode: "live",
      officialUrl: OFFICIAL_MATCHROOM_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: items.length,
      health,
      warnings: buildMatchroomValidationWarnings({
        parsedItemCount: items.length,
        reportedUpcomingCount: preview.reportedUpcomingCount,
      }),
      items,
    };
  } catch (error) {
    const fallbackItems = getMatchroomFallbackEvents();

    return {
      source: "matchroom",
      mode: "fallback",
      officialUrl: OFFICIAL_MATCHROOM_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: fallbackItems.length,
      health: buildSourceHealth({
        mode: "fallback",
        parsedItemCount: fallbackItems.length,
        checkedPageCount: 0,
      }),
      warnings: [
        `Live Matchroom source unavailable: ${getErrorMessage(error)}`,
      ],
      items: fallbackItems,
    };
  }
}

async function loadUpcomingEvents(
  query: EventSourceQuery,
  fetchedAt: string,
): Promise<{
  items: EventSummary[];
  reportedUpcomingCount: number;
}> {
  const response = await fetch(OFFICIAL_MATCHROOM_EVENTS_URL, {
    headers: {
      "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
      accept: "text/html,application/xhtml+xml",
    },
  });

  if (!response.ok) {
    throw new Error(`Matchroom source returned ${response.status}`);
  }

  const html = await response.text();
  const upcomingSection = extractUpcomingSection(html);
  const reportedUpcomingCount = countMatchroomUpcomingCards(upcomingSection);
  const cards = upcomingSection
    .split(FIGHT_CARD_MARKER)
    .slice(1)
    .map((cardHtml) => `${FIGHT_CARD_MARKER}${cardHtml}`);

  return {
    items: (
      await Promise.all(
        cards.map((cardHtml) => parseMatchroomCard(cardHtml, query, fetchedAt)),
      )
    ).filter((event): event is EventSummary => event != null),
    reportedUpcomingCount,
  };
}

function extractUpcomingSection(html: string): string {
  const start = html.indexOf(UPCOMING_SECTION_MARKER);
  if (start < 0) {
    throw new Error("Could not find Matchroom upcoming section");
  }

  const archiveStart = html.indexOf('facetwp-template', start);
  return archiveStart >= 0 ? html.slice(start, archiveStart) : html.slice(start);
}

async function parseMatchroomCard(
  cardHtml: string,
  query: EventSourceQuery,
  fetchedAt: string,
): Promise<EventSummary | null> {
  const eventUrl = matchSingle(
    cardHtml,
    /<a class="button button--wide" href="([^"]+)" title="[^"]*">\s*<span>See event<\/span>/,
  );
  const fighterAName = sanitizeText(
    matchSingle(cardHtml, /<span class="boxer-1">([\s\S]*?)<\/span>/) ?? "",
  );
  const fighterBName = sanitizeText(
    matchSingle(cardHtml, /<span class="boxer-2">([\s\S]*?)<\/span>/) ?? "",
  );
  const dateLabel = sanitizeText(
    matchSingle(cardHtml, /<span class="day">([\s\S]*?)<\/span>/) ?? "",
  );
  const locationLabel = sanitizeText(
    matchSingle(cardHtml, /<span class="location">([\s\S]*?)<\/span>/) ?? "",
  );

  if (!eventUrl || !fighterAName || !fighterBName || !dateLabel) {
    return null;
  }

  const detail = await loadMatchroomEventDetail(eventUrl);
  const scheduledStart = detail.scheduledStartUtc ?? inferScheduledStartFromDayMonth(dateLabel);
  const scheduledTimezone = normalizeTimeZone(detail.eventTimezone ?? inferTimezoneFromLocation(locationLabel));
  const { localDateLabel, localTimeLabel } = formatForTimezone(
    new Date(scheduledStart),
    normalizeTimeZone(query.timezone),
  );
  const venueLabel = detail.venueLabel ?? extractVenueLabel(locationLabel);

  return {
    id: `evt_matchroom_${toSlug(eventUrl.split("/").filter(Boolean).pop() ?? `${fighterAName}-${fighterBName}`)}`,
    organizationSlug: "matchroom",
    organizationName: "Matchroom",
    sport: "boxing",
    title: `${fighterAName} vs ${fighterBName}`,
    tagline: "Official Matchroom card tracked from the Matchroom Boxing event schedule.",
    locationLabel: locationLabel || "Location TBA",
    venueLabel: venueLabel || "Venue TBA",
    scheduledStartUtc: scheduledStart,
    scheduledTimezone,
    localDateLabel,
    localTimeLabel,
    eventLocalTimeLabel: detail.dateLabel ?? "Official Matchroom local time pending",
    selectedCountryCode: query.selectedCountryCode,
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Official Matchroom schedule",
    officialUrl: eventUrl,
    watchProviders: buildWatchProviders(query.selectedCountryCode, fetchedAt),
    bouts: [
      {
        id: `bout_${toSlug(fighterAName)}_${toSlug(fighterBName)}_1`,
        slotLabel: "Main event",
        fighterAId: `ftr_${toSlug(fighterAName)}`,
        fighterAName,
        fighterBId: `ftr_${toSlug(fighterBName)}`,
        fighterBName,
        isMainEvent: true,
        includesFollowedFighter: false,
      } satisfies BoutSummary,
    ],
  };
}

async function loadMatchroomEventDetail(url: string): Promise<{
  scheduledStartUtc?: string;
  venueLabel?: string;
  dateLabel?: string;
  eventTimezone?: string;
}> {
  const response = await fetch(url, {
    headers: {
      "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
      accept: "text/html,application/xhtml+xml",
    },
  });

  if (!response.ok) {
    return {};
  }

  const html = await response.text();
  const fullDateLabel = sanitizeText(
    matchSingle(html, /<div class="event-details">[\s\S]*?<p class="date">([\s\S]*?)<\/p>/) ?? "",
  );
  const venueLabel = sanitizeText(
    matchSingle(html, /<p class="location">([\s\S]*?)<\/p>/) ?? "",
  ) || undefined;

  return {
    scheduledStartUtc: fullDateLabel ? parseMatchroomFullDate(fullDateLabel) : undefined,
    venueLabel,
    dateLabel: fullDateLabel || undefined,
    eventTimezone: venueLabel ? inferTimezoneFromLocation(venueLabel) : undefined,
  };
}

function parseMatchroomFullDate(fullDateLabel: string): string {
  const normalized = fullDateLabel
    .replace(/,/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  const match = normalized.match(
    /(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)\s+(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})/i,
  );

  if (!match) {
    throw new Error(`Could not parse Matchroom date: ${fullDateLabel}`);
  }

  const day = Number(match[1]);
  const month = monthNumber(match[2]);
  const year = Number(match[3]);
  return new Date(Date.UTC(year, month - 1, day, 19, 0, 0)).toISOString();
}

function inferScheduledStartFromDayMonth(dayMonthLabel: string): string {
  const match = dayMonthLabel.match(/(\d{1,2})\s+([A-Za-z]+)/);
  if (!match) {
    throw new Error(`Could not infer Matchroom event date from ${dayMonthLabel}`);
  }

  const day = Number(match[1]);
  const month = monthNumber(match[2]);
  const now = new Date();
  const currentYear = now.getUTCFullYear();
  const candidate = new Date(Date.UTC(currentYear, month - 1, day, 19, 0, 0));

  if (candidate.getTime() + 7 * 24 * 60 * 60 * 1000 < now.getTime()) {
    candidate.setUTCFullYear(currentYear + 1);
  }

  return candidate.toISOString();
}

function monthNumber(value: string): number {
  const index = [
    "jan",
    "feb",
    "mar",
    "apr",
    "may",
    "jun",
    "jul",
    "aug",
    "sep",
    "oct",
    "nov",
    "dec",
  ].indexOf(value.slice(0, 3).toLowerCase());

  if (index < 0) {
    throw new Error(`Unknown month label: ${value}`);
  }

  return index + 1;
}

function extractVenueLabel(locationLabel: string): string {
  const [venue] = locationLabel.split(",");
  return sanitizeText(venue ?? "");
}

function inferTimezoneFromLocation(locationLabel: string): string {
  const normalized = locationLabel.toLowerCase();
  if (normalized.includes("uk") || normalized.includes("london")) {
    return "Europe/London";
  }
  if (normalized.includes("ireland") || normalized.includes("dublin")) {
    return "Europe/Dublin";
  }
  if (normalized.includes("ghana") || normalized.includes("accra")) {
    return "Africa/Accra";
  }
  if (normalized.includes("usa") || normalized.includes("las vegas") || normalized.includes("new york")) {
    return "America/New_York";
  }
  if (normalized.includes("mexico")) {
    return "America/Mexico_City";
  }
  if (normalized.includes("australia")) {
    return "Australia/Sydney";
  }

  return "Europe/London";
}

function buildWatchProviders(
  countryCode: string,
  fetchedAt: string,
): WatchProviderSummary[] {
  return [
    {
      label: "DAZN",
      kind: "streaming",
      countryCode,
      confidence: "likely",
      lastVerifiedAt: fetchedAt,
      providerUrl: "https://www.dazn.com/",
    },
  ];
}

function matchSingle(input: string, regex: RegExp): string | undefined {
  return sharedMatchSingle(input, regex);
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

  return "Unknown source error";
}
