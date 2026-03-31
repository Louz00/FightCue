import { formatForTimezone, normalizeTimeZone } from "../../domain/time.js";
import type {
  BoutSummary,
  EventSummary,
  ProviderKind,
  WatchProviderSummary,
} from "../../domain/models.js";
import { buildSourceHealth } from "../source-health.js";
import type { EventSourcePreview, EventSourceQuery } from "../types.js";

const OFFICIAL_BOXXER_EVENTS_API_URL =
  "https://www.boxxer.com/wp-json/wp/v2/posts";
const BOXXER_EVENTS_CATEGORY_ID = 65;
const BOXXER_POSTS_PER_PAGE = 12;

type BoxxerPostSummary = {
  id: number;
  slug: string;
  link: string;
  date: string;
  title: {
    rendered?: string;
  };
};

type BoxxerPostDetail = BoxxerPostSummary & {
  content: {
    rendered?: string;
  };
};

type ParsedBoxxerDate = {
  year: number;
  month: number;
  day: number;
};

export async function loadBoxxerEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const summaries = await fetchBoxxerEventPosts();
    const upcomingSummaries = summaries.filter(isLikelyUpcomingBoxxerEvent);
    const details = await Promise.all(
      upcomingSummaries.map((post) => fetchBoxxerEventDetail(post.id)),
    );
    const items = details
      .map((detail) => mapBoxxerPostToSummary(detail, query, fetchedAt))
      .filter((event): event is EventSummary => event != null)
      .sort((left, right) =>
        left.scheduledStartUtc.localeCompare(right.scheduledStartUtc),
      );

    if (items.length === 0) {
      throw new Error("No BOXXER upcoming events were parsed");
    }

    const health = buildSourceHealth({
      mode: "live",
      parsedItemCount: items.length,
      reportedItemCount: upcomingSummaries.length,
      checkedPageCount: 1,
    });
    const warnings =
      health.status === "degraded" && upcomingSummaries.length > items.length
        ? [
            `BOXXER parsing is below the detected upcoming event-post count (${items.length}/${upcomingSummaries.length}).`,
          ]
        : [];

    return {
      source: "boxxer",
      mode: "live",
      officialUrl: "https://www.boxxer.com/tickets/",
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
      source: "boxxer",
      mode: "fallback",
      officialUrl: "https://www.boxxer.com/tickets/",
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: 0,
      health: buildSourceHealth({
        mode: "fallback",
        parsedItemCount: 0,
        checkedPageCount: 0,
      }),
      warnings: [`Live BOXXER source unavailable: ${getErrorMessage(error)}`],
      items: [],
    };
  }
}

export function isLikelyUpcomingBoxxerEvent(post: BoxxerPostSummary): boolean {
  const title = decodeHtmlEntities(post.title.rendered ?? "");
  const parsedDate = extractBoxxerDateFromText(title, {
    fallbackYear: new Date(post.date).getUTCFullYear(),
  });

  if (parsedDate) {
    const eventDateUtc = Date.UTC(parsedDate.year, parsedDate.month - 1, parsedDate.day);
    const yesterdayUtc = startOfUtcDay(Date.now() - 24 * 60 * 60 * 1000);
    return eventDateUtc >= yesterdayUtc;
  }

  const ninetyDaysAgo = Date.now() - 90 * 24 * 60 * 60 * 1000;
  return new Date(post.date).getTime() >= ninetyDaysAgo;
}

export function mapBoxxerPostToSummary(
  post: BoxxerPostDetail,
  query: EventSourceQuery,
  fetchedAt: string,
): EventSummary | null {
  const title = decodeHtmlEntities(post.title.rendered ?? "");
  const contentHtml = post.content.rendered ?? "";
  const contentText = htmlToText(contentHtml);
  const parsedDate =
    extractBoxxerDateFromText(title, {
      fallbackYear: new Date(post.date).getUTCFullYear(),
    }) ??
    extractBoxxerDateFromText(contentText, {
      fallbackYear: new Date(post.date).getUTCFullYear(),
    });

  if (!parsedDate) {
    return null;
  }

  const mainBout = extractMainBout(title, contentText);
  if (!mainBout) {
    return null;
  }

  const venue = extractVenue(title, contentText) ?? "Venue TBA";
  const locationLabel = extractLocationLabel(title, contentText, venue);
  const scheduledTimezone = inferTimezoneFromLocation(locationLabel);
  const scheduledStartUtc = inferScheduledStartUtc(parsedDate, scheduledTimezone);
  const timezone = normalizeTimeZone(query.timezone);
  const { localDateLabel } = formatForTimezone(new Date(scheduledStartUtc), timezone);
  const watchProviders = buildWatchProviders(
    query.selectedCountryCode,
    contentText,
    extractTicketUrl(contentHtml),
    fetchedAt,
  );

  return {
    id: `evt_boxxer_${post.id}_${toSlug(post.slug)}`,
    organizationSlug: "boxxer",
    organizationName: "BOXXER",
    sport: "boxing",
    title:
      mainBout.fighterBName === "TBA"
        ? `${mainBout.fighterAName} vs TBA`
        : `${mainBout.fighterAName} vs ${mainBout.fighterBName}`,
    tagline: "Official BOXXER event tracked from the BOXXER events API.",
    locationLabel,
    venueLabel: venue,
    scheduledStartUtc,
    scheduledTimezone,
    localDateLabel,
    localTimeLabel: "TBA",
    eventLocalTimeLabel:
      watchProviders.length > 0
        ? `Official BOXXER listing on ${watchProviders[0]?.label}`
        : "Official BOXXER local time pending",
    selectedCountryCode: query.selectedCountryCode,
    status: "scheduled",
    isFollowed: false,
    sourceLabel: "Official BOXXER events API",
    officialUrl: post.link,
    watchProviders,
    bouts: [
      {
        id: `bout_${toSlug(mainBout.fighterAName)}_${toSlug(mainBout.fighterBName)}_1`,
        slotLabel:
          mainBout.fighterBName === "TBA"
            ? "Main event headliner"
            : "Main event",
        fighterAId: `ftr_${toSlug(mainBout.fighterAName)}`,
        fighterAName: mainBout.fighterAName,
        fighterBId: `ftr_${toSlug(mainBout.fighterBName)}`,
        fighterBName: mainBout.fighterBName,
        weightClass: mainBout.weightClass,
        isMainEvent: true,
        includesFollowedFighter: false,
      } satisfies BoutSummary,
    ],
  };
}

async function fetchBoxxerEventPosts(): Promise<BoxxerPostSummary[]> {
  const url = new URL(OFFICIAL_BOXXER_EVENTS_API_URL);
  url.searchParams.set("categories", String(BOXXER_EVENTS_CATEGORY_ID));
  url.searchParams.set("per_page", String(BOXXER_POSTS_PER_PAGE));
  url.searchParams.set(
    "_fields",
    ["id", "slug", "link", "date", "title"].join(","),
  );

  const response = await fetch(url, {
    headers: {
      "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
      accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`BOXXER events API returned ${response.status}`);
  }

  return response.json();
}

async function fetchBoxxerEventDetail(id: number): Promise<BoxxerPostDetail> {
  const url = new URL(`${OFFICIAL_BOXXER_EVENTS_API_URL}/${id}`);
  url.searchParams.set(
    "_fields",
    ["id", "slug", "link", "date", "title", "content"].join(","),
  );

  const response = await fetch(url, {
    headers: {
      "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
      accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`BOXXER event detail ${id} returned ${response.status}`);
  }

  return response.json();
}

function extractMainBout(
  title: string,
  contentText: string,
): {
  fighterAName: string;
  fighterBName: string;
  weightClass?: string;
} | null {
  const titleVsMatch = title.match(
    /([A-Z][A-Za-z.'\- ]+?)\s+vs\.?\s+([A-Z][A-Za-z.'\- ]+)/i,
  );
  if (titleVsMatch) {
    return {
      fighterAName: sanitizeName(titleVsMatch[1] ?? ""),
      fighterBName: sanitizeName(titleVsMatch[2] ?? ""),
      weightClass: extractWeightClass(contentText),
    };
  }

  const defendAgainstMatch = contentText.match(
    /([A-Z][A-Za-z.'\- ]+?)\s+will defend[\s\S]*?\sagainst\s+([A-Z][A-Za-z.'\- ]+)/i,
  );
  if (defendAgainstMatch) {
    return {
      fighterAName: sanitizeName(defendAgainstMatch[1] ?? ""),
      fighterBName: sanitizeName(defendAgainstMatch[2] ?? ""),
      weightClass: extractWeightClass(contentText),
    };
  }

  const facesMatch = contentText.match(
    /([A-Z][A-Za-z.'\- ]+?)\s+(?:faces|takes on)\s+([A-Z][A-Za-z.'\- ]+)/i,
  );
  if (facesMatch) {
    return {
      fighterAName: sanitizeName(facesMatch[1] ?? ""),
      fighterBName: sanitizeName(facesMatch[2] ?? ""),
      weightClass: extractWeightClass(contentText),
    };
  }

  const headlinerSection = contentText.split(/headlined by/i)[1] ?? "";
  const headlinerSentence = headlinerSection.split(/(?:\.|BOXXER Founder)/i)[0] ?? "";
  const headlinedByMatch = headlinerSentence.match(
    /([A-Z][A-Za-z.'\-]+(?:\s+[A-Z][A-Za-z.'\-]+){1,2})/,
  );
  if (headlinedByMatch) {
    return {
      fighterAName: sanitizeName(headlinedByMatch[1] ?? ""),
      fighterBName: "TBA",
      weightClass: extractWeightClass(contentText),
    };
  }

  return null;
}

function extractVenue(title: string, contentText: string): string | undefined {
  const titleMatch = title.match(
    /(?:\d{1,2}\s+[A-Za-z]{3,9}\s+\d{4}|\d{1,2}\s+[A-Za-z]{3,9}),\s*([^,]+(?:,\s*[^,]+)?)$/,
  );
  if (titleMatch) {
    return sanitizeText(titleMatch[1] ?? "");
  }

  const contentMatch = contentText.match(
    /at\s+(?:the\s+)?([A-Z][A-Za-z0-9'&.\- ]+?)\s+in\s+([A-Z][A-Za-z.\- ]+)/i,
  );
  if (contentMatch) {
    return sanitizeText(contentMatch[1] ?? "");
  }

  return undefined;
}

function extractLocationLabel(
  title: string,
  contentText: string,
  venueLabel: string,
): string {
  const contentMatch = contentText.match(
    /at\s+(?:the\s+)?[A-Z][A-Za-z0-9'&.\- ]+?\s+in\s+([A-Z][A-Za-z.\- ]+)/i,
  );
  if (contentMatch) {
    const city = sanitizeText(contentMatch[1] ?? "");
    return `${venueLabel}, ${city}`;
  }

  const titleMatch = title.match(
    /,\s*([^,]+(?:,\s*[^,]+)?)$/,
  );
  return sanitizeText(titleMatch?.[1] ?? venueLabel);
}

export function extractBoxxerDateFromText(
  input: string,
  { fallbackYear }: { fallbackYear: number },
): ParsedBoxxerDate | undefined {
  const monthFirstMatch = input.match(
    /\b(?:Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday),?\s+([A-Za-z]{3,9})\s+(\d{1,2})(?:,?\s+(\d{4}))?/i,
  );
  if (monthFirstMatch) {
    return {
      year: Number(monthFirstMatch[3] ?? fallbackYear),
      month: monthNumber(monthFirstMatch[1] ?? ""),
      day: Number(monthFirstMatch[2]),
    };
  }

  const dayFirstMatch = input.match(/\b(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{4})\b/i);
  if (dayFirstMatch) {
    return {
      year: Number(dayFirstMatch[3]),
      month: monthNumber(dayFirstMatch[2] ?? ""),
      day: Number(dayFirstMatch[1]),
    };
  }

  return undefined;
}

function inferScheduledStartUtc(
  date: ParsedBoxxerDate,
  scheduledTimezone: string,
): string {
  const hourByTimezone =
    scheduledTimezone === "Europe/Amsterdam" ? 19 : 18;
  const offset =
    scheduledTimezone === "Europe/Amsterdam" ? "+02:00" : "+01:00";

  return new Date(
    `${date.year}-${pad(date.month)}-${pad(date.day)}T${pad(hourByTimezone)}:00:00${offset}`,
  ).toISOString();
}

function buildWatchProviders(
  countryCode: string,
  contentText: string,
  ticketUrl: string | undefined,
  fetchedAt: string,
): WatchProviderSummary[] {
  const providers: Array<{ label: string; kind: ProviderKind }> = [];
  const normalized = contentText.toLowerCase();

  if (normalized.includes("bbc two")) {
    providers.push({ label: "BBC Two", kind: "network" });
  }
  if (normalized.includes("bbc iplayer")) {
    providers.push({ label: "BBC iPlayer", kind: "streaming" });
  }
  if (normalized.includes("netflix")) {
    providers.push({ label: "Netflix", kind: "streaming" });
  }
  if (normalized.includes("dazn")) {
    providers.push({ label: "DAZN", kind: "streaming" });
  }

  const seenLabels = new Set<string>();
  return providers
    .filter((provider) => {
      const key = provider.label.toLowerCase();
      if (seenLabels.has(key)) {
        return false;
      }
      seenLabels.add(key);
      return true;
    })
    .map((provider) => ({
      label: provider.label,
      kind: provider.kind,
      countryCode,
      confidence: "confirmed" as const,
      lastVerifiedAt: fetchedAt,
      providerUrl: ticketUrl,
    }));
}

function extractTicketUrl(contentHtml: string): string | undefined {
  const ticketMatch = contentHtml.match(
    /href=\"(https?:\/\/[^\"]+)\"[^>]*>\s*(?:Buy Tickets|Buy Tickets from [^<]+)\s*<\/a>/i,
  );
  return ticketMatch?.[1];
}

function extractWeightClass(contentText: string): string | undefined {
  const match = contentText.match(
    /\b(light heavyweight|heavyweight|cruiserweight|welterweight|middleweight|super middleweight|featherweight|lightweight|super lightweight|bantamweight)\b/i,
  );
  if (!match?.[1]) {
    return undefined;
  }

  return toTitleCase(match[1]);
}

function inferTimezoneFromLocation(locationLabel: string): string {
  const normalized = locationLabel.toLowerCase();

  if (
    normalized.includes("rotterdam") ||
    normalized.includes("netherlands") ||
    normalized.includes("amsterdam")
  ) {
    return "Europe/Amsterdam";
  }

  return "Europe/London";
}

function startOfUtcDay(timestamp: number): number {
  const date = new Date(timestamp);
  return Date.UTC(
    date.getUTCFullYear(),
    date.getUTCMonth(),
    date.getUTCDate(),
  );
}

function monthNumber(input: string): number {
  const normalized = input.toLowerCase();
  const months = [
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
  ];
  const index = months.findIndex((month) => normalized.startsWith(month));
  if (index < 0) {
    throw new Error(`Unknown month token: ${input}`);
  }
  return index + 1;
}

function htmlToText(input: string): string {
  return decodeHtmlEntities(input)
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<\/p>/gi, "\n")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function decodeHtmlEntities(input: string): string {
  return input
    .replace(/&#(\d+);/g, (_, code) => String.fromCharCode(Number(code)))
    .replace(/&amp;/g, "&")
    .replace(/&nbsp;/g, " ")
    .replace(/&quot;/g, "\"")
    .replace(/&#039;/g, "'")
    .replace(/&rsquo;/g, "'")
    .replace(/&ndash;/g, "-")
    .replace(/&mdash;/g, "-")
    .replace(/\u00a0/g, " ");
}

function sanitizeText(input: string): string {
  return input.replace(/\s+/g, " ").trim();
}

function sanitizeName(input: string): string {
  return sanitizeText(input)
    .replace(/\bMBE\b/gi, "")
    .replace(/\bBOXXER\b$/i, "")
    .replace(/[.,;:]+$/g, "")
    .trim();
}

function toTitleCase(input: string): string {
  return input
    .split(/\s+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
    .join(" ");
}

function pad(value: number): string {
  return String(value).padStart(2, "0");
}

function toSlug(input: string): string {
  return input
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function getErrorMessage(error: unknown): string {
  return error instanceof Error ? error.message : "Unknown error";
}
