import type {
  AlertPresetKey,
  EventSummary,
  FighterSummary,
  PushDeliveryReadiness,
  PushDueSummary,
  PushPreviewItem,
  PushPreviewSummary,
} from "./models.js";
import { formatForTimezone } from "./time.js";
import type { PersistedUserState } from "../store/user-state-store.js";
import {
  buildRuntimeEvents,
  buildRuntimeFighters,
  buildRuntimeProfile,
} from "./runtime-data.js";

const fighterAlertDefaults: AlertPresetKey[] = [
  "before_24h",
  "before_1h",
  "time_changes",
];

const eventAlertDefaults: AlertPresetKey[] = [
  "before_24h",
  "time_changes",
  "watch_updates",
];

const scheduledOffsetsByReason: Partial<Record<AlertPresetKey, number>> = {
  before_24h: 24 * 60 * 60 * 1000,
  before_1h: 60 * 60 * 1000,
};

export const DEFAULT_PUSH_DISPATCH_LOOKBACK_MS = 15 * 60 * 1000;

export function buildRuntimePushPreview(
  state: PersistedUserState,
  now = new Date(),
): PushPreviewSummary {
  const previewItems = collectPushItems(state, {
    now,
    scheduledWindow: "future",
    includeSignals: true,
    limit: 20,
  });

  const scheduledCount = previewItems.filter(
    (item) => item.deliveryKind === "scheduled",
  ).length;
  const signalCount = previewItems.length - scheduledCount;

  return {
    ...buildPushSettingsSummary(state),
    deliveryReadiness: resolvePushDeliveryReadiness(state),
    scheduledCount,
    signalCount,
    items: previewItems,
  };
}

export function buildRuntimeDuePushSummary(
  state: PersistedUserState,
  now = new Date(),
  lookbackMs = DEFAULT_PUSH_DISPATCH_LOOKBACK_MS,
): PushDueSummary {
  const items = collectPushItems(state, {
    now,
    scheduledWindow: "due",
    dueLookbackMs: lookbackMs,
    includeSignals: false,
    limit: 50,
  });

  return {
    ...buildPushSettingsSummary(state),
    deliveryReadiness: resolvePushDeliveryReadiness(state),
    dueCount: items.length,
    lookbackMinutes: Math.floor(lookbackMs / (60 * 1000)),
    items,
  };
}

function collectPushItems(
  state: PersistedUserState,
  {
    now,
    scheduledWindow,
    includeSignals,
    limit,
    dueLookbackMs = DEFAULT_PUSH_DISPATCH_LOOKBACK_MS,
  }: {
    now: Date;
    scheduledWindow: "future" | "due" | "all";
    includeSignals: boolean;
    limit: number;
    dueLookbackMs?: number;
  },
): PushPreviewItem[] {
  const profile = buildRuntimeProfile(state);
  const events = buildRuntimeEvents(state, profile);
  const fighters = buildRuntimeFighters(state);
  const fightersById = new Map(fighters.map((fighter) => [fighter.id, fighter]));

  const items = new Map<string, PushPreviewItem>();
  const nowMs = now.getTime();

  for (const eventId of state.follows.eventIds) {
    const event = events.find((candidate) => candidate.id === eventId);
    if (!event) {
      continue;
    }

    const presets = state.alerts.events[eventId] ?? eventAlertDefaults;
    for (const preset of presets) {
      const item = buildPreviewItemForEventPreset(
        event,
        preset,
        profile.timezone,
        nowMs,
        scheduledWindow,
        includeSignals,
        dueLookbackMs,
      );
      if (item) {
        items.set(previewDedupKey(item), item);
      }
    }
  }

  for (const fighterId of state.follows.fighterIds) {
    const fighter = fightersById.get(fighterId);
    if (!fighter) {
      continue;
    }

    const presets = state.alerts.fighters[fighterId] ?? fighterAlertDefaults;
    const relatedEvents = events.filter((event) =>
      event.bouts.some(
        (bout) => bout.fighterAId === fighterId || bout.fighterBId === fighterId,
      ),
    );

    for (const event of relatedEvents) {
      for (const preset of presets) {
        const item = buildPreviewItemForFighterPreset(
          fighter,
          event,
          preset,
          profile.timezone,
          nowMs,
          scheduledWindow,
          includeSignals,
          dueLookbackMs,
        );
        if (item) {
          items.set(previewDedupKey(item), item);
        }
      }
    }
  }

  return [...items.values()].sort(comparePushPreviewItems).slice(0, limit);
}

function buildPreviewItemForEventPreset(
  event: EventSummary,
  preset: AlertPresetKey,
  timezone: string,
  nowMs: number,
  scheduledWindow: "future" | "due" | "all",
  includeSignals: boolean,
  dueLookbackMs: number,
): PushPreviewItem | undefined {
  if (preset === "time_changes") {
    if (!includeSignals) {
      return undefined;
    }
    return {
      id: `push_preview_event_${event.id}_${preset}`,
      deliveryKind: "signal",
      reason: preset,
      targetType: "event",
      targetId: event.id,
      eventId: event.id,
      title: event.title,
      body: `FightCue will send an update if the scheduled time changes for ${event.title}.`,
    };
  }

  if (preset === "watch_updates") {
    if (!includeSignals) {
      return undefined;
    }
    return {
      id: `push_preview_event_${event.id}_${preset}`,
      deliveryKind: "signal",
      reason: preset,
      targetType: "event",
      targetId: event.id,
      eventId: event.id,
      title: event.title,
      body: `FightCue will send an update if watch information changes for ${event.title}.`,
    };
  }

  return buildScheduledPreviewItem({
    event,
    preset,
    targetType: "event",
    targetId: event.id,
    title: event.title,
    body:
      preset === "before_24h"
        ? `${event.title} starts in 24 hours.`
        : `${event.title} starts in 1 hour.`,
    timezone,
    nowMs,
    scheduledWindow,
    dueLookbackMs,
  });
}

function buildPreviewItemForFighterPreset(
  fighter: FighterSummary,
  event: EventSummary,
  preset: AlertPresetKey,
  timezone: string,
  nowMs: number,
  scheduledWindow: "future" | "due" | "all",
  includeSignals: boolean,
  dueLookbackMs: number,
): PushPreviewItem | undefined {
  if (preset === "time_changes") {
    if (!includeSignals) {
      return undefined;
    }
    return {
      id: `push_preview_fighter_${fighter.id}_${event.id}_${preset}`,
      deliveryKind: "signal",
      reason: preset,
      targetType: "fighter",
      targetId: fighter.id,
      eventId: event.id,
      title: fighter.name,
      body: `FightCue will send an update if the timing changes for ${fighter.name}'s next event.`,
    };
  }

  if (preset === "watch_updates") {
    if (!includeSignals) {
      return undefined;
    }
    return {
      id: `push_preview_fighter_${fighter.id}_${event.id}_${preset}`,
      deliveryKind: "signal",
      reason: preset,
      targetType: "fighter",
      targetId: fighter.id,
      eventId: event.id,
      title: fighter.name,
      body: `FightCue will send an update if watch information changes for ${fighter.name}'s next event.`,
    };
  }

  return buildScheduledPreviewItem({
    event,
    preset,
    targetType: "fighter",
    targetId: fighter.id,
    title: fighter.name,
    body:
      preset === "before_24h"
        ? `${fighter.name} fights in 24 hours on ${event.title}.`
        : `${fighter.name} fights in 1 hour on ${event.title}.`,
    timezone,
    nowMs,
    scheduledWindow,
    dueLookbackMs,
  });
}

function buildScheduledPreviewItem({
  event,
  preset,
  targetType,
  targetId,
  title,
  body,
  timezone,
  nowMs,
  scheduledWindow,
  dueLookbackMs,
}: {
  event: EventSummary;
  preset: AlertPresetKey;
  targetType: "fighter" | "event";
  targetId: string;
  title: string;
  body: string;
  timezone: string;
  nowMs: number;
  scheduledWindow: "future" | "due" | "all";
  dueLookbackMs: number;
}): PushPreviewItem | undefined {
  const offsetMs = scheduledOffsetsByReason[preset];
  if (offsetMs == null) {
    return undefined;
  }

  const scheduledFor = new Date(new Date(event.scheduledStartUtc).getTime() - offsetMs);
  if (
    !matchesScheduledWindow(
      scheduledFor.getTime(),
      nowMs,
      scheduledWindow,
      dueLookbackMs,
    )
  ) {
    return undefined;
  }

  const { localDateLabel, localTimeLabel } = formatForTimezone(scheduledFor, timezone);

  return {
    id: `push_preview_${targetType}_${targetId}_${event.id}_${preset}`,
    deliveryKind: "scheduled",
    reason: preset,
    targetType,
    targetId,
    eventId: event.id,
    title,
    body,
    scheduledForUtc: scheduledFor.toISOString(),
    scheduledLocalLabel: `${localDateLabel} • ${localTimeLabel}`,
  };
}

function matchesScheduledWindow(
  scheduledForMs: number,
  nowMs: number,
  scheduledWindow: "future" | "due" | "all",
  dueLookbackMs: number,
): boolean {
  switch (scheduledWindow) {
    case "future":
      return scheduledForMs > nowMs;
    case "due":
      return scheduledForMs <= nowMs && scheduledForMs >= nowMs - dueLookbackMs;
    case "all":
    default:
      return true;
  }
}

function resolvePushDeliveryReadiness(
  state: PersistedUserState,
): PushDeliveryReadiness {
  if (!state.push.pushEnabled) {
    return "disabled";
  }
  if (state.push.permissionStatus !== "granted") {
    return "permission_required";
  }
  if (!state.push.tokenValue) {
    return "token_missing";
  }
  return "ready";
}

function buildPushSettingsSummary(state: PersistedUserState) {
  return {
    pushEnabled: state.push.pushEnabled,
    permissionStatus: state.push.permissionStatus,
    tokenPlatform: state.push.tokenPlatform,
    tokenRegistered: Boolean(state.push.tokenValue),
    tokenUpdatedAt: state.push.tokenUpdatedAt,
  };
}

function comparePushPreviewItems(a: PushPreviewItem, b: PushPreviewItem): number {
  if (a.deliveryKind !== b.deliveryKind) {
    return a.deliveryKind === "scheduled" ? -1 : 1;
  }

  if (a.scheduledForUtc && b.scheduledForUtc) {
    return a.scheduledForUtc.localeCompare(b.scheduledForUtc);
  }

  if (a.scheduledForUtc) {
    return -1;
  }
  if (b.scheduledForUtc) {
    return 1;
  }

  return a.id.localeCompare(b.id);
}

function previewDedupKey(item: PushPreviewItem): string {
  return [
    item.deliveryKind,
    item.reason,
    item.eventId ?? "no_event",
    item.targetType,
    item.targetId,
    item.scheduledForUtc ?? "signal",
  ].join(":");
}
