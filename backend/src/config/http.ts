const DEFAULT_REQUEST_BODY_LIMIT_BYTES = 256 * 1024;

export function requestBodyLimitBytes(): number {
  const rawValue = process.env.FIGHTCUE_MAX_REQUEST_BODY_BYTES?.trim();
  if (!rawValue) {
    return DEFAULT_REQUEST_BODY_LIMIT_BYTES;
  }

  const parsed = Number.parseInt(rawValue, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return DEFAULT_REQUEST_BODY_LIMIT_BYTES;
  }

  return parsed;
}
