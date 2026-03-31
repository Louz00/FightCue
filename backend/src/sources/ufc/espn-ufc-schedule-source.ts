const ESPN_UFC_SCHEDULE_URL = "https://www.espn.com/mma/schedule/_/league/ufc";
const ESPN_PAGE_DATA_MARKER = "window['__espnfitt__']=";
const ESPN_PAGE_DATA_END_MARKER = ";</script>";

type EspnFittPayload = {
  page?: {
    content?: {
      events?: Record<string, EspnScheduleEvent[]>;
      scheduleData?: {
        schedule?: Record<string, EspnScheduleEvent[]>;
      };
    };
  };
};

type EspnScheduleEvent = {
  completed?: boolean;
  isPostponedOrCanceled?: boolean;
  date?: string;
  name?: string;
  broadcasts?: Array<{
    name?: string;
  }>;
};

export type EspnUfcScheduleEvent = {
  title: string;
  scheduledStartUtc?: string;
  broadcastLabels: string[];
};

export async function loadEspnUfcUpcomingSchedule(): Promise<EspnUfcScheduleEvent[]> {
  const response = await fetch(ESPN_UFC_SCHEDULE_URL, {
    headers: {
      "user-agent": "FightCue/0.1 (+https://github.com/Louz00/FightCue)",
      accept: "text/html,application/xhtml+xml",
    },
  });

  if (!response.ok) {
    throw new Error(`ESPN UFC schedule returned ${response.status}`);
  }

  const html = await response.text();
  const schedule = extractEspnSchedulePayload(html);

  return Object.values(schedule)
    .flat()
    .filter((event) => !event.completed && !event.isPostponedOrCanceled && !!event.name)
    .map((event) => ({
      title: sanitizeText(event.name ?? ""),
      scheduledStartUtc: event.date,
      broadcastLabels: (event.broadcasts ?? [])
        .map((broadcast) => sanitizeText(broadcast.name ?? ""))
        .filter((label) => label.length > 0),
    }));
}

function extractEspnSchedulePayload(
  html: string,
): Record<string, EspnScheduleEvent[]> {
  const start = html.indexOf(ESPN_PAGE_DATA_MARKER);
  if (start < 0) {
    throw new Error("Could not find ESPN page data payload");
  }

  const payloadStart = start + ESPN_PAGE_DATA_MARKER.length;
  const end = html.indexOf(ESPN_PAGE_DATA_END_MARKER, payloadStart);
  if (end < 0) {
    throw new Error("Could not find end of ESPN page data payload");
  }

  const rawPayload = html.slice(payloadStart, end);
  const parsed = JSON.parse(rawPayload) as EspnFittPayload;
  const schedule =
    parsed.page?.content?.events ??
    parsed.page?.content?.scheduleData?.schedule;

  if (!schedule || typeof schedule !== "object") {
    throw new Error("Could not read ESPN UFC schedule data");
  }

  return schedule;
}

function sanitizeText(input: string): string {
  return input.replace(/\s+/g, " ").trim();
}
