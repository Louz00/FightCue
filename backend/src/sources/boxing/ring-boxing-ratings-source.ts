import type {
  LeaderboardEntry,
  LeaderboardSummary,
} from "../../domain/models.js";
import { buildSourceHealth } from "../source-health.js";
import type {
  LeaderboardSourcePreview,
  LeaderboardSourceQuery,
} from "../types.js";

const RING_BASE_URL = "https://www.ringmagazine.com/";
const RING_HEADERS = {
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) FightCue/0.1",
  accept: "text/html,application/xhtml+xml",
};
const RING_DIVISION_PAGES = [
  {
    weightClass: "Junior Bantamweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-junior-bantamweight-115-pounds-3Zjpl29txbudWm1LP1fe57",
  },
  {
    weightClass: "Bantamweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-bantamweight-118-pounds-4sqG1DPCG1CZM4QYureI2",
  },
  {
    weightClass: "Junior Featherweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-junior-featherweight-122-pounds-5eb8JHOoP59HtkketW0RSQ",
  },
  {
    weightClass: "Featherweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-featherweight-limit-126-pounds-Pb8LiXs9qLQdmBAQv4EPx",
  },
  {
    weightClass: "Junior Lightweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-junior-lightweight-130-pounds-36ZAyVIlgywqLUK9CK9Wl4",
  },
  {
    weightClass: "Lightweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-lightweight-135-pounds-1vCQ1BcEjGpSCybB7plKVx",
  },
  {
    weightClass: "Junior Welterweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-junior-welterweight-140-pounds-2oafRQRxUcuMERVkiApYJk",
  },
  {
    weightClass: "Welterweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-welterweight-147-pounds-1JpbA8mOAOqGiCRgIt9Si9",
  },
  {
    weightClass: "Junior Middleweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-junior-middleweight-154-pounds-6nLQQXJlz70GQXWSKQoiEv",
  },
  {
    weightClass: "Middleweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-middleweight-160-pounds-7EY0IUAeLwdXyiisSFqyTG",
  },
  {
    weightClass: "Light Heavyweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-light-heavyweight-175-pounds-2IUV4kZVEEnDZPYbt5HbMu",
  },
  {
    weightClass: "Cruiserweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-cruiserweight-200-pounds-dHj1engNXzyaRHoTNs6a6",
  },
  {
    weightClass: "Heavyweight",
    url: "https://www.ringmagazine.com/news/the-ring-ratings-reviewed-2025-heavyweight-4ANmwMLZENy6mGl2R1fq64",
  },
] as const;

export async function loadRingBoxingRatingsPreview(
  query: LeaderboardSourceQuery,
): Promise<LeaderboardSourcePreview> {
  const fetchedAt = new Date().toISOString();

  try {
    const settled = await Promise.allSettled(
      RING_DIVISION_PAGES.map(async (page) => {
        const response = await fetch(page.url, {
          headers: RING_HEADERS,
        });

        if (!response.ok) {
          throw new Error(`${page.weightClass} returned ${response.status}`);
        }

        const html = await response.text();
        const division = parseRingRatingsHtml(html, page.weightClass);

        if (!division) {
          throw new Error(`${page.weightClass} returned no leaderboard rows`);
        }

        return division;
      }),
    );

    const items = settled
      .filter(
        (
          result,
        ): result is PromiseFulfilledResult<LeaderboardSummary> =>
          result.status === "fulfilled",
      )
      .map((result) => result.value);
    const rejected = settled.filter(
      (result): result is PromiseRejectedResult => result.status === "rejected",
    );

    if (items.length === 0) {
      throw new Error("No Ring boxing rating divisions were parsed");
    }

    const health = buildSourceHealth({
      mode: "live",
      parsedItemCount: items.length,
      reportedItemCount: RING_DIVISION_PAGES.length,
      checkedPageCount: RING_DIVISION_PAGES.length,
    });
    const warnings = [
      "The Ring ratings are treated as an editorial source layer for future boxing leaderboards and are not yet surfaced in the in-app rankings tab.",
      "This preview uses a curated set of Ring Ratings Reviewed division pages discovered from the Ring sitemap.",
    ];

    for (const failure of rejected.slice(0, 5)) {
      warnings.push(`Ring ratings page warning: ${getErrorMessage(failure.reason)}`);
    }

    return {
      source: "ring_boxing_ratings",
      mode: "live",
      officialUrl: RING_BASE_URL,
      timezone: query.timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: items.length,
      health,
      warnings,
      items,
    };
  } catch (error) {
    return {
      source: "ring_boxing_ratings",
      mode: "fallback",
      officialUrl: RING_BASE_URL,
      timezone: query.timezone,
      selectedCountryCode: query.selectedCountryCode,
      fetchedAt,
      itemCount: 0,
      health: buildSourceHealth({
        mode: "fallback",
        parsedItemCount: 0,
        checkedPageCount: 0,
      }),
      warnings: [
        `Live Ring boxing ratings unavailable: ${getErrorMessage(error)}`,
      ],
      items: [],
    };
  }
}

export function parseRingRatingsHtml(
  html: string,
  weightClass: string,
): LeaderboardSummary | null {
  const entryRegex =
    /<div[^>]*role="heading"[^>]*>\s*(?:<b>)?(CHAMPION|No\.\s*(\d+))\s*[–-]\s*([^<]+?)(?:<\/b>)?\s*<\/div>[\s\S]*?<div[^>]*>\s*(?:<b>)?RECORD(?:<!-- -->)?(?:<\/b>)?\s*:\s*([^<]+)<\/div>/g;
  const entries: LeaderboardEntry[] = [];

  for (const match of html.matchAll(entryRegex)) {
    const label = sanitizeText(decodeHtmlEntities(match[1] ?? ""));
    const fighterName = sanitizeText(decodeHtmlEntities(match[3] ?? ""));
    const recordLabel = sanitizeText(decodeHtmlEntities(match[4] ?? ""));

    if (!fighterName || !recordLabel) {
      continue;
    }

    entries.push({
      id: `ldb_entry_ring_${toSlug(weightClass)}_${toSlug(fighterName)}`,
      rank: /CHAMPION/i.test(label) ? 0 : Number(match[2]),
      fighterId: `ftr_${toSlug(fighterName)}`,
      fighterName,
      organizationSlug: "ring_boxing",
      recordLabel,
      isChampion: /CHAMPION/i.test(label),
    });
  }

  if (entries.length === 0) {
    return null;
  }

  return {
    id: `ldb_ring_men_${toSlug(weightClass)}`,
    title: `${weightClass} Men`,
    organizationSlug: "ring_boxing",
    organizationName: "The Ring",
    sourceType: "editorial",
    gender: "men",
    weightClass,
    sourceLabel: "The Ring Ratings Reviewed",
    entries,
  };
}

function sanitizeText(input: string): string {
  return input.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
}

function decodeHtmlEntities(input: string): string {
  return input
    .replace(/&#39;|&#x27;/g, "'")
    .replace(/&amp;/g, "&")
    .replace(/&nbsp;/g, " ")
    .replace(/&quot;/g, '"')
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&ndash;/g, "–")
    .replace(/&mdash;/g, "—");
}

function toSlug(input: string): string {
  return sanitizeText(input)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }

  return "Unknown Ring ratings error";
}
