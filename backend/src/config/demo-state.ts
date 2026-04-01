export function isDemoSeedStateEnabled(): boolean {
  return process.env.FIGHTCUE_SEED_DEMO_STATE === "true";
}
