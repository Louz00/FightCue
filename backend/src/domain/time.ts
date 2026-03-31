import type { EventSummary } from "./models.js";
import { sampleUserProfile } from "./mock-data.js";

export function formatForTimezone(
  date: Date,
  timezone: string,
): { localDateLabel: string; localTimeLabel: string } {
  const safeTimezone = normalizeTimeZone(timezone);
  const parts = new Intl.DateTimeFormat("en-US", {
    weekday: "short",
    day: "numeric",
    month: "short",
    timeZone: safeTimezone,
  }).formatToParts(date);

  const weekday = parts.find((part) => part.type === "weekday")?.value ?? "";
  const day = parts.find((part) => part.type === "day")?.value ?? "";
  const month = parts.find((part) => part.type === "month")?.value ?? "";
  const localDateLabel = `${weekday} ${day} ${month}`.trim();
  const localTimeLabel = new Intl.DateTimeFormat("en-GB", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    timeZone: safeTimezone,
  }).format(date);

  return {
    localDateLabel,
    localTimeLabel,
  };
}

export function normalizeTimeZone(timezone: string): string {
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: timezone }).format(new Date());
    return timezone;
  } catch {
    return sampleUserProfile.timezone;
  }
}

export function compareEventsByStart(left: EventSummary, right: EventSummary): number {
  return (
    new Date(left.scheduledStartUtc).getTime() -
    new Date(right.scheduledStartUtc).getTime()
  );
}
