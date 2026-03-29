import 'domain_models.dart';

const sampleHomeSnapshot = HomeSnapshot(
  premiumState: PremiumState.free,
  accountModeLabel: 'Anonymous by default, email login optional later',
  followedFighters: [
    FighterSummary(
      id: 'ftr_001',
      name: 'Katie Taylor',
      organizationHint: 'Matchroom',
      nextAppearanceLabel: 'Sat 18 Apr',
    ),
    FighterSummary(
      id: 'ftr_002',
      name: 'Alex Pereira',
      organizationHint: 'UFC',
      nextAppearanceLabel: 'Sun 10 May',
    ),
  ],
  events: [
    EventSummary(
      id: 'evt_001',
      organization: 'Matchroom',
      sport: Sport.boxing,
      title: 'Taylor vs Serrano III',
      locationLabel: 'Dublin, Ireland',
      localDateLabel: 'Sat 18 Apr',
      localTimeLabel: '21:00',
      eventLocalTimeLabel: '20:00 local',
      selectedCountryCode: 'NL',
      isFollowed: true,
      watchProviders: [
        WatchProviderSummary(
          label: 'DAZN',
          countryCode: 'NL',
          kind: ProviderKind.streaming,
          confidenceLabel: 'Confirmed',
        ),
      ],
      bouts: [
        BoutSummary(
          id: 'bout_001',
          slotLabel: 'Main event',
          fighterAName: 'Katie Taylor',
          fighterBName: 'Amanda Serrano',
          weightClass: 'Lightweight',
          isMainEvent: true,
          includesFollowedFighter: true,
        ),
        BoutSummary(
          id: 'bout_002',
          slotLabel: 'Co-main',
          fighterAName: 'Fighter A',
          fighterBName: 'Fighter B',
          weightClass: 'Welterweight',
          isMainEvent: false,
          includesFollowedFighter: false,
        ),
      ],
    ),
    EventSummary(
      id: 'evt_002',
      organization: 'UFC',
      sport: Sport.mma,
      title: 'Pereira vs Ankalaev',
      locationLabel: 'Las Vegas, USA',
      localDateLabel: 'Sun 10 May',
      localTimeLabel: '04:00',
      eventLocalTimeLabel: '19:00 local',
      selectedCountryCode: 'NL',
      isFollowed: false,
      watchProviders: [
        WatchProviderSummary(
          label: 'Discovery+ / TNT Sports',
          countryCode: 'NL',
          kind: ProviderKind.streaming,
          confidenceLabel: 'Likely',
        ),
      ],
      bouts: [
        BoutSummary(
          id: 'bout_003',
          slotLabel: 'Main event',
          fighterAName: 'Alex Pereira',
          fighterBName: 'Magomed Ankalaev',
          weightClass: 'Light Heavyweight',
          isMainEvent: true,
          includesFollowedFighter: true,
        ),
        BoutSummary(
          id: 'bout_004',
          slotLabel: 'Co-main',
          fighterAName: 'Fighter C',
          fighterBName: 'Fighter D',
          weightClass: 'Flyweight',
          isMainEvent: false,
          includesFollowedFighter: false,
        ),
      ],
    ),
  ],
);
