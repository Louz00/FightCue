export function isSignedDeviceTokenRequired(): boolean {
  const explicit = process.env.FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN;
  if (explicit === "true") {
    return true;
  }
  if (explicit === "false") {
    return false;
  }

  const nodeEnv = (process.env.NODE_ENV ?? "development").toLowerCase();
  return nodeEnv !== "development" && nodeEnv !== "test";
}
