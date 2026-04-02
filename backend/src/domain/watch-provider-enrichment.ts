import type {
  EventSummary,
  ProviderConfidence,
  ProviderVerificationSource,
  WatchProviderSummary,
} from "./models.js";
import {
  EVENT_WATCH_PROVIDER_OVERRIDES,
  organizationDefaultProvidersForCountry,
  type WatchProviderSeed,
} from "./watch-provider-config.js";

export function enrichWatchProvidersForCountry(
  event: EventSummary,
  countryCode: string,
): WatchProviderSummary[] {
  const normalizedCountryCode = countryCode.toUpperCase();
  const lastVerifiedAt = new Date().toISOString();
  const sourceProviders = normalizeSourceProviders(
    event.watchProviders,
    normalizedCountryCode,
    lastVerifiedAt,
    event.officialUrl,
  );

  const enrichedSeeds = resolveWatchProviderSeeds(event, normalizedCountryCode);
  const enrichedProviders = enrichedSeeds.map((provider) => ({
    label: provider.label,
    kind: provider.kind,
    countryCode: normalizedCountryCode,
    confidence: provider.confidence,
    lastVerifiedAt,
    providerUrl: provider.providerUrl ?? event.officialUrl,
    verificationSource: provider.verificationSource,
  }));

  if (sourceProviders.length > 0) {
    return dedupeProviders([...sourceProviders, ...enrichedProviders]);
  }

  if (enrichedProviders.length > 0) {
    return dedupeProviders(enrichedProviders);
  }

  if (event.officialUrl) {
    return [
      {
        label: `${event.organizationName} event page`,
        kind: "streaming",
        countryCode: normalizedCountryCode,
        confidence: "unknown",
        lastVerifiedAt,
        providerUrl: event.officialUrl,
        verificationSource: "official_page_fallback",
      },
    ];
  }

  return [];
}

function resolveWatchProviderSeeds(
  event: EventSummary,
  countryCode: string,
): WatchProviderSeed[] {
  const eventOverrides =
    EVENT_WATCH_PROVIDER_OVERRIDES[event.id]?.[countryCode] ??
    EVENT_WATCH_PROVIDER_OVERRIDES[event.id]?.NL;
  if (eventOverrides) {
    return eventOverrides;
  }

  if (event.watchProviders.length > 0) {
    return event.watchProviders.map((provider) => ({
      label: provider.label,
      kind: provider.kind,
      confidence: provider.confidence,
      providerUrl: provider.providerUrl,
      verificationSource: "source",
    }));
  }

  return defaultProvidersForOrganization(event, countryCode);
}

function defaultProvidersForOrganization(
  event: EventSummary,
  countryCode: string,
): WatchProviderSeed[] {
  return organizationDefaultProvidersForCountry(
    event.organizationSlug,
    countryCode,
  );
}

function normalizeSourceProviders(
  providers: WatchProviderSummary[],
  countryCode: string,
  lastVerifiedAt: string,
  officialUrl?: string,
): WatchProviderSummary[] {
  return providers.map((provider) => ({
    label: provider.label,
    kind: provider.kind,
    countryCode,
    confidence: provider.confidence,
    lastVerifiedAt: provider.lastVerifiedAt || lastVerifiedAt,
    providerUrl: provider.providerUrl ?? officialUrl,
    verificationSource: provider.verificationSource ?? "source",
  }));
}

function dedupeProviders(providers: WatchProviderSummary[]): WatchProviderSummary[] {
  const deduped = new Map<string, WatchProviderSummary>();

  for (const provider of providers) {
    const key = `${provider.countryCode}:${provider.label.toLowerCase()}:${provider.kind}`;
    const existing = deduped.get(key);
    deduped.set(key, chooseBetterProvider(existing, provider));
  }

  return [...deduped.values()];
}

function chooseBetterProvider(
  existing: WatchProviderSummary | undefined,
  candidate: WatchProviderSummary,
): WatchProviderSummary {
  if (!existing) {
    return candidate;
  }

  const existingVerification = verificationSourceRank(existing.verificationSource);
  const candidateVerification = verificationSourceRank(candidate.verificationSource);
  const existingConfidence = confidenceRank(existing.confidence);
  const candidateConfidence = confidenceRank(candidate.confidence);

  if (
    existing.verificationSource === "source" &&
    existing.confidence === "unknown" &&
    candidate.verificationSource === "event_override" &&
    candidate.confidence !== "unknown"
  ) {
    return candidate;
  }

  if (
    candidateConfidence >= existingConfidence + 2 &&
    candidateVerification >= existingVerification - 1
  ) {
    return candidate;
  }

  if (
    candidateVerification >= existingVerification + 1 &&
    candidateConfidence >= existingConfidence - 1
  ) {
    return candidate;
  }

  const existingScore = providerScore(existing);
  const candidateScore = providerScore(candidate);

  if (candidateScore > existingScore) {
    return candidate;
  }

  return existing;
}

function providerScore(provider: WatchProviderSummary): number {
  const verificationScore = verificationSourceRank(provider.verificationSource);
  const confidenceScore = confidenceRank(provider.confidence);
  const urlScore = provider.providerUrl ? 1 : 0;
  return verificationScore * 100 + confidenceScore * 10 + urlScore;
}

function verificationSourceRank(
  source: ProviderVerificationSource | undefined,
): number {
  switch (source) {
    case "source":
      return 4;
    case "event_override":
      return 3;
    case "organization_default":
      return 2;
    case "official_page_fallback":
      return 1;
    default:
      return 0;
  }
}

function confidenceRank(confidence: ProviderConfidence): number {
  switch (confidence) {
    case "confirmed":
      return 3;
    case "likely":
      return 2;
    case "unknown":
      return 1;
    default:
      return 0;
  }
}
