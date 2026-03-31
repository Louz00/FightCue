import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/models/domain_models.dart';
import 'package:fightcue_mobile/src/models/event_summary_utils.dart';

void main() {
  const baseEvent = EventSummary(
    id: 'evt_test',
    organization: 'UFC',
    sport: Sport.mma,
    title: 'Test Event',
    tagline: 'Test tagline',
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

  test('headlineBoutForEvent returns null when the card is empty', () {
    expect(headlineBoutForEvent(baseEvent), isNull);
  });

  test('headlineBoutForEvent prefers the marked main event', () {
    final event = baseEvent.copyWith(
      bouts: const [
        BoutSummary(
          id: 'bout_1',
          slotLabel: 'Co-main',
          fighterAId: 'f1',
          fighterAName: 'Fighter A',
          fighterBId: 'f2',
          fighterBName: 'Fighter B',
          isMainEvent: false,
          includesFollowedFighter: false,
        ),
        BoutSummary(
          id: 'bout_2',
          slotLabel: 'Main event',
          fighterAId: 'f3',
          fighterAName: 'Fighter C',
          fighterBId: 'f4',
          fighterBName: 'Fighter D',
          isMainEvent: true,
          includesFollowedFighter: false,
        ),
      ],
    );

    expect(headlineBoutForEvent(event)?.id, 'bout_2');
  });

  test('primaryWatchProviderLabel safely handles empty providers', () {
    expect(primaryWatchProviderLabel(baseEvent), isNull);

    final event = baseEvent.copyWith(
      watchProviders: const [
        WatchProviderSummary(
          label: 'ESPN+',
          countryCode: 'US',
          kind: ProviderKind.streaming,
          confidenceLabel: 'likely',
        ),
      ],
    );

    expect(primaryWatchProviderLabel(event), 'ESPN+');
  });
}
