import type { EventSummary } from "./models.js";
import { normalizeTimeZone } from "./time.js";

export function filterUniqueBoxingEventsAgainstExisting(
  existingEvents: EventSummary[],
  candidateEvents: EventSummary[],
): EventSummary[] {
  const existingKeys = new Set(
    existingEvents
      .filter((event) => event.sport === "boxing")
      .map(buildBoxingEventKey)
      .filter((key): key is string => key != null),
  );

  return candidateEvents.filter((event) => {
    if (event.sport !== "boxing") {
      return true;
    }

    const key = buildBoxingEventKey(event);
    if (!key) {
      return true;
    }

    if (existingKeys.has(key)) {
      return false;
    }

    existingKeys.add(key);
    return true;
  });
}

export function buildBoxingEventKey(event: EventSummary): string | undefined {
  if (event.sport !== "boxing") {
    return undefined;
  }

  const mainBout = event.bouts.find((bout) => bout.isMainEvent) ?? event.bouts[0];
  if (!mainBout) {
    return undefined;
  }

  const fighters = [
    normalizeFighterName(mainBout.fighterAName),
    normalizeFighterName(mainBout.fighterBName),
  ].sort();
  const dateKey = buildLocalDateKey(event);

  return `${dateKey}:${fighters.join(":")}`;
}

function buildLocalDateKey(event: EventSummary): string {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    timeZone: normalizeTimeZone(event.scheduledTimezone),
  });
  const parts = formatter.formatToParts(new Date(event.scheduledStartUtc));
  const year = parts.find((part) => part.type === "year")?.value ?? "0000";
  const month = parts.find((part) => part.type === "month")?.value ?? "00";
  const day = parts.find((part) => part.type === "day")?.value ?? "00";

  return `${year}-${month}-${day}`;
}

function normalizeFighterName(input: string): string {
  const normalized = input
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .trim();

  const parts = normalized.split(" ").filter(Boolean);
  if (parts.length === 0) {
    return normalized;
  }

  const last = parts.at(-1) ?? normalized;
  if (isSuffixToken(last) && parts.length > 1) {
    return parts.at(-2) ?? normalized;
  }

  return last;
}

function isSuffixToken(token: string): boolean {
  return ["jr", "sr", "ii", "iii", "iv", "v"].includes(token);
}
