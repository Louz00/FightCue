import { getTopRankFallbackEvents } from "../../domain/mock-data.js";
import type {
  BoutSummary,
  EventSummary,
  ProviderKind,
  WatchProviderSummary,
} from "../../domain/models.js";
import { formatForTimezone, normalizeTimeZone } from "../../domain/time.js";
import {
  sanitizeText as sharedSanitizeText,
  toSlug as sharedToSlug,
} from "../parse-utils.js";
import { buildSourceHealth } from "../source-health.js";
import type { EventSourcePreview, EventSourceQuery } from "../types.js";

const TOP_RANK_SITE_API_BASE_URL = "https://api.toprank.com/api";

type TopRankApiResponse = {
  data?: TopRankApiEvent[];
  meta?: {
    total?: number;
  };
};

type TopRankApiEvent = {
  id: number;
  slug: string;
  title: string | null;
  type: "upcoming" | "live" | string;
  start: string;
  location_address: string | null;
  online_streaming_link: string | null;
  streaming_networks?: Array<{
    name?: string | null;
  }>;
  get_tickets_link?: string | null;
  is_show_exact_time?: boolean;
  first_fighter?: {
    full_name?: string | null;
    division?: {
      name?: string | null;
    } | null;
  } | null;
  second_fighter?: {
    full_name?: string | null;
  } | null;
};

export async function loadTopRankEventsPreview(
  query: EventSourceQuery,
): Promise<EventSourcePreview> {
  const fetchedAt = new Date().toISOString();
  const timezone = normalizeTimeZone(query.timezone);

  try {
    const response = await fetchTopRankEventList();
    const items = (response.data ?? [])
      .map((event) => mapTopRankEventToSummary(event, query, fetchedAt))
      .filter((event): event is EventSummary => event != null);

    if (items.length === 0) {
      throw new Error("No Top Rank upcoming events were parsed");
    }

    return {
      source: "top_rank",
      mode: "live",
      officialUrl: "https://toprank.com/events/upcoming",
      timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: items.length,
      health: buildSourceHealth({
        mode: "live",
        parsedItemCount: items.length,
        reportedItemCount: response.meta?.total,
        checkedPageCount: 1,
      }),
      warnings: [
        "Top Rank data is sourced from the official Top Rank site API behind the public events page.",
      ],
      items,
    };
  } catch (error) {
    const fallbackItems = getTopRankFallbackEvents();

    return {
      source: "top_rank",
      mode: "fallback",
      officialUrl: "https://toprank.com/events/upcoming",
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
        `Live Top Rank source unavailable: ${getErrorMessage(error)}`,
      ],
      items: fallbackItems,
    };
  }
}

async function fetchTopRankEventList(): Promise<TopRankApiResponse> {
  const url = new URL(`${TOP_RANK_SITE_API_BASE_URL}/admin/events/`);
  url.searchParams.set("page", "1");
  url.searchParams.set("per_page", "8");
  url.searchParams.set("status", "published");
  url.searchParams.append("types[]", "upcoming");
  url.searchParams.append("types[]", "live");
  url.searchParams.set("sort_by", "start");

  const response = await fetch(url, {
    headers: {
      "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
      accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`Top Rank API returned ${response.status}`);
  }

  return response.json();
}

function mapTopRankEventToSummary(
  event: TopRankApiEvent,
  query: EventSourceQuery,
  fetchedAt: string,
): EventSummary | null {
  const fighterAName = sanitizeText(event.first_fighter?.full_name ?? "");
  const fighterBName = sanitizeText(event.second_fighter?.full_name ?? "");

  if (!event.slug || !event.start || !fighterAName || !fighterBName) {
    return null;
  }

  const scheduledStartUtc = new Date(event.start).toISOString();
  const scheduledTimezone = inferTimezoneFromLocation(event.location_address ?? "");
  const timezone = normalizeTimeZone(query.timezone);
  const { localDateLabel, localTimeLabel } = formatForTimezone(
    new Date(scheduledStartUtc),
    timezone,
  );
  const exactTimeKnown = event.is_show_exact_time === true;
  const title =
    sanitizeText(event.title ?? "") || `${fighterAName} vs ${fighterBName}`;
  const locationLabel = sanitizeText(event.location_address ?? "Location TBA");
  const weightClass = sanitizeText(event.first_fighter?.division?.name ?? "");

  return {
    id: `evt_top_rank_${event.slug}`,
    organizationSlug: "top_rank",
    organizationName: "Top Rank",
    sport: "boxing",
    title,
    tagline: "Official Top Rank event sourced from the Top Rank site API.",
    locationLabel,
    venueLabel: extractVenueLabel(locationLabel),
    scheduledStartUtc,
    scheduledTimezone,
    localDateLabel,
    localTimeLabel: exactTimeKnown ? localTimeLabel : "TBA",
    eventLocalTimeLabel: exactTimeKnown
      ? "Official Top Rank start time"
      : "Official Top Rank exact start time pending",
    selectedCountryCode: query.selectedCountryCode,
    status: event.type === "live" ? "estimated" : "scheduled",
    isFollowed: false,
    sourceLabel: "Official Top Rank site API",
    officialUrl: `https://toprank.com/events/${event.slug}`,
    watchProviders: buildWatchProviders(
      event.streaming_networks,
      event.online_streaming_link,
      query.selectedCountryCode,
      fetchedAt,
    ),
    bouts: [
      {
        id: `bout_${toSlug(fighterAName)}_${toSlug(fighterBName)}_1`,
        slotLabel: "Main event",
        fighterAId: `ftr_${toSlug(fighterAName)}`,
        fighterAName,
        fighterBId: `ftr_${toSlug(fighterBName)}`,
        fighterBName,
        weightClass: weightClass || undefined,
        isMainEvent: true,
        includesFollowedFighter: false,
      } satisfies BoutSummary,
    ],
  };
}

function buildWatchProviders(
  networks: TopRankApiEvent["streaming_networks"],
  providerUrl: string | null | undefined,
  countryCode: string,
  fetchedAt: string,
): WatchProviderSummary[] {
  const labels = (networks ?? [])
    .map((network) => sanitizeText(network.name ?? ""))
    .filter(Boolean);

  return labels.map((label) => ({
    label,
    kind: inferProviderKind(label),
    countryCode,
    confidence: "confirmed",
    lastVerifiedAt: fetchedAt,
    providerUrl: providerUrl ?? undefined,
  }));
}

function inferProviderKind(label: string): ProviderKind {
  const normalized = label.toLowerCase();

  if (normalized.includes("ppv")) {
    return "ppv";
  }
  if (normalized.includes("espn")) {
    return "network";
  }
  if (normalized.includes("dazn")) {
    return "streaming";
  }

  return "streaming";
}

function inferTimezoneFromLocation(locationLabel: string): string {
  const normalized = locationLabel.toLowerCase();

  if (
    normalized.includes("new york") ||
    normalized.includes("brooklyn") ||
    normalized.includes("las vegas") ||
    normalized.includes("nevada") ||
    normalized.includes("california")
  ) {
    return "America/New_York";
  }
  if (normalized.includes("tokyo")) {
    return "Asia/Tokyo";
  }

  return "UTC";
}

function extractVenueLabel(locationLabel: string): string {
  const [venue] = locationLabel.split("|");
  return sanitizeText(venue ?? "");
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
