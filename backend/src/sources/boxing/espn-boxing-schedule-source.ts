import type {
  BoutSummary,
  EventSummary,
  WatchProviderSummary,
} from "../../domain/models.js";
import { formatForTimezone, normalizeTimeZone } from "../../domain/time.js";
import { buildSourceHealth } from "../source-health.js";
import type { EventSourcePreview, EventSourceQuery } from "../types.js";

const ESPN_BOXING_SCHEDULE_URL =
  "https://www.espn.com/boxing/story/_/id/12508267/boxing-schedule";
const FULL_SCHEDULE_MARKER = "<h2>Full schedule:</h2>";

export async function loadEspnBoxingSchedulePreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const response = await fetch(ESPN_BOXING_SCHEDULE_URL, {
      headers: {
        "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
        accept: "text/html,application/xhtml+xml",
      },
    });

    if (!response.ok) {
      throw new Error(`ESPN boxing schedule returned ${response.status}`);
    }

    const html = await response.text();
    const parsed = parseEspnBoxingScheduleHtml(html, query, fetchedAt);

    if (parsed.items.length === 0) {
      throw new Error("No ESPN boxing schedule events were parsed");
    }

    const health = buildSourceHealth({
      mode: "live",
      parsedItemCount: parsed.items.length,
      reportedItemCount: parsed.reportedItemCount,
      checkedPageCount: 1,
    });
    const warnings = [
      "ESPN boxing schedule is treated as an editorial aggregate source and is not yet merged into the main feed to avoid duplicate cards.",
    ];

    if (health.status === "degraded" && parsed.reportedItemCount != null) {
      warnings.push(
        `ESPN boxing schedule parsing is below the detected event block count (${parsed.items.length}/${parsed.reportedItemCount}).`,
      );
    }

    return {
      source: "espn_boxing_schedule",
      mode: "live",
      officialUrl: ESPN_BOXING_SCHEDULE_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: parsed.items.length,
      health,
      warnings,
      items: parsed.items,
    };
  } catch (error) {
    return {
      source: "espn_boxing_schedule",
      mode: "fallback",
      officialUrl: ESPN_BOXING_SCHEDULE_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: 0,
      health: buildSourceHealth({
        mode: "fallback",
        parsedItemCount: 0,
        checkedPageCount: 0,
      }),
      warnings: [
        `Live ESPN boxing schedule unavailable: ${getErrorMessage(error)}`,
      ],
      items: [],
    };
  }
}

export function parseEspnBoxingScheduleHtml(
  html: string,
  query: EventSourceQuery,
  fetchedAt: string,
  referenceYear = new Date().getUTCFullYear(),
): {
  items: EventSummary[];
  reportedItemCount: number;
} {
  const fullScheduleSection = extractFullScheduleSection(html);
  const blockRegex =
    /<h3>\s*([A-Za-z.]+\s+\d{1,2}:\s+[^<]+)\s*<\/h3>\s*<ul>\s*([\s\S]*?)<\/ul>/g;
  const blocks = [...fullScheduleSection.matchAll(blockRegex)];
  const items = blocks
    .map((match, index) =>
      parseEspnScheduleBlock(
        match[1] ?? "",
        match[2] ?? "",
        query,
        fetchedAt,
        referenceYear,
        index,
      ),
    )
    .filter((event): event is EventSummary => event != null);

  return {
    items,
    reportedItemCount: blocks.length,
  };
}

function extractFullScheduleSection(html: string): string {
  const start = html.indexOf(FULL_SCHEDULE_MARKER);
  if (start < 0) {
    throw new Error("Could not find ESPN boxing full schedule section");
  }

  return html.slice(start);
}

function parseEspnScheduleBlock(
  heading: string,
  listHtml: string,
  query: EventSourceQuery,
  fetchedAt: string,
  referenceYear: number,
  index: number,
): EventSummary | null {
  const headingMatch = heading.match(
    /^([A-Za-z.]+)\s+(\d{1,2}):\s+(.+?)(?:\s+\(([^)]+)\))?$/,
  );
  if (!headingMatch) {
    return null;
  }

  const month = monthNumber(headingMatch[1] ?? "");
  const day = Number(headingMatch[2]);
  const locationLabel = sanitizeText(headingMatch[3] ?? "");
  const providerLabel = sanitizeText(headingMatch[4] ?? "");
  const boutTexts = [...listHtml.matchAll(/<li><p>([\s\S]*?)<\/li>/g)]
    .map((match) => sanitizeText(match[1] ?? ""))
    .filter(Boolean);

  if (boutTexts.length === 0) {
    return null;
  }

  const bouts = boutTexts
    .map((boutText, boutIndex) => parseEspnBout(boutText, boutIndex))
    .filter((bout): bout is BoutSummary => bout != null);

  if (bouts.length === 0) {
    return null;
  }

  const mainBout = bouts[0];
  const approximateUtc = new Date(
    Date.UTC(referenceYear, month - 1, day, 18, 0, 0),
  ).toISOString();
  const scheduledTimezone = inferTimezoneFromLocation(locationLabel);
  const { localDateLabel } = formatForTimezone(
    new Date(approximateUtc),
    normalizeTimeZone(query.timezone),
  );

  return {
    id: `evt_espn_boxing_${referenceYear}_${month}_${day}_${toSlug(locationLabel)}_${index + 1}`,
    organizationSlug: "espn_boxing",
    organizationName: "ESPN Boxing",
    sport: "boxing",
    title: `${mainBout.fighterAName} vs ${mainBout.fighterBName}`,
    tagline:
      "Editorial boxing schedule tracked from ESPN's published boxing schedule.",
    locationLabel,
    venueLabel: extractVenueLabel(locationLabel),
    scheduledStartUtc: approximateUtc,
    scheduledTimezone,
    localDateLabel,
    localTimeLabel: "TBA",
    eventLocalTimeLabel: providerLabel
      ? `${providerLabel} listing`
      : "ESPN schedule listing",
    selectedCountryCode: query.selectedCountryCode,
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "ESPN boxing schedule",
    officialUrl: ESPN_BOXING_SCHEDULE_URL,
    watchProviders: buildWatchProviders(
      query.selectedCountryCode,
      providerLabel,
      fetchedAt,
    ),
    bouts,
  };
}

function parseEspnBout(
  text: string,
  index: number,
): BoutSummary | null {
  const normalized = text.replace(/^Title fight:\s*/i, "").trim();
  const titleMatch = normalized.match(/^(.+?)\s+vs\.?\s+(.+?)(?:,|$)/i);

  if (!titleMatch) {
    return null;
  }

  const fighterAName = sanitizeText(titleMatch[1] ?? "");
  const fighterBName = sanitizeText(titleMatch[2] ?? "");
  const weightClass = extractWeightClass(normalized);

  return {
    id: `bout_${toSlug(fighterAName)}_${toSlug(fighterBName)}_${index + 1}`,
    slotLabel: index === 0 ? "Main event" : `Bout ${index + 1}`,
    fighterAId: `ftr_${toSlug(fighterAName)}`,
    fighterAName,
    fighterBId: `ftr_${toSlug(fighterBName)}`,
    fighterBName,
    weightClass,
    isMainEvent: index === 0,
    includesFollowedFighter: false,
  };
}

function extractWeightClass(text: string): string | undefined {
  const segments = text
    .split(",")
    .map((segment) => segment.trim())
    .filter(Boolean);
  const weightSegment = [...segments].reverse().find((segment) =>
    /weight|heavyweights?|cruiserweights?|middleweights?|welterweights?|lightweights?|featherweights?|bantamweights?|flyweights?/i.test(
      segment,
    ),
  );

  return weightSegment;
}

function buildWatchProviders(
  countryCode: string,
  providerLabel: string,
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
      confidence: "likely",
      lastVerifiedAt: fetchedAt,
    },
  ];
}

function extractVenueLabel(locationLabel: string): string {
  return sanitizeText(locationLabel.split(",")[0] ?? "");
}

function inferTimezoneFromLocation(locationLabel: string): string {
  const normalized = locationLabel.toLowerCase();

  if (
    normalized.includes("london") ||
    normalized.includes("wales") ||
    normalized.includes("manchester") ||
    normalized.includes("uk")
  ) {
    return "Europe/London";
  }
  if (normalized.includes("tokyo")) {
    return "Asia/Tokyo";
  }
  if (normalized.includes("australia") || normalized.includes("wollongong")) {
    return "Australia/Sydney";
  }
  if (
    normalized.includes("las vegas") ||
    normalized.includes("new york") ||
    normalized.includes("new jersey") ||
    normalized.includes("atlantic city") ||
    normalized.includes("usa")
  ) {
    return "America/New_York";
  }
  if (normalized.includes("giza") || normalized.includes("egypt")) {
    return "Africa/Cairo";
  }

  return "UTC";
}

function monthNumber(value: string): number {
  const normalized = value.replace(/\./g, "").slice(0, 3).toLowerCase();
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
  ].indexOf(normalized);

  if (index < 0) {
    throw new Error(`Unknown month label: ${value}`);
  }

  return index + 1;
}

function sanitizeText(input: string): string {
  return input
    .replace(/<[^>]+>/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, "\"")
    .replace(/&#x27;/g, "'")
    .replace(/\s+/g, " ")
    .trim();
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
