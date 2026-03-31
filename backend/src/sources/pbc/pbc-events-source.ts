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

const OFFICIAL_PBC_SCHEDULE_URL =
  "https://www.premierboxingchampions.com/boxing-schedule";
const FIGHT_ROW_MARKER = '<div class="fight-row">';

export async function loadPbcEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const response = await fetch(OFFICIAL_PBC_SCHEDULE_URL, {
      headers: {
        "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
        accept: "text/html,application/xhtml+xml",
      },
    });

    if (!response.ok) {
      throw new Error(`PBC schedule returned ${response.status}`);
    }

    const html = await response.text();
    const reportedUpcomingCount = countPbcFightRows(html);
    const items = parsePbcScheduleHtml(html, query, fetchedAt);

    if (items.length === 0) {
      throw new Error("No PBC upcoming events were parsed");
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
            `PBC parsing is below the detected fight-row count (${items.length}/${reportedUpcomingCount}).`,
          ]
        : [];

    return {
      source: "pbc",
      mode: "live",
      officialUrl: OFFICIAL_PBC_SCHEDULE_URL,
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
      source: "pbc",
      mode: "fallback",
      officialUrl: OFFICIAL_PBC_SCHEDULE_URL,
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: 0,
      health: buildSourceHealth({
        mode: "fallback",
        parsedItemCount: 0,
        checkedPageCount: 0,
      }),
      warnings: [`Live PBC source unavailable: ${getErrorMessage(error)}`],
      items: [],
    };
  }
}

export function countPbcFightRows(html: string): number {
  return html.split(FIGHT_ROW_MARKER).length - 1;
}

export function parsePbcScheduleHtml(
  html: string,
  query: EventSourceQuery,
  fetchedAt: string,
): EventSummary[] {
  const rows = html
    .split(FIGHT_ROW_MARKER)
    .slice(1)
    .map((rowHtml) => `${FIGHT_ROW_MARKER}${rowHtml}`);

  const items: EventSummary[] = [];
  for (const [index, rowHtml] of rows.entries()) {
    const item = parsePbcFightRow(rowHtml, query, fetchedAt, index);
    if (item) {
      items.push(item);
    }
  }

  return items;
}

function parsePbcFightRow(
  rowHtml: string,
  query: EventSourceQuery,
  fetchedAt: string,
  index: number,
): EventSummary | null {
  const fighterNames = [...rowHtml.matchAll(/<span>([^<]+)<\/span>\s*<em><abbr title="versus">vs<\/abbr><\/em>\s*<span>([^<]+)<\/span>/g)]
    .map((match) => ({
      fighterAName: sanitizeText(match[1] ?? ""),
      fighterBName: sanitizeText(match[2] ?? ""),
    }))
    .filter((names) => names.fighterAName && names.fighterBName);
  const mainBout = fighterNames[0];
  if (!mainBout) {
    return null;
  }

  const _dateText = sanitizeText(
    matchSingle(
      rowHtml,
      /<h4 class="schedule-date">[\s\S]*?<span><abbr title="[^"]+">[^<]+<\/abbr><\/span>\s*(\d{2}),\s*(\d{4})/,
    ) ?? "",
  );
  const monthText = sanitizeText(
    matchSingle(
      rowHtml,
      /<h4 class="schedule-date">[\s\S]*?<span><abbr title="([^"]+)">[^<]+<\/abbr><\/span>\s*\d{2},\s*\d{4}/,
    ) ?? "",
  );
  const dayMatch = rowHtml.match(
    /<h4 class="schedule-date">[\s\S]*?<span><abbr title="[^"]+">[^<]+<\/abbr><\/span>\s*(\d{2}),\s*(\d{4})/,
  );
  const timeLabel = sanitizeText(
    matchSingle(rowHtml, /<span class="time">\s*([\s\S]*?)\s*<\/span>/) ?? "",
  );
  const networkLabel = sanitizeText(
    matchSingle(rowHtml, /<h5>(LIVE ON[\s\S]*?)<\/h5>/) ?? "",
  );
  const locationLabel = sanitizeText(
    matchSingle(rowHtml, /<li class="arena">([\s\S]*?)<\/li>/) ?? "",
  );
  const detailUrl = absoluteUrl(
    matchSingle(rowHtml, /<a href="([^"]+)" class="regular-button white">View Fight Night<\/a>/) ??
      "",
  );
  const _watchUrl =
    matchSingle(rowHtml, /<a href="([^"]+)">Watch Live on ([\s\S]*?)<i class="fa fa-angle-right"/) ??
    matchSingle(rowHtml, /<a href="([^"]+)">Watch Live on ([\s\S]*?)<\/a>/);

  if (!monthText || !dayMatch || !locationLabel || !detailUrl) {
    return null;
  }

  const day = Number(dayMatch[1]);
  const year = Number(dayMatch[2]);
  const month = monthNumber(monthText);
  const scheduledStartUtc = parsePbcBroadcastTime(month, day, year, timeLabel);
  const timezone = normalizeTimeZone(query.timezone);
  const { localDateLabel, localTimeLabel } = formatForTimezone(
    new Date(scheduledStartUtc),
    timezone,
  );
  const providerLabel = extractProviderLabel(networkLabel);
  const providerUrl = matchSingle(
    rowHtml,
    /<a href="([^"]+)">Watch Live on [\s\S]*?<i class="fa fa-angle-right"/,
  );
  const title = `${mainBout.fighterAName} vs ${mainBout.fighterBName}`;

  return {
    id: `evt_pbc_${toSlug(detailUrl.split("/").filter(Boolean).pop() ?? `${title}_${index + 1}`)}`,
    organizationSlug: "pbc",
    organizationName: "Premier Boxing Champions",
    sport: "boxing",
    title,
    tagline: "Official PBC fight night tracked from the Premier Boxing Champions schedule.",
    locationLabel,
    venueLabel: extractVenueLabel(locationLabel),
    scheduledStartUtc,
    scheduledTimezone: "America/New_York",
    localDateLabel,
    localTimeLabel,
    eventLocalTimeLabel: timeLabel || providerLabel || "Official PBC local time pending",
    selectedCountryCode: query.selectedCountryCode,
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Official Premier Boxing Champions schedule",
    officialUrl: detailUrl,
    watchProviders: buildWatchProviders(
      query.selectedCountryCode,
      providerLabel,
      providerUrl,
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
        isMainEvent: true,
        includesFollowedFighter: false,
      } satisfies BoutSummary,
    ],
  };
}

function parsePbcBroadcastTime(
  month: number,
  day: number,
  year: number,
  timeLabel: string,
): string {
  const match = timeLabel.match(/(\d{1,2})(?::(\d{2}))?\s*([AP]M)\s*ET/i);
  const hour12 = Number(match?.[1] ?? "20");
  const minutes = Number(match?.[2] ?? "0");
  const meridiem = (match?.[3] ?? "PM").toUpperCase();
  const hour24 = to24Hour(hour12, meridiem);

  const isoSource = `${year}-${pad(month)}-${pad(day)}T${pad(hour24)}:${pad(minutes)}:00-04:00`;
  return new Date(isoSource).toISOString();
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
  if (normalized.includes("prime") || normalized.includes("amazon")) {
    return "streaming";
  }

  return "network";
}

function extractProviderLabel(networkLabel: string): string | undefined {
  const normalized = sanitizeText(
    networkLabel.replace(/^LIVE ON\s*/i, "").replace(/\s{2,}/g, " "),
  );
  return normalized || undefined;
}

function extractVenueLabel(locationLabel: string): string {
  return sanitizeText(locationLabel.split(",")[0] ?? "");
}

function absoluteUrl(input: string): string {
  return sharedAbsoluteUrl(input, OFFICIAL_PBC_SCHEDULE_URL);
}

function matchSingle(input: string, pattern: RegExp): string | undefined {
  return sharedMatchSingle(input, pattern);
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

function to24Hour(hour12: number, meridiem: string): number {
  if (meridiem === "AM") {
    return hour12 === 12 ? 0 : hour12;
  }

  return hour12 === 12 ? 12 : hour12 + 12;
}

function pad(value: number): string {
  return String(value).padStart(2, "0");
}

function toSlug(input: string): string {
  return sharedToSlug(input);
}

function getErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Unknown error";
}
