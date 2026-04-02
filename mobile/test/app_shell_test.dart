import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fightcue_mobile/src/data/fightcue_api.dart';
import 'package:fightcue_mobile/src/features/shell/app_shell.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';

import 'test_fakes.dart';

const _singleEventSnapshot = HomeSnapshot(
  fighters: [
    FighterSummary(
      id: 'fighter_a',
      name: 'Test Fighter',
      sport: Sport.boxing,
      organizationHint: 'Matchroom',
      recordLabel: '10-0-0',
      nationalityLabel: 'Ireland',
      headline: 'Headline',
      nextAppearanceLabel: 'Sat 18 Apr',
      isFollowed: false,
    ),
  ],
  events: [
    EventSummary(
      id: 'event_1',
      organization: 'Matchroom',
      sport: Sport.boxing,
      title: 'Test Event',
      tagline: 'Single test event',
      locationLabel: 'Dublin, Ireland',
      venueLabel: '3Arena',
      localDateLabel: 'Sat 18 Apr',
      localTimeLabel: '21:00',
      eventLocalTimeLabel: '20:00 local',
      selectedCountryCode: 'NL',
      isFollowed: true,
      sourceLabel: 'Official promoter schedule',
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
          id: 'bout_1',
          slotLabel: 'Main event',
          fighterAId: 'fighter_a',
          fighterAName: 'Test Fighter',
          fighterBId: 'fighter_b',
          fighterBName: 'Other Fighter',
          isMainEvent: true,
          includesFollowedFighter: false,
          weightClass: 'Lightweight',
        ),
      ],
    ),
  ],
  premiumState: PremiumState.free,
  adTier: AdTier.freeWithAds,
  adConsentRequired: true,
  adConsentGranted: false,
  analyticsConsent: false,
  accountModeLabel: 'Anonymous by default, email login optional',
  languageCode: 'en',
  timezone: 'Europe/Amsterdam',
  viewingCountryCode: 'NL',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AppShell shows a saved preview notice when home uses cache', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      homeResult: ApiFetchResult(
        data: _singleEventSnapshot,
        isFromCache: true,
        lastSyncedAt: DateTime.utc(2026, 3, 31, 18, 45),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(api: api),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showing saved preview'), findsOneWidget);
    expect(find.textContaining('Last synced:'), findsOneWidget);
    expect(find.text('Pull down to refresh the live feed.'), findsOneWidget);
    expect(find.text('UPCOMING FIGHTS'), findsOneWidget);
  });

  testWidgets('AppShell rolls back optimistic event follow changes on API error', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      homeResult: const ApiFetchResult(
        data: _singleEventSnapshot,
        isFromCache: false,
      ),
      setEventFollowError: StateError('follow failed'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(api: api),
      ),
    );
    await tester.pumpAndSettle();

    final removeButton = find.ancestor(
      of: find.text('Remove'),
      matching: find.byType(InkWell),
    );

    expect(removeButton, findsWidgets);
    tester.widget<InkWell>(removeButton.first).onTap?.call();
    await tester.pump();
    expect(find.text('Save event'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();
    expect(find.text('Remove'), findsOneWidget);
  });
}
