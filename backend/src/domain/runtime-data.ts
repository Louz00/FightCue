import type {
  AlertPreferenceSummary,
  EventSummary,
  FighterSummary,
  ProviderConfidence,
  ProviderKind,
  UserProfile,
} from "./models.js";
import {
  getFighterById as getSampleFighterById,
  sampleEvents,
  sampleFighters,
  sampleLeaderboards,
  sampleUserProfile,
} from "./mock-data.js";
import type { PersistedUserState } from "../store/user-state-store.js";

export type HomeResponse = {
  profile: UserProfile;
  fighters: FighterSummary[];
  events: EventSummary[];
};

export type AlertsResponse = {
  fighters: AlertPreferenceSummary[];
  events: AlertPreferenceSummary[];
};

export function buildRuntimeHome(state: PersistedUserState): HomeResponse {
  const profile = buildRuntimeProfile(state);
  const fighters = buildRuntimeFighters(state);
  const events = buildRuntimeEvents(state, profile);

  return {
    profile,
    fighters,
    events,
  };
}

export function buildRuntimeProfile(state: PersistedUserState): UserProfile {
  return {
    ...sampleUserProfile,
    language: state.profile.language,
    timezone: state.profile.timezone,
    viewingCountryCode: state.profile.viewingCountryCode,
    premiumState: state.profile.premiumState,
    analyticsConsent: state.profile.analyticsConsent,
    adConsentGranted: state.profile.adConsentGranted,
    adTier:
      state.profile.premiumState === "premium"
        ? "premium_no_ads"
        : "free_with_ads",
  };
}

export function buildRuntimeFighters(state: PersistedUserState): FighterSummary[] {
  const followedIds = new Set(state.follows.fighterIds);

  return sampleFighters.map((fighter) => ({
    ...fighter,
    isFollowed: followedIds.has(fighter.id),
  }));
}

export function buildRuntimeEvents(
  state: PersistedUserState,
  profile = buildRuntimeProfile(state),
): EventSummary[] {
  const followedEventIds = new Set(state.follows.eventIds);
  const followedFighterIds = new Set(state.follows.fighterIds);

  return sampleEvents.map((event) => {
    const { localDateLabel, localTimeLabel } = formatForTimezone(
      new Date(event.scheduledStartUtc),
      profile.timezone,
    );

    return {
      ...event,
      localDateLabel,
      localTimeLabel,
      selectedCountryCode: profile.viewingCountryCode,
      isFollowed: followedEventIds.has(event.id),
      watchProviders: buildProvidersForCountry(event.id, profile.viewingCountryCode),
      bouts: event.bouts.map((bout) => ({
        ...bout,
        includesFollowedFighter:
          followedFighterIds.has(bout.fighterAId) ||
          followedFighterIds.has(bout.fighterBId),
      })),
    };
  });
}

export function buildRuntimeEventById(
  state: PersistedUserState,
  eventId: string,
): EventSummary | undefined {
  return buildRuntimeEvents(state).find((event) => event.id === eventId);
}

export function buildRuntimeFighterById(
  state: PersistedUserState,
  fighterId: string,
): FighterSummary | undefined {
  const runtimeFighter = buildRuntimeFighters(state).find(
    (fighter) => fighter.id === fighterId,
  );

  if (runtimeFighter) {
    return runtimeFighter;
  }

  return buildSyntheticRankingFighter(state, fighterId);
}

export function buildRuntimeEventsForFighter(
  state: PersistedUserState,
  fighterId: string,
): EventSummary[] {
  return buildRuntimeEvents(state).filter((event) =>
    event.bouts.some(
      (bout) => bout.fighterAId === fighterId || bout.fighterBId === fighterId,
    ),
  );
}

export function buildRuntimeAlerts(state: PersistedUserState): AlertsResponse {
  const followedFighterIds = new Set(state.follows.fighterIds);
  const followedEventIds = new Set(state.follows.eventIds);

  return {
    fighters: [...followedFighterIds].map((fighterId) => ({
      targetId: fighterId,
      presetKeys:
        state.alerts.fighters[fighterId] ??
        ["before_24h", "before_1h", "time_changes"],
    })),
    events: [...followedEventIds].map((eventId) => ({
      targetId: eventId,
      presetKeys:
        state.alerts.events[eventId] ?? ["before_24h", "time_changes", "watch_updates"],
    })),
  };
}

export function buildEventCalendarIcs(event: EventSummary): string {
  const start = toIcsDateTime(event.scheduledStartUtc);
  const end = toIcsDateTime(
    new Date(new Date(event.scheduledStartUtc).getTime() + 3 * 60 * 60 * 1000).toISOString(),
  );
  const location = escapeIcsText(`${event.venueLabel}, ${event.locationLabel}`);
  const description = escapeIcsText(
    `${event.tagline}\nSource: ${event.sourceLabel}\nWatch: ${event.watchProviders
      .map((provider) => provider.label)
      .join(", ")}`,
  );
  const urlLine = event.officialUrl ? `URL:${escapeIcsText(event.officialUrl)}\r\n` : "";

  return [
    "BEGIN:VCALENDAR",
    "VERSION:2.0",
    "PRODID:-//FightCue//EN",
    "CALSCALE:GREGORIAN",
    "BEGIN:VEVENT",
    `UID:${event.id}@fightcue.local`,
    `DTSTAMP:${toIcsDateTime(new Date().toISOString())}`,
    `DTSTART:${start}`,
    `DTEND:${end}`,
    `SUMMARY:${escapeIcsText(`${event.organizationName}: ${event.title}`)}`,
    `DESCRIPTION:${description}`,
    `LOCATION:${location}`,
    urlLine.trimEnd(),
    "END:VEVENT",
    "END:VCALENDAR",
  ]
    .filter((line) => line.length > 0)
    .join("\r\n");
}

function buildSyntheticRankingFighter(
  state: PersistedUserState,
  fighterId: string,
): FighterSummary | undefined {
  const followedIds = new Set(state.follows.fighterIds);

  for (const leaderboard of sampleLeaderboards) {
    for (const entry of leaderboard.entries) {
      if (entry.fighterId === fighterId) {
        return {
          id: entry.fighterId,
          name: entry.fighterName,
          sport: "mma",
          organizationHints: ["ufc"],
          recordLabel: entry.recordLabel ?? "Record pending",
          nationalityLabel: "TBD",
          headline: "Official ranking preview entry.",
          nextAppearanceLabel: leaderboard.weightClass,
          isFollowed: followedIds.has(entry.fighterId),
        };
      }
    }
  }

  return getSampleFighterById(fighterId);
}

function buildProvidersForCountry(
  eventId: string,
  countryCode: string,
): EventSummary["watchProviders"] {
  const normalizedCountryCode = countryCode.toUpperCase();

  const mapping: Record<
    string,
    Record<
      string,
      Array<{
        label: string;
        kind: ProviderKind;
        confidence: ProviderConfidence;
      }>
    >
  > = {
    evt_matchroom_taylor_serrano: {
      NL: [{ label: "DAZN", kind: "streaming", confidence: "confirmed" }],
      GB: [{ label: "DAZN", kind: "streaming", confidence: "confirmed" }],
      US: [{ label: "DAZN", kind: "streaming", confidence: "likely" }],
      ES: [{ label: "DAZN", kind: "streaming", confidence: "confirmed" }],
    },
    evt_ufc_327: {
      NL: [
        {
          label: "Discovery+ / TNT Sports",
          kind: "streaming",
          confidence: "likely",
        },
      ],
      GB: [{ label: "TNT Sports Box Office", kind: "ppv", confidence: "likely" }],
      US: [{ label: "ESPN+ PPV", kind: "ppv", confidence: "likely" }],
      ES: [{ label: "UFC Fight Pass", kind: "streaming", confidence: "unknown" }],
    },
    evt_ufc_fight_night_moicano_duncan: {
      NL: [{ label: "UFC Fight Pass", kind: "streaming", confidence: "likely" }],
      GB: [{ label: "TNT Sports", kind: "tv", confidence: "likely" }],
      US: [{ label: "ESPN+", kind: "streaming", confidence: "likely" }],
      ES: [{ label: "UFC Fight Pass", kind: "streaming", confidence: "unknown" }],
    },
  };

  const fallbackProviders = sampleEvents.find((event) => event.id === eventId)?.watchProviders;
  const configuredProviders =
    mapping[eventId]?.[normalizedCountryCode] ??
    mapping[eventId]?.NL ??
    fallbackProviders?.map((provider) => ({
      label: provider.label,
      kind: provider.kind,
      confidence: normalizeConfidence(provider.confidence),
    })) ??
    [];

  return configuredProviders.map((provider) => ({
    label: provider.label,
    kind: provider.kind,
    countryCode: normalizedCountryCode,
    confidence: provider.confidence,
    lastVerifiedAt: new Date().toISOString(),
  }));
}

function normalizeConfidence(confidenceLabel: string): ProviderConfidence {
  switch (confidenceLabel.toLowerCase()) {
    case "confirmed":
      return "confirmed";
    case "likely":
      return "likely";
    default:
      return "unknown";
  }
}

function formatForTimezone(
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

function normalizeTimeZone(timezone: string): string {
  try {
    new Intl.DateTimeFormat("en-US", { timeZone: timezone }).format(new Date());
    return timezone;
  } catch {
    return sampleUserProfile.timezone;
  }
}

function toIcsDateTime(iso: string): string {
  return iso.replace(/[-:]/g, "").replace(/\.\d{3}Z$/, "Z").replace(/Z$/, "Z");
}

function escapeIcsText(value: string): string {
  return value
    .replace(/\\/g, "\\\\")
    .replace(/\n/g, "\\n")
    .replace(/,/g, "\\,")
    .replace(/;/g, "\\;");
}
