import type {
  EventSummary,
  ProviderConfidence,
  ProviderKind,
  ProviderVerificationSource,
  WatchProviderSummary,
} from "./models.js";

type WatchProviderSeed = {
  label: string;
  kind: ProviderKind;
  confidence: ProviderConfidence;
  providerUrl?: string;
  verificationSource: ProviderVerificationSource;
};

const EVENT_WATCH_PROVIDER_OVERRIDES: Record<
  string,
  Record<string, WatchProviderSeed[]>
> = {
  evt_matchroom_taylor_serrano: {
    NL: [
      {
        label: "DAZN",
        kind: "streaming",
        confidence: "confirmed",
        verificationSource: "event_override",
      },
    ],
    GB: [
      {
        label: "DAZN",
        kind: "streaming",
        confidence: "confirmed",
        verificationSource: "event_override",
      },
    ],
    US: [
      {
        label: "DAZN",
        kind: "streaming",
        confidence: "likely",
        verificationSource: "event_override",
      },
    ],
    ES: [
      {
        label: "DAZN",
        kind: "streaming",
        confidence: "confirmed",
        verificationSource: "event_override",
      },
    ],
  },
  evt_ufc_327: {
    NL: [
      {
        label: "Discovery+ / TNT Sports",
        kind: "streaming",
        confidence: "likely",
        verificationSource: "event_override",
      },
    ],
    GB: [
      {
        label: "TNT Sports Box Office",
        kind: "ppv",
        confidence: "likely",
        verificationSource: "event_override",
      },
    ],
    US: [
      {
        label: "ESPN+ PPV",
        kind: "ppv",
        confidence: "likely",
        verificationSource: "event_override",
      },
    ],
    ES: [
      {
        label: "UFC Fight Pass",
        kind: "streaming",
        confidence: "unknown",
        verificationSource: "event_override",
      },
    ],
  },
  evt_ufc_fight_night_moicano_duncan: {
    NL: [
      {
        label: "UFC Fight Pass",
        kind: "streaming",
        confidence: "likely",
        verificationSource: "event_override",
      },
    ],
    GB: [
      {
        label: "TNT Sports",
        kind: "tv",
        confidence: "likely",
        verificationSource: "event_override",
      },
    ],
    US: [
      {
        label: "ESPN+",
        kind: "streaming",
        confidence: "likely",
        verificationSource: "event_override",
      },
    ],
    ES: [
      {
        label: "UFC Fight Pass",
        kind: "streaming",
        confidence: "unknown",
        verificationSource: "event_override",
      },
    ],
  },
};

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
  switch (event.organizationSlug) {
    case "ufc":
      return countryCode === "US"
        ? [
            {
              label: "ESPN+",
              kind: "streaming",
              confidence: "likely",
              verificationSource: "organization_default",
            },
          ]
        : [
            {
              label: "UFC Fight Pass",
              kind: "streaming",
              confidence: "unknown",
              verificationSource: "organization_default",
            },
          ];
    case "glory":
      return [
        {
          label: "GLORY event page",
          kind: "streaming",
          confidence: "unknown",
          verificationSource: "organization_default",
        },
      ];
    case "one":
      return [
        {
          label: "ONE event page",
          kind: "streaming",
          confidence: "unknown",
          verificationSource: "organization_default",
        },
      ];
    case "matchroom":
      return [
        {
          label: "DAZN",
          kind: "streaming",
          confidence: "likely",
          verificationSource: "organization_default",
        },
      ];
    case "top_rank":
      return [
        {
          label: "ESPN / ESPN+",
          kind: "streaming",
          confidence: "likely",
          verificationSource: "organization_default",
        },
      ];
    case "pbc":
      return [
        {
          label: "PBC event page",
          kind: "streaming",
          confidence: "unknown",
          verificationSource: "organization_default",
        },
      ];
    case "golden_boy":
      return [
        {
          label: "Golden Boy event page",
          kind: "streaming",
          confidence: "unknown",
          verificationSource: "organization_default",
        },
      ];
    case "queensberry":
      return [
        {
          label: "Queensberry event page",
          kind: "streaming",
          confidence: "unknown",
          verificationSource: "organization_default",
        },
      ];
    case "boxxer":
      return [
        {
          label: "BOXXER event page",
          kind: "streaming",
          confidence: "unknown",
          verificationSource: "organization_default",
        },
      ];
    default:
      return [];
  }
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
  }
}
