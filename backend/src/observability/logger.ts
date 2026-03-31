type LogLevel = "info" | "warn" | "error";

type LogPayload = Record<string, unknown>;

export function logInfo(event: string, payload: LogPayload = {}): void {
  emitStructuredLog("info", event, payload);
}

export function logWarn(event: string, payload: LogPayload = {}): void {
  emitStructuredLog("warn", event, payload);
}

export function logError(event: string, payload: LogPayload = {}): void {
  emitStructuredLog("error", event, payload);
}

function emitStructuredLog(level: LogLevel, event: string, payload: LogPayload): void {
  const serialized = JSON.stringify({
    service: "fightcue-backend",
    event,
    level,
    timestamp: new Date().toISOString(),
    ...payload,
  });

  switch (level) {
    case "error":
      console.error(serialized);
      return;
    case "warn":
      console.warn(serialized);
      return;
    default:
      console.info(serialized);
  }
}
