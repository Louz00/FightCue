import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/models/domain_models.dart';

void main() {
  test('FighterSummary.copyWith keeps existing values when fields are omitted', () {
    const fighter = FighterSummary(
      id: 'ftr_1',
      name: 'Renato Moicano',
      sport: Sport.mma,
      organizationHint: 'UFC',
      recordLabel: '20-7-1',
      nationalityLabel: 'Brazil',
      headline: 'Upcoming UFC fighter',
      nextAppearanceLabel: 'Apr 5',
      isFollowed: false,
    );

    final updated = fighter.copyWith(isFollowed: true);

    expect(updated.name, fighter.name);
    expect(updated.organizationHint, fighter.organizationHint);
    expect(updated.isFollowed, isTrue);
  });

  test('EventSummary.copyWith safely replaces bouts and providers', () {
    const event = EventSummary(
      id: 'evt_1',
      organization: 'UFC',
      sport: Sport.mma,
      title: 'Moicano vs Duncan',
      tagline: 'Fight Night',
      locationLabel: 'Las Vegas',
      venueLabel: 'APEX',
      localDateLabel: 'Sun 5 Apr',
      localTimeLabel: '02:00',
      eventLocalTimeLabel: 'Sat 4 Apr • 8:00 PM EDT',
      selectedCountryCode: 'NL',
      isFollowed: false,
      sourceLabel: 'Official UFC events page',
      watchProviders: [],
      bouts: [],
    );

    final updated = event.copyWith(
      isFollowed: true,
      watchProviders: const [
        WatchProviderSummary(
          label: 'ESPN+',
          countryCode: 'US',
          kind: ProviderKind.streaming,
          confidenceLabel: 'likely',
        ),
      ],
      bouts: const [
        BoutSummary(
          id: 'bout_1',
          slotLabel: 'Main event',
          fighterAId: 'ftr_a',
          fighterAName: 'Renato Moicano',
          fighterBId: 'ftr_b',
          fighterBName: 'Chris Duncan',
          isMainEvent: true,
          includesFollowedFighter: false,
        ),
      ],
    );

    expect(updated.isFollowed, isTrue);
    expect(updated.watchProviders.single.label, 'ESPN+');
    expect(updated.bouts.single.fighterAName, 'Renato Moicano');
  });
}

