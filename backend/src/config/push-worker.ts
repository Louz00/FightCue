export function isPushWorkerEnabled(): boolean {
  return process.env.FIGHTCUE_PUSH_WORKER_ENABLED === "true";
}

export function getPushWorkerIntervalMs(): number {
  const raw = Number(process.env.FIGHTCUE_PUSH_WORKER_INTERVAL_SECONDS ?? 60);
  const seconds = Number.isFinite(raw) && raw >= 15 ? raw : 60;
  return seconds * 1000;
}

export function getPushWorkerLookbackMs(): number {
  const raw = Number(process.env.FIGHTCUE_PUSH_WORKER_LOOKBACK_MINUTES ?? 15);
  const minutes = Number.isFinite(raw) && raw >= 1 ? raw : 15;
  return minutes * 60 * 1000;
}
