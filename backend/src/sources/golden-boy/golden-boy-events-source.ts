import { formatForTimezone, normalizeTimeZone } from "../../domain/time.js";
import type {
  BoutSummary,
  EventSummary,
  ProviderKind,
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

const OFFICIAL_GOLDEN_BOY_EVENTS_URL = "https://www.goldenboy.com/events/";
const MAIN_EVENT_SECTION_REGEX =
  /<section class="bg-dark-grad pattern-overlay-4 [\s\S]*?<h2 class="display-4 fw-normal text-white">([\s\S]*?)<\/h2>[\s\S]*?<p class="mb-4 display-7[\s\S]*?text-white">([\s\S]*?)<\/p>[\s\S]*?(?:<a class="btn btn-success[\s\S]*?href="([^"]+)"[\s\S]*?>[\s\S]*?GET TICKETS[\s\S]*?<\/a>)?[\s\S]*?(?:<a class="btn btn-light[\s\S]*?href="([^"]+)"[\s\S]*?>[\s\S]*?WATCH ON ([\s\S]*?)<\/a>)?[\s\S]*?(?:<a class="btn btn-primary[\s\S]*?href="([^"]+)"[\s\S]*?>[\s\S]*?VIEW BOUTS[\s\S]*?<\/a>|<button class="btn btn-primary[\s\S]*?>[\s\S]*?VIEW BOUTS[\s\S]*?<\/button>)/g;
const MAIN_EVENT_TITLE_REGEX = /^([A-Za-z]+)\s+(\d{1,2}):\s+(.+)$/i;

export async function loadGoldenBoyEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const response = await fetch(OFFICIAL_GOLDEN_BOY_EVENTS_URL, {
      headers: {
        "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
        accept: "text/html,application/xhtml+xml",
      },
    });

    if (!response.ok) {
      throw new Error(`Golden Boy events page returned ${response.status}`);
    }

    const html = await response.text();
    const reportedUpcomingCount = [...html.matchAll(MAIN_EVENT_SECTION_REGEX)].length;
    const items = await parseGoldenBoyEventsHtml(html, query, fetchedAt);

    if (items.length === 0) {
      throw new Error("No Golden Boy upcoming events were parsed");
    }

    const health = buildSourceHealth({
      mode: "live",
      parsedItemCount: items.length,
      reportedItemCount: reportedUpcomingCount,
      checkedPageCount: 1,
    });
    const warnings =
      health.status === "degraded" && reportedUpcomingCount > items.length
        ? [
            `Golden Boy parsing is below the detected event hero count (${items.length}/${reportedUpcomingCount}).`,
          ]
        : [];

    return {
      source: "golden_boy",
      mode: "live",
      officialUrl: OFFICIAL_GOLDEN_BOY_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: items.length,
      health,
      warnings,
      items,
    };
  } catch (error) {
    return {
      source: "golden_boy",
      mode: "fallback",
      officialUrl: OFFICIAL_GOLDEN_BOY_EVENTS_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: 0,
      health: buildSourceHealth({
        mode: "fallback",
        parsedItemCount: 0,
        checkedPageCount: 0,
      }),
      warnings: [`Live Golden Boy source unavailable: ${getErrorMessage(error)}`],
      items: [],
    };
  }
}

async function parseGoldenBoyEventsHtml(
  html: string,
  query: EventSourceQuery,
  fetchedAt: string,
): Promise<EventSummary[]> {
  const matches = [...html.matchAll(MAIN_EVENT_SECTION_REGEX)];
  const items = await Promise.all(
    matches.map(async (match, index) => {
      const heading = sanitizeText(match[1] ?? "");
      const locationLabel = sanitizeText(match[2] ?? "");
      const ticketUrl = match[3] ?? undefined;
      const watchUrl = match[4] ?? undefined;
      const watchLabel = sanitizeText(match[5] ?? "");
      const detailUrl = absoluteUrl(match[6] ?? "");

      if (!heading || !locationLabel) {
        return null;
      }

      const titleMatch = heading.match(MAIN_EVENT_TITLE_REGEX);
      if (!titleMatch) {
        return null;
      }

      const month = monthNumber(titleMatch[1]);
      const day = Number(titleMatch[2]);
      const fightLabel = sanitizeText(titleMatch[3] ?? "");
      const scheduledStartUtc = inferGoldenBoyScheduledStart(month, day);
      const detail = detailUrl
        ? await loadGoldenBoyEventDetail(detailUrl)
        : undefined;
      const mainBout = detail?.mainBout ?? inferMainBoutFromHeading(fightLabel);
      if (!mainBout) {
        return null;
      }

      const { localDateLabel } = formatForTimezone(
        new Date(scheduledStartUtc),
        normalizeTimeZone(query.timezone),
      );
      const weightClass = detail?.weightClass;
      const providerLabel = detail?.providerLabel ?? watchLabel;
      const title = `${mainBout.fighterAName} vs ${mainBout.fighterBName}`;

      void ticketUrl;

      return {
        id: `evt_golden_boy_${toSlug(detailUrl.split("/").filter(Boolean).pop() ?? `${title}_${index + 1}`)}`,
        organizationSlug: "golden_boy",
        organizationName: "Golden Boy",
        sport: "boxing",
        title,
        tagline: "Official Golden Boy event tracked from the Golden Boy events page.",
        locationLabel,
        venueLabel: extractVenueLabel(locationLabel),
        scheduledStartUtc,
        scheduledTimezone: "America/Los_Angeles",
        localDateLabel,
        localTimeLabel: "TBA",
        eventLocalTimeLabel: providerLabel
          ? `Official Golden Boy listing on ${providerLabel}`
          : "Official Golden Boy local time pending",
        selectedCountryCode: query.selectedCountryCode,
        status: "scheduled",
        isFollowed: false,
        sourceLabel: "Official Golden Boy events page",
        officialUrl: detailUrl || OFFICIAL_GOLDEN_BOY_EVENTS_URL,
        watchProviders: buildWatchProviders(
          query.selectedCountryCode,
          providerLabel,
          watchUrl,
          fetchedAt,
        ),
        bouts: [
          {
            id: `bout_${toSlug(mainBout.fighterAName)}_${toSlug(mainBout.fighterBName)}_1`,
            slotLabel: "Main event",
            fighterAId: `ftr_${toSlug(mainBout.fighterAName)}`,
            fighterAName: mainBout.fighterAName,
            fighterBId: `ftr_${toSlug(mainBout.fighterBName)}`,
            fighterBName: mainBout.fighterBName,
            weightClass: weightClass || undefined,
            isMainEvent: true,
            includesFollowedFighter: false,
          } satisfies BoutSummary,
        ],
      } satisfies EventSummary;
    }),
  );

  return items.flatMap((event) => (event ? [event] : []));
}

async function loadGoldenBoyEventDetail(
  detailUrl: string,
): Promise<{
  mainBout?: {
    fighterAName: string;
    fighterBName: string;
  };
  weightClass?: string;
  providerLabel?: string;
}> {
  try {
    const response = await fetch(detailUrl, {
      headers: {
        "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
        accept: "text/html,application/xhtml+xml",
      },
    });

    if (!response.ok) {
      return {};
    }

    const html = await response.text();
    const redCornerName = cleanFighterName(
      sanitizeText(
        matchSingle(
          html,
          /<h5 class="text-white bout-fighter-name [^"]*">([\s\S]*?)<\/h5>/,
        ) ?? "",
      ),
    );
    const blueCornerName = cleanFighterName(
      sanitizeText(
        matchSingle(
          html,
          /<h5 class="text-white blue-title bout-fighter-name">([\s\S]*?)<\/h5>/,
        ) ?? "",
      ),
    );
    const weightClass = sanitizeText(
      matchSingle(
        html,
        /<div class="col-12 text-center mb-4 text-primary title-org">\s*[\s\S]*?\|\s*([^|<]+)\s*\|/i,
      ) ?? "",
    );
    const providerLabel = sanitizeText(
      matchSingle(
        html,
        /<div class="col-12 text-center text-primary bout-type">[\s\S]*?<span class="">([^|<]+)\s*\|/i,
      ) ?? "",
    );

    return {
      mainBout:
        redCornerName && blueCornerName
          ? {
              fighterAName: redCornerName,
              fighterBName: blueCornerName,
            }
          : undefined,
      weightClass: weightClass || undefined,
      providerLabel: providerLabel || undefined,
    };
  } catch {
    return {};
  }
}

function inferMainBoutFromHeading(fightLabel: string):
  | {
      fighterAName: string;
      fighterBName: string;
    }
  | undefined {
  const parts = fightLabel.split(/\s+vs\.?\s+/i).map((part) => sanitizeText(part));
  if (parts.length !== 2 || !parts[0] || !parts[1]) {
    return undefined;
  }

  return {
    fighterAName: parts[0],
    fighterBName: parts[1],
  };
}

function inferGoldenBoyScheduledStart(month: number, day: number): string {
  const year = inferUpcomingYear(month, day);
  return new Date(Date.UTC(year, month - 1, day + 1, 3, 0, 0)).toISOString();
}

function inferUpcomingYear(month: number, day: number): number {
  const now = new Date();
  const currentYear = now.getUTCFullYear();
  const candidate = new Date(Date.UTC(currentYear, month - 1, day, 0, 0, 0));
  const lowerBound = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - 30));

  return candidate < lowerBound ? currentYear + 1 : currentYear;
}

function buildWatchProviders(
  countryCode: string,
  providerLabel: string | undefined,
  providerUrl: string | undefined,
  fetchedAt: string,
): WatchProviderSummary[] {
  if (!providerLabel) {
    return [];
  }

  return [
    {
      label: providerLabel,
      kind: inferProviderKind(providerLabel),
      countryCode,
      confidence: "confirmed",
      lastVerifiedAt: fetchedAt,
      providerUrl,
    },
  ];
}

function inferProviderKind(label: string): ProviderKind {
  const normalized = label.toLowerCase();
  if (normalized.includes("ppv")) {
    return "ppv";
  }
  if (normalized.includes("dazn") || normalized.includes("prime")) {
    return "streaming";
  }

  return "network";
}

function extractVenueLabel(locationLabel: string): string {
  return sanitizeText(locationLabel.split("|")[0] ?? "");
}

function absoluteUrl(input: string): string {
  return sharedAbsoluteUrl(input, OFFICIAL_GOLDEN_BOY_EVENTS_URL);
}

function matchSingle(input: string, pattern: RegExp): string | undefined {
  return sharedMatchSingle(input, pattern);
}

function cleanFighterName(input: string): string {
  return input
    .replace(/"[^"]+"/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function sanitizeText(input: string): string {
  return sharedSanitizeText(input);
}

function monthNumber(name: string): number {
  const normalized = name.trim().toLowerCase().slice(0, 3);
  const months = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"];
  const index = months.indexOf(normalized);
  if (index < 0) {
    throw new Error(`Unknown month: ${name}`);
  }

  return index + 1;
}

function toSlug(input: string): string {
  return sharedToSlug(input);
}

function getErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Unknown error";
}
