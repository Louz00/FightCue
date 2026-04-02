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
  testWidgets('Favorites screen renders saved fighters and events', (
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
    expect(find.text('Favorites'), findsWidgets);
    expect(find.text('Saved fighters'), findsWidgets);
    expect(find.text('Saved events'), findsWidgets);
  });

  testWidgets('Favorites screen shows empty states when nothing is saved', (
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

    expect(find.text('No saved fighters yet'), findsOneWidget);

    await tester.tap(find.text('Saved events').last);
    await tester.pumpAndSettle();

    expect(find.text('No saved events yet'), findsOneWidget);
  });

  testWidgets('Favorites screen shows cached preview notice when using saved home state', (
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
