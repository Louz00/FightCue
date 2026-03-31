import type {
  LeaderboardEntry,
  LeaderboardSummary,
} from "../../domain/models.js";
import { buildSourceHealth } from "../source-health.js";
import type {
  LeaderboardSourcePreview,
  LeaderboardSourceQuery,
} from "../types.js";

const ESPN_BOXING_RANKINGS_URL =
  "https://www.espn.com/boxing/story/_/id/21675272/divisional-rankings-best-top-10-fighters-per-division";
const ESPN_WOMENS_BOXING_RANKINGS_URL =
  "https://www.espn.com/boxing/story/_/id/32533891/women-boxing-divisional-rankings-best-top-10-women-fighters-per-division";
const ESPN_HEADERS = {
  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) FightCue/0.1",
  accept: "text/html,application/xhtml+xml",
};

export async function loadEspnBoxingRankingsPreview(
  query: LeaderboardSourceQuery,
): Promise<LeaderboardSourcePreview> {
  const fetchedAt = new Date().toISOString();

  try {
    const [mensResponse, womensResponse] = await Promise.all([
      fetch(ESPN_BOXING_RANKINGS_URL, {
        headers: ESPN_HEADERS,
      }),
      fetch(ESPN_WOMENS_BOXING_RANKINGS_URL, {
        headers: ESPN_HEADERS,
      }),
    ]);

    if (!mensResponse.ok) {
      throw new Error(
        `ESPN men's boxing rankings returned ${mensResponse.status}`,
      );
    }

    if (!womensResponse.ok) {
      throw new Error(
        `ESPN women's boxing rankings returned ${womensResponse.status}`,
      );
    }

    const [mensHtml, womensHtml] = await Promise.all([
      mensResponse.text(),
      womensResponse.text(),
    ]);
    const mensParsed = parseEspnBoxingRankingsHtml(mensHtml, "men");
    const womensParsed = parseEspnBoxingRankingsHtml(womensHtml, "women");
    const items = [...mensParsed.items, ...womensParsed.items];
    const reportedItemCount =
      mensParsed.reportedItemCount + womensParsed.reportedItemCount;

    if (items.length === 0) {
      throw new Error("No ESPN boxing leaderboard divisions were parsed");
    }

    const health = buildSourceHealth({
      mode: "live",
      parsedItemCount: items.length,
      reportedItemCount,
      checkedPageCount: 2,
    });
    const warnings = [
      "ESPN boxing rankings are treated as an editorial source layer for future boxing leaderboards and are not yet surfaced in the in-app rankings tab.",
    ];

    if (health.status === "degraded") {
      warnings.push(
        `ESPN boxing rankings parsing is below the detected division count (${items.length}/${reportedItemCount}).`,
      );
    }

    return {
      source: "espn_boxing_rankings",
      mode: "live",
      officialUrl: ESPN_BOXING_RANKINGS_URL,
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
      source: "espn_boxing_rankings",
      mode: "fallback",
      officialUrl: ESPN_BOXING_RANKINGS_URL,
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
        `Live ESPN boxing rankings unavailable: ${getErrorMessage(error)}`,
      ],
      items: [],
    };
  }
}

export function parseEspnBoxingRankingsHtml(
  html: string,
  gender: LeaderboardSummary["gender"],
): {
  items: LeaderboardSummary[];
  reportedItemCount: number;
} {
  const rankingsSection = extractEspnRankingsSection(html);
  const divisions = findEspnDivisionSections(rankingsSection);
  const items = divisions
    .map(({ heading, sectionHtml }) =>
      parseEspnDivisionSection(sectionHtml, heading, gender),
    )
    .filter((division): division is LeaderboardSummary => division != null);

  return {
    items,
    reportedItemCount: divisions.length,
  };
}

function extractEspnRankingsSection(html: string): string {
  const anchor = html.indexOf("For a list of the current champions");
  if (anchor < 0) {
    return html;
  }

  return html.slice(anchor);
}

function findEspnDivisionSections(
  html: string,
): Array<{ heading: string; sectionHtml: string }> {
  const headingRegex = /<h2>([^<]+)<\/h2>/g;
  const matches = [...html.matchAll(headingRegex)]
    .map((match) => ({
      heading: sanitizeText(decodeHtmlEntities(match[1] ?? "")),
      index: match.index ?? 0,
      matchLength: match[0].length,
    }))
    .filter(({ heading }) => isEspnDivisionHeading(heading));

  return matches.map((match, index) => {
    const sectionStart = match.index + match.matchLength;
    const sectionEnd = matches[index + 1]?.index ?? html.length;

    return {
      heading: match.heading,
      sectionHtml: html.slice(sectionStart, sectionEnd),
    };
  });
}

function isEspnDivisionHeading(heading: string): boolean {
  return /weight/i.test(heading) && !/^\d+\./.test(heading);
}

function parseEspnDivisionSection(
  sectionHtml: string,
  heading: string,
  gender: LeaderboardSummary["gender"],
): LeaderboardSummary | null {
  const entryRegex =
    gender === "women"
      ? /<h3>(\d+)\.\s*([^<]+?)<\/h3>[\s\S]*?<b>Record:<\/b>\s*([^<]+?)(?:<br|<\/p>)/g
      : /<h2>(\d+)\.\s*([^<]+?)(?:,\s*<i>([^<]+)<\/i>)?<\/h2>[\s\S]*?<b>Record:<\/b>\s*([^<]+?)(?:<br|<\/div>)/g;
  const entries: LeaderboardEntry[] = [];

  for (const match of sectionHtml.matchAll(entryRegex)) {
    const rank = Number(match[1]);
    const fighterName = sanitizeText(decodeHtmlEntities(match[2] ?? ""));
    const label = gender === "women" ? "" : sanitizeText(decodeHtmlEntities(match[3] ?? ""));
    const recordLabel = sanitizeText(
      decodeHtmlEntities(gender === "women" ? match[3] ?? "" : match[4] ?? ""),
    );

    if (!fighterName || Number.isNaN(rank)) {
      continue;
    }

    entries.push({
      id: `ldb_entry_espn_${gender}_${toSlug(heading)}_${rank}`,
      rank,
      fighterId: `ftr_${toSlug(fighterName)}`,
      fighterName,
      organizationSlug: "espn_boxing",
      recordLabel,
      isChampion: /champion/i.test(label),
      pointsLabel: label || undefined,
    });
  }

  if (entries.length === 0) {
    return null;
  }

  const weightClass = normalizeEspnWeightClass(heading);

  return {
    id: `ldb_espn_${gender}_${toSlug(weightClass)}`,
    title: `${weightClass} ${gender === "women" ? "Women" : "Men"}`,
    organizationSlug: "espn_boxing",
    organizationName: "ESPN Boxing",
    sourceType: "editorial",
    gender,
    weightClass,
    sourceLabel: "ESPN divisional rankings",
    entries,
  };
}

function normalizeEspnWeightClass(heading: string): string {
  const base = sanitizeText(heading.replace(/\s*\([^)]*\)\s*$/, ""));
  return base
    .toLowerCase()
    .split(/[\s-]+/)
    .filter(Boolean)
    .map((segment) => segment[0]!.toUpperCase() + segment.slice(1))
    .join(" ");
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
    .replace(/&gt;/g, ">");
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

  return "Unknown ESPN boxing rankings error";
}
