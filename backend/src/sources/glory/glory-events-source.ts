import { getGloryFallbackEvents } from "../../domain/mock-data.js";
import type {
  BoutSummary,
  EventSummary,
  WatchProviderSummary,
} from "../../domain/models.js";
import { formatForTimezone, normalizeTimeZone } from "../../domain/time.js";
import { buildSourceHealth } from "../source-health.js";
import type { EventSourcePreview, EventSourceQuery } from "../types.js";

const OFFICIAL_GLORY_EVENTS_URL = "https://glorykickboxing.com/events";
const GLORY_EVENTS_API_URL =
  "https://glory-api.pinkyellow.computer/api/collections/events/entries";
const GLORY_PAGE_LIMIT = 12;
const MAX_GLORY_PAGES = 3;

type GloryApiResponse = {
  data?: GloryApiEventEntry[];
  meta?: {
    current_page?: number;
    last_page?: number;
  };
};

type GloryApiEventEntry = {
  title?: string;
  starts_at?: string;
  ends_at?: string;
  venue?: string | null;
  city?: string | null;
  country?: {
    key?: string | null;
    label?: string | null;
  } | null;
  url?: string | null;
  buttons?: GloryButton[] | null;
  youtube_prelims?: string | null;
  facebook_prelims?: string | null;
  fight_cards?: GloryFightCard[] | null;
  tournament_title?: string | null;
  event_type?: {
    label?: string | null;
  } | null;
};

type GloryButton = {
  type?: string | null;
  enabled?: boolean | null;
  ticket_link?: string | null;
};

type GloryFightCard = {
  title?: string | null;
  weight_class?: GloryTaxonomyValue | string[] | null;
  fight_type?: GloryTaxonomyValue | string[] | null;
  white_corner?: GloryCorner | number[] | null;
  black_corner?: GloryCorner | number[] | null;
};

type GloryTaxonomyValue = {
  title?: string | null;
  slug?: string | null;
};

type GloryCorner = {
  title?: string | null;
  url?: string | null;
};

export async function loadGloryEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const preview = await loadAllUpcomingEvents(query, fetchedAt);
    const items = preview.items;

    if (items.length === 0) {
      throw new Error("No upcoming GLORY events were parsed");
    }

    return {
      source: "glory",
      mode: "live",
      officialUrl: OFFICIAL_GLORY_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: items.length,
      health: buildSourceHealth({
        mode: "live",
        parsedItemCount: items.length,
        checkedPageCount: preview.checkedPageCount,
      }),
      warnings: [
        "GLORY watch coverage is still a pilot and currently falls back to official schedule links when no confirmed stream is published.",
      ],
      items,
    };
  } catch (error) {
    const fallbackItems = getGloryFallbackEvents().map((event) =>
      reformatEventForQuery(event, query),
    );

    return {
      source: "glory",
      mode: "fallback",
      officialUrl: OFFICIAL_GLORY_EVENTS_URL,
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
        `Live GLORY source unavailable, using curated fallback data: ${getErrorMessage(error)}`,
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
}> {
  const items: EventSummary[] = [];
  const seenUrls = new Set<string>();
  const upcomingCutoff = new Date();
  upcomingCutoff.setUTCHours(0, 0, 0, 0);
  let checkedPageCount = 0;

  for (let page = 1; page <= MAX_GLORY_PAGES; page += 1) {
    const response = await fetchGloryEventsPage(page);
    const entries = response.data ?? [];
    if (entries.length === 0) {
      break;
    }

    checkedPageCount += 1;
    let encounteredPastEvent = false;

    for (const entry of entries) {
      if (!isUpcomingEntry(entry, upcomingCutoff)) {
        encounteredPastEvent = true;
        continue;
      }

      const parsed = parseGloryEventEntry(entry, query, fetchedAt);
      if (!parsed) {
        continue;
      }

      const stableKey = parsed.officialUrl ?? parsed.title;
      if (seenUrls.has(stableKey)) {
        continue;
      }

      seenUrls.add(stableKey);
      items.push(parsed);
    }

    if (encounteredPastEvent) {
      break;
    }

    const currentPage = response.meta?.current_page ?? page;
    const lastPage = response.meta?.last_page ?? page;
    if (currentPage >= lastPage) {
      break;
    }
  }

  return {
    items,
    checkedPageCount,
  };
}

async function fetchGloryEventsPage(page: number): Promise<GloryApiResponse> {
  const url = new URL(GLORY_EVENTS_API_URL);
  url.searchParams.set("limit", String(GLORY_PAGE_LIMIT));
  url.searchParams.set("sort", "-starts_at");
  url.searchParams.set("page", String(page));

  const response = await fetch(url, {
    headers: {
      "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
      accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`GLORY source returned ${response.status}`);
  }

  return (await response.json()) as GloryApiResponse;
}

function isUpcomingEntry(entry: GloryApiEventEntry, cutoff: Date): boolean {
  const comparisonValue = entry.ends_at ?? entry.starts_at;
  if (!comparisonValue) {
    return false;
  }

  return new Date(comparisonValue).getTime() >= cutoff.getTime();
}

function parseGloryEventEntry(
  entry: GloryApiEventEntry,
  query: EventSourceQuery,
  fetchedAt: string,
): EventSummary | null {
  if (!entry.title || !entry.starts_at) {
    return null;
  }

  const scheduledStart = new Date(entry.starts_at);
  if (Number.isNaN(scheduledStart.getTime())) {
    return null;
  }

  const timezone = normalizeTimeZone(query.timezone);
  const eventTimezone = inferEventTimezone(entry);
  const { localDateLabel, localTimeLabel } = formatForTimezone(scheduledStart, timezone);
  const officialUrl = absoluteUrl(entry.url);
  const bouts = parseFightCards(entry.fight_cards);

  return {
    id: `evt_glory_${toSlug(eventSlug(entry))}`,
    organizationSlug: "glory",
    organizationName: "GLORY",
    sport: "kickboxing",
    title: sanitizeText(entry.title),
    tagline: buildEventTagline(entry),
    locationLabel: buildLocationLabel(entry),
    venueLabel: sanitizeText(entry.venue ?? "") || "Venue TBA",
    scheduledStartUtc: scheduledStart.toISOString(),
    scheduledTimezone: eventTimezone,
    localDateLabel,
    localTimeLabel,
    eventLocalTimeLabel: formatEventLocalTimeLabel(scheduledStart, eventTimezone),
    selectedCountryCode: query.selectedCountryCode,
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Official GLORY schedule",
    officialUrl,
    watchProviders: parseWatchProviders(entry, officialUrl, query.selectedCountryCode, fetchedAt),
    bouts,
  };
}

function parseFightCards(fightCards: GloryFightCard[] | null | undefined): BoutSummary[] {
  if (!fightCards || fightCards.length === 0) {
    return [];
  }

  return fightCards
    .map((fightCard, index) => parseFightCard(fightCard, index))
    .filter((bout): bout is BoutSummary => bout != null);
}

function parseFightCard(
  fightCard: GloryFightCard,
  index: number,
): BoutSummary | null {
  const fallbackNames = splitBoutTitle(sanitizeText(fightCard.title ?? ""));
  const fighterAName = readCornerName(fightCard.white_corner) ?? fallbackNames[0];
  const fighterBName = readCornerName(fightCard.black_corner) ?? fallbackNames[1];

  if (!fighterAName || !fighterBName) {
    return null;
  }

  const slotLabel =
    index === 0
      ? "Main event"
      : index === 1
        ? "Co-main"
        : normalizeFightType(readTaxonomyLabel(fightCard.fight_type) ?? "Featured bout");

  return {
    id: `bout_${toSlug(fighterAName)}_${toSlug(fighterBName)}_${index + 1}`,
    slotLabel,
    fighterAId: `ftr_${toSlug(fighterAName)}`,
    fighterAName,
    fighterBId: `ftr_${toSlug(fighterBName)}`,
    fighterBName,
    weightClass: readTaxonomyLabel(fightCard.weight_class),
    isMainEvent: index === 0,
    includesFollowedFighter: false,
  };
}

function parseWatchProviders(
  entry: GloryApiEventEntry,
  officialUrl: string | undefined,
  selectedCountryCode: string,
  fetchedAt: string,
): WatchProviderSummary[] {
  const providers = new Map<string, WatchProviderSummary>();

  if (entry.youtube_prelims && isHttpUrl(entry.youtube_prelims)) {
    providers.set("YouTube prelims", {
      label: "YouTube prelims",
      kind: "streaming",
      countryCode: selectedCountryCode,
      confidence: "confirmed",
      lastVerifiedAt: fetchedAt,
      providerUrl: entry.youtube_prelims,
    });
  }

  if (entry.facebook_prelims && isHttpUrl(entry.facebook_prelims)) {
    providers.set("Facebook prelims", {
      label: "Facebook prelims",
      kind: "streaming",
      countryCode: selectedCountryCode,
      confidence: "confirmed",
      lastVerifiedAt: fetchedAt,
      providerUrl: entry.facebook_prelims,
    });
  }

  const hasTicketsButton = (entry.buttons ?? []).some(
    (button) => button.type === "tickets_button" && typeof button.ticket_link === "string",
  );

  if (providers.size === 0 && hasTicketsButton && officialUrl) {
    providers.set("GLORY event page", {
      label: "GLORY event page",
      kind: "network",
      countryCode: selectedCountryCode,
      confidence: "unknown",
      lastVerifiedAt: fetchedAt,
      providerUrl: officialUrl,
    });
  }

  return [...providers.values()];
}

function buildEventTagline(entry: GloryApiEventEntry): string {
  const eventType = sanitizeText(entry.event_type?.label ?? "");
  const locationLabel = buildLocationLabel(entry);
  const tournamentTitle = sanitizeText(entry.tournament_title ?? "");

  if (tournamentTitle) {
    return `${tournamentTitle} tracked directly from the official GLORY schedule.`;
  }

  if (locationLabel) {
    return `${eventType || "Official GLORY"} card tracked from ${locationLabel}.`;
  }

  return "Official GLORY card tracked directly from the GLORY schedule.";
}

function buildLocationLabel(entry: GloryApiEventEntry): string {
  const city = sanitizeText(entry.city ?? "");
  const country = sanitizeText(entry.country?.label ?? "");

  if (city && country) {
    return `${city}, ${country}`;
  }

  return city || country || "Location TBA";
}

function eventSlug(entry: GloryApiEventEntry): string {
  const urlSlug = entry.url?.split("/").filter(Boolean).pop();
  return sanitizeText(urlSlug ?? entry.title ?? "glory-event");
}

function inferEventTimezone(entry: GloryApiEventEntry): string {
  const city = sanitizeText(entry.city ?? "").toLowerCase();
  const cityTimezones: Record<string, string> = {
    tokyo: "Asia/Tokyo",
    rotterdam: "Europe/Amsterdam",
    amsterdam: "Europe/Amsterdam",
    paris: "Europe/Paris",
    brussels: "Europe/Brussels",
    antwerp: "Europe/Brussels",
    london: "Europe/London",
    riyadh: "Asia/Riyadh",
    dubai: "Asia/Dubai",
    zagreb: "Europe/Zagreb",
    belgrade: "Europe/Belgrade",
    bucharest: "Europe/Bucharest",
    warsaw: "Europe/Warsaw",
    lisbon: "Europe/Lisbon",
    madrid: "Europe/Madrid",
    berlin: "Europe/Berlin",
    lasvegas: "America/Los_Angeles",
    "las vegas": "America/Los_Angeles",
    miami: "America/New_York",
    "new york": "America/New_York",
    chicago: "America/Chicago",
  };

  if (cityTimezones[city]) {
    return normalizeTimeZone(cityTimezones[city]);
  }

  const countryCode = sanitizeText(entry.country?.key ?? "").toUpperCase();
  const countryTimezones: Record<string, string> = {
    AE: "Asia/Dubai",
    BE: "Europe/Brussels",
    DE: "Europe/Berlin",
    ES: "Europe/Madrid",
    FR: "Europe/Paris",
    GB: "Europe/London",
    HR: "Europe/Zagreb",
    JP: "Asia/Tokyo",
    NL: "Europe/Amsterdam",
    PT: "Europe/Lisbon",
    RO: "Europe/Bucharest",
    RS: "Europe/Belgrade",
    SA: "Asia/Riyadh",
    US: "America/New_York",
  };

  return normalizeTimeZone(countryTimezones[countryCode] ?? "UTC");
}

function formatEventLocalTimeLabel(date: Date, timezone: string): string {
  const safeTimezone = normalizeTimeZone(timezone);
  const weekdayParts = new Intl.DateTimeFormat("en-US", {
    weekday: "short",
    day: "numeric",
    month: "short",
    timeZone: safeTimezone,
  }).formatToParts(date);
  const weekday = weekdayParts.find((part) => part.type === "weekday")?.value ?? "";
  const day = weekdayParts.find((part) => part.type === "day")?.value ?? "";
  const month = weekdayParts.find((part) => part.type === "month")?.value ?? "";
  const timeLabel = new Intl.DateTimeFormat("en-US", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
    timeZone: safeTimezone,
  }).format(date);
  const timeZoneLabel =
    new Intl.DateTimeFormat("en-US", {
      timeZone: safeTimezone,
      timeZoneName: "short",
    })
      .formatToParts(date)
      .find((part) => part.type === "timeZoneName")?.value ?? safeTimezone;

  return `${weekday} ${day} ${month} • ${timeLabel} ${timeZoneLabel}`;
}

function readTaxonomyLabel(
  value: GloryTaxonomyValue | string[] | null | undefined,
): string | undefined {
  if (!value) {
    return undefined;
  }

  if (Array.isArray(value)) {
    return value[0] ? humanizeSlug(value[0]) : undefined;
  }

  return sanitizeText(value.title ?? "") || humanizeSlug(value.slug ?? "");
}

function readCornerName(value: GloryCorner | number[] | null | undefined): string | undefined {
  if (!value || Array.isArray(value)) {
    return undefined;
  }

  return sanitizeText(value.title ?? "") || undefined;
}

function normalizeFightType(value: string): string {
  const normalized = sanitizeText(value);
  if (!normalized) {
    return "Featured bout";
  }

  switch (normalized.toLowerCase()) {
    case "world title fight":
      return "Title fight";
    case "fight reserve":
      return "Reserve bout";
    default:
      return normalized;
  }
}

function splitBoutTitle(title: string): [string | undefined, string | undefined] {
  const parts = title.split(/\s+vs\.?\s+/i).map((part) => sanitizeText(part));
  return [parts[0] || undefined, parts[1] || undefined];
}

function absoluteUrl(pathOrUrl: string | null | undefined): string | undefined {
  if (!pathOrUrl) {
    return undefined;
  }

  if (pathOrUrl.startsWith("http://") || pathOrUrl.startsWith("https://")) {
    return pathOrUrl;
  }

  return new URL(pathOrUrl, OFFICIAL_GLORY_EVENTS_URL).toString();
}

function humanizeSlug(value: string): string {
  return sanitizeText(
    value
      .replace(/[-_]+/g, " ")
      .replace(/\b\w/g, (match) => match.toUpperCase()),
  );
}

function isHttpUrl(value: string): boolean {
  return value.startsWith("http://") || value.startsWith("https://");
}

function sanitizeText(input: string): string {
  return input.replace(/\s+/g, " ").trim();
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
