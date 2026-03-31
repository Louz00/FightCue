import type { EventSummary } from "../../domain/models.js";
import type { EspnUfcScheduleEvent } from "./espn-ufc-schedule-source.js";

export function buildEspnValidationWarnings(
  officialItems: EventSummary[],
  espnItems: EspnUfcScheduleEvent[],
): string[] {
  if (officialItems.length === 0 || espnItems.length === 0) {
    return [];
  }

  const officialKeys = new Set(
    officialItems.map((item) => normalizeUfcEventTitleForComparison(item.title)),
  );
  const missingEspnItems = espnItems.filter(
    (item) => !officialKeys.has(normalizeUfcEventTitleForComparison(item.title)),
  );
  const warnings: string[] = [];

  if (missingEspnItems.length > 0) {
    const previewTitles = missingEspnItems
      .slice(0, 3)
      .map((item) => item.title)
      .join(", ");

    warnings.push(
      `ESPN UFC schedule lists ${missingEspnItems.length} upcoming event(s) not currently matched by the official UFC parser: ${previewTitles}.`,
    );
  }

  if (espnItems.length !== officialItems.length) {
    warnings.push(
      `Secondary UFC validation count differs from ESPN (${officialItems.length} from UFC.com vs ${espnItems.length} from ESPN).`,
    );
  }

  return [...new Set(warnings)];
}

export function normalizeUfcEventTitleForComparison(title: string): string {
  return normalizeText(stripUfcPrefix(title))
    .replace(/\bvs\.?\b/g, "vs")
    .replace(/[^a-z0-9\s]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function stripUfcPrefix(title: string): string {
  const normalized = title.trim();
  const separatorIndex = normalized.indexOf(":");

  if (separatorIndex >= 0) {
    return normalized.slice(separatorIndex + 1).trim();
  }

  return normalized.replace(/^ufc(?:\s+fight\s+night|\s+\d+|\s+freedom\s+\d+)?\s*/i, "");
}

function normalizeText(value: string): string {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

