export function isSignedDeviceTokenRequired(): boolean {
  return process.env.FIGHTCUE_REQUIRE_SIGNED_DEVICE_TOKEN === "true";
}
