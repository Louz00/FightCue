import type {
  ProviderConfidence,
  ProviderKind,
  ProviderVerificationSource,
} from "./models.js";

export type WatchProviderSeed = {
  label: string;
  kind: ProviderKind;
  confidence: ProviderConfidence;
  providerUrl?: string;
  verificationSource: ProviderVerificationSource;
};

export const EVENT_WATCH_PROVIDER_OVERRIDES: Record<
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

export const ORGANIZATION_DEFAULT_WATCH_PROVIDERS: Record<string, WatchProviderSeed[]> = {
  ufc: [
    {
      label: "UFC Fight Pass",
      kind: "streaming",
      confidence: "unknown",
      verificationSource: "organization_default",
    },
  ],
  glory: [
    {
      label: "GLORY event page",
      kind: "streaming",
      confidence: "unknown",
      verificationSource: "organization_default",
    },
  ],
  one: [
    {
      label: "ONE event page",
      kind: "streaming",
      confidence: "unknown",
      verificationSource: "organization_default",
    },
  ],
  matchroom: [
    {
      label: "DAZN",
      kind: "streaming",
      confidence: "likely",
      verificationSource: "organization_default",
    },
  ],
  top_rank: [
    {
      label: "ESPN / ESPN+",
      kind: "streaming",
      confidence: "likely",
      verificationSource: "organization_default",
    },
  ],
  pbc: [
    {
      label: "PBC event page",
      kind: "streaming",
      confidence: "unknown",
      verificationSource: "organization_default",
    },
  ],
  golden_boy: [
    {
      label: "Golden Boy event page",
      kind: "streaming",
      confidence: "unknown",
      verificationSource: "organization_default",
    },
  ],
  queensberry: [
    {
      label: "Queensberry event page",
      kind: "streaming",
      confidence: "unknown",
      verificationSource: "organization_default",
    },
  ],
  boxxer: [
    {
      label: "BOXXER event page",
      kind: "streaming",
      confidence: "unknown",
      verificationSource: "organization_default",
    },
  ],
};

export function organizationDefaultProvidersForCountry(
  organizationSlug: string,
  countryCode: string,
): WatchProviderSeed[] {
  if (organizationSlug === "ufc" && countryCode === "US") {
    return [
      {
        label: "ESPN+",
        kind: "streaming",
        confidence: "likely",
        verificationSource: "organization_default",
      },
    ];
  }

  return ORGANIZATION_DEFAULT_WATCH_PROVIDERS[organizationSlug] ?? [];
}
