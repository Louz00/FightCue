import { getQueensberryFallbackEvents } from "../../domain/mock-data.js";
import type {
  BoutSummary,
  EventSummary,
  WatchProviderSummary,
} from "../../domain/models.js";
import {
  absoluteUrl as sharedAbsoluteUrl,
  matchSingle as sharedMatchSingle,
  sanitizeText as sharedSanitizeText,
  toSlug as sharedToSlug,
} from "../parse-utils.js";
import { buildSourceHealth } from "../source-health.js";
import type { EventSourcePreview, EventSourceQuery } from "../types.js";
import {
  buildQueensberryValidationWarnings,
  countQueensberryHeroCards,
} from "./queensberry-validation.js";

const OFFICIAL_QUEENSBERRY_EVENTS_URL = "https://queensberry.co.uk/pages/events";
const HERO_CARD_REGEX =
  /<section[^>]+class="custom-image-banner-section events-page-banner event-third-banner mob-page-banner-wrapper"[\s\S]*?<h2><span>([\s\S]*?)<\/span>\s*([\s\S]*?)<\/h2>[\s\S]*?<h2><span>([\s\S]*?)<\/span>\s*([\s\S]*?)<\/h2>[\s\S]*?<div class="banner-fight-events">\s*(?:<p>([\s\S]*?)<\/p>)?\s*<h5[^>]*>([\s\S]*?)<\/h5>\s*<h6>([\s\S]*?)<\/h6>[\s\S]*?<div class="banner-second-button">\s*<a href="([^"]+)">Event Info<\/a>/g;

export async function loadQueensberryEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();

  try {
    const response = await fetch(OFFICIAL_QUEENSBERRY_EVENTS_URL, {
      headers: {
        "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
        accept: "text/html,application/xhtml+xml",
      },
    });

    if (!response.ok) {
      throw new Error(`Queensberry source returned ${response.status}`);
    }

    const html = await response.text();
    const reportedUpcomingCount = countQueensberryHeroCards(html);
    const items = await parseQueensberryEventsPage(html, query, fetchedAt);

    if (items.length === 0) {
      throw new Error("No Queensberry upcoming events were parsed");
    }

    return {
      source: "queensberry",
      mode: "live",
      officialUrl: OFFICIAL_QUEENSBERRY_EVENTS_URL,
      timezone: query.timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: items.length,
      health: buildSourceHealth({
        mode: "live",
        parsedItemCount: items.length,
        reportedItemCount: reportedUpcomingCount,
        checkedPageCount: 1,
      }),
      warnings: buildQueensberryValidationWarnings({
        parsedItemCount: items.length,
        reportedUpcomingCount,
      }),
      items,
    };
  } catch (error) {
    const fallbackItems = getQueensberryFallbackEvents();

    return {
      source: "queensberry",
      mode: "fallback",
      officialUrl: OFFICIAL_QUEENSBERRY_EVENTS_URL,
      timezone: query.timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: fallbackItems.length,
      health: buildSourceHealth({
        mode: "fallback",
        parsedItemCount: fallbackItems.length,
        checkedPageCount: 0,
      }),
      warnings: [
        `Live Queensberry source unavailable: ${getErrorMessage(error)}`,
      ],
      items: fallbackItems,
    };
  }
}

async function parseQueensberryEventsPage(
  html: string,
  query: EventSourceQuery,
  fetchedAt: string,
): Promise<EventSummary[]> {
  const matches = [...html.matchAll(HERO_CARD_REGEX)];
  const items: EventSummary[] = [];

  for (const [index, match] of matches.entries()) {
    const fighterAName = cleanFighterName(`${match[1] ?? ""} ${match[2] ?? ""}`);
    const fighterBName = cleanFighterName(`${match[3] ?? ""} ${match[4] ?? ""}`);
    const championshipLabel = sanitizeText(match[5] ?? "");
    const locationLabel = sanitizeText(match[6] ?? "");
    const dateLabel = sanitizeText(match[7] ?? "");
    const detailUrl = absoluteUrl(match[8] ?? "");

    if (!fighterAName || !fighterBName || !locationLabel || !dateLabel || !detailUrl) {
      continue;
    }

    const detail = await loadQueensberryEventDetail(detailUrl, fetchedAt);
    const parsedDate = parseQueensberryDateLabel(dateLabel);

    items.push({
      id: `evt_queensberry_${toSlug(detailUrl.split("/").filter(Boolean).pop() ?? `${fighterAName}-${fighterBName}`)}`,
      organizationSlug: "queensberry",
      organizationName: "Queensberry",
      sport: "boxing",
      title: `${fighterAName} vs ${fighterBName}`,
      tagline:
        detail.eventAlias != null && detail.eventAlias.length > 0
          ? `Queensberry event: ${detail.eventAlias}.`
          : championshipLabel || "Official Queensberry event card.",
      locationLabel,
      venueLabel: extractVenueLabel(locationLabel),
      scheduledStartUtc: parsedDate.scheduledStartUtc,
      scheduledTimezone: parsedDate.scheduledTimezone,
      localDateLabel: parsedDate.localDateLabel,
      localTimeLabel: "TBA",
      eventLocalTimeLabel: "Official local start time pending",
      selectedCountryCode: query.selectedCountryCode,
      status: "scheduled",
      isFollowed: false,
      sourceLabel: "Official Queensberry events page",
      officialUrl: detailUrl,
      watchProviders: buildWatchProviders(
        query.selectedCountryCode,
        detail.providerLabel,
        fetchedAt,
      ),
      bouts: [
        {
          id: `bout_${toSlug(fighterAName)}_${toSlug(fighterBName)}_${index + 1}`,
          slotLabel: "Main event",
          fighterAId: `ftr_${toSlug(fighterAName)}`,
          fighterAName,
          fighterBId: `ftr_${toSlug(fighterBName)}`,
          fighterBName,
          weightClass: championshipLabel || undefined,
          isMainEvent: true,
          includesFollowedFighter: false,
        } satisfies BoutSummary,
      ],
    });
  }

  return items;
}

async function loadQueensberryEventDetail(
  detailUrl: string,
  fetchedAt: string,
): Promise<{
  providerLabel?: string;
  eventAlias?: string;
  lastVerifiedAt: string;
}> {
  try {
    const response = await fetch(detailUrl, {
      headers: {
        "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
        accept: "text/html,application/xhtml+xml",
      },
    });

    if (!response.ok) {
      return {
        lastVerifiedAt: fetchedAt,
      };
    }

    const html = await response.text();
    const providerLabel = detectProviderLabel(html);
    const title = sanitizeText(matchSingle(html, /<title>([^<]+)<\/title>/i) ?? "");
    const eventAlias = extractEventAlias(title);

    return {
      providerLabel,
      eventAlias,
      lastVerifiedAt: fetchedAt,
    };
  } catch {
    return {
      lastVerifiedAt: fetchedAt,
    };
  }
}

function parseQueensberryDateLabel(dateLabel: string): {
  scheduledStartUtc: string;
  scheduledTimezone: string;
  localDateLabel: string;
} {
  const match = dateLabel.match(/(\d{1,2})\s*\|\s*(\d{1,2})\s*\|\s*(\d{2,4})/);
  if (!match) {
    throw new Error(`Could not parse Queensberry date label: ${dateLabel}`);
  }

  const day = Number(match[1]);
  const month = Number(match[2]);
  const year = normalizeYear(Number(match[3]));
  const scheduledStartUtc = new Date(Date.UTC(year, month - 1, day, 18, 0, 0)).toISOString();

  return {
    scheduledStartUtc,
    scheduledTimezone: "UTC",
    localDateLabel: formatDateLabel(day, month, year),
  };
}

function detectProviderLabel(html: string): string | undefined {
  const providerMatch = html.match(/live(?: worldwide)? on ([A-Za-z0-9+ ]+)/i);
  const providerLabel = sanitizeText(providerMatch?.[1] ?? "");

  if (!providerLabel) {
    return undefined;
  }

  return providerLabel
    .replace(/\.$/, "")
    .replace(/\s{2,}/g, " ")
    .trim();
}

function buildWatchProviders(
  countryCode: string,
  providerLabel: string | undefined,
  fetchedAt: string,
): WatchProviderSummary[] {
  if (!providerLabel) {
    return [];
  }

  return [
    {
      label: providerLabel,
      kind: "streaming",
      countryCode,
      confidence: "confirmed",
      lastVerifiedAt: fetchedAt,
    },
  ];
}

function extractVenueLabel(locationLabel: string): string {
  return sanitizeText(locationLabel.split(",")[0] ?? "");
}

function extractEventAlias(title: string): string | undefined {
  const parts = title.split(" - ").map((part) => part.trim()).filter(Boolean);
  if (parts.length < 2) {
    return undefined;
  }

  return parts.slice(1).join(" - ");
}

function cleanFighterName(input: string): string {
  return sanitizeText(input)
    .replace(/(^|\s)-+/g, "$1")
    .replace(/-+(?=\s|$)/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function absoluteUrl(path: string): string {
  return sharedAbsoluteUrl(path, "https://queensberry.co.uk");
}

function sanitizeText(input: string): string {
  return sharedSanitizeText(input);
}

function matchSingle(input: string, regex: RegExp): string | undefined {
  return sharedMatchSingle(input, regex);
}

function normalizeYear(value: number): number {
  if (value >= 1000) {
    return value;
  }

  return value >= 70 ? 1900 + value : 2000 + value;
}

function formatDateLabel(day: number, month: number, year: number): string {
  const date = new Date(Date.UTC(year, month - 1, day));
  return new Intl.DateTimeFormat("en-GB", {
    weekday: "short",
    day: "numeric",
    month: "short",
    timeZone: "UTC",
  }).format(date);
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
