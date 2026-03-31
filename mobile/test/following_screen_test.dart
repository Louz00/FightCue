import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/core/app_strings.dart';
import 'package:fightcue_mobile/src/features/following/following_screen.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';
import 'package:fightcue_mobile/src/models/mock_data.dart';

const _emptySnapshot = HomeSnapshot(
  fighters: [],
  events: [],
  premiumState: PremiumState.free,
  adTier: AdTier.freeWithAds,
  adConsentRequired: true,
  adConsentGranted: false,
  analyticsConsent: false,
  accountModeLabel: 'Anonymous',
  languageCode: 'en',
  timezone: 'Europe/Amsterdam',
  viewingCountryCode: 'NL',
);

void main() {
  testWidgets('Following screen renders followed fighters and events', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FollowingScreen(
              snapshotListenable: ValueNotifier(sampleHomeSnapshot),
              cachedFallbackListenable: ValueNotifier(false),
              lastSyncedAtListenable: ValueNotifier(null),
              strings: AppStrings.of(context),
              onOpenEvent: (_) {},
              onOpenFighter: (_) {},
              onToggleEventFollow: (_) {},
              onToggleFighterFollow: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KATIE TAYLOR'), findsOneWidget);
    expect(find.text('Your follows'), findsOneWidget);
    expect(find.text('FOLLOWED FIGHTERS'), findsOneWidget);
    expect(find.text('FOLLOWED EVENTS', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Following screen shows empty states when nothing is followed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FollowingScreen(
              snapshotListenable: ValueNotifier(_emptySnapshot),
              cachedFallbackListenable: ValueNotifier(false),
              lastSyncedAtListenable: ValueNotifier(null),
              strings: AppStrings.of(context),
              onOpenEvent: (_) {},
              onOpenFighter: (_) {},
              onToggleEventFollow: (_) {},
              onToggleFighterFollow: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No followed fighters yet'), findsOneWidget);
    expect(find.text('No followed events yet'), findsOneWidget);
  });

  testWidgets('Following screen shows cached preview notice when using saved home state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FollowingScreen(
              snapshotListenable: ValueNotifier(sampleHomeSnapshot),
              cachedFallbackListenable: ValueNotifier(true),
              lastSyncedAtListenable: ValueNotifier(DateTime.utc(2026, 3, 31, 14, 10)),
              strings: AppStrings.of(context),
              onOpenEvent: (_) {},
              onOpenFighter: (_) {},
              onToggleEventFollow: (_) {},
              onToggleFighterFollow: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showing saved preview'), findsOneWidget);
    expect(find.textContaining('Last synced:'), findsOneWidget);
  });
}
