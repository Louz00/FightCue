import type {
  AdProviderStatusSummary,
  AdProviderType,
  BillingProviderStatusSummary,
  BillingProviderType,
} from "../domain/models.js";

function parseList(value?: string): string[] {
  return (value ?? "")
    .split(",")
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0);
}

function resolveBillingProvider(): BillingProviderType {
  return process.env.FIGHTCUE_BILLING_PROVIDER === "disabled"
    ? "disabled"
    : "storekit_play";
}

function resolveAdProvider(): AdProviderType {
  return process.env.FIGHTCUE_AD_PROVIDER === "disabled"
    ? "disabled"
    : "google_admob";
}

export function getBillingProviderStatus(): BillingProviderStatusSummary {
  const provider = resolveBillingProvider();
  const productIds = parseList(process.env.FIGHTCUE_BILLING_PRODUCT_IDS);
  const configured = provider !== "disabled" && productIds.length > 0;

  return {
    provider,
    configured,
    supportsProducts: productIds.length > 0,
    productIds,
    description:
      provider === "disabled"
        ? "Store billing is disabled for this backend environment."
        : configured
          ? "FightCue has product identifiers configured for StoreKit and Play Billing."
          : "Store billing wiring is enabled, but no product identifiers are configured yet.",
  };
}

export function getAdProviderStatus(): AdProviderStatusSummary {
  const provider = resolveAdProvider();
  const androidAppId = process.env.FIGHTCUE_ADMOB_APP_ID_ANDROID?.trim() ?? "";
  const iosAppId = process.env.FIGHTCUE_ADMOB_APP_ID_IOS?.trim() ?? "";
  const androidBannerUnit =
    process.env.FIGHTCUE_ADMOB_BANNER_UNIT_ID_ANDROID?.trim() ?? "";
  const iosBannerUnit =
    process.env.FIGHTCUE_ADMOB_BANNER_UNIT_ID_IOS?.trim() ?? "";
  const appIdConfigured = androidAppId.length > 0 || iosAppId.length > 0;
  const bannerUnitConfigured =
    androidBannerUnit.length > 0 || iosBannerUnit.length > 0;
  const configured =
    provider !== "disabled" && appIdConfigured && bannerUnitConfigured;

  return {
    provider,
    configured,
    appIdConfigured,
    bannerUnitConfigured,
    description:
      provider === "disabled"
        ? "Ad delivery is disabled for this backend environment."
        : configured
          ? "FightCue has AdMob app identifiers and banner ad units configured."
          : "AdMob wiring is enabled, but the app IDs or banner unit IDs are still incomplete.",
  };
}
