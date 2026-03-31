import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fightcue_mobile/src/core/app_strings.dart';
import 'package:fightcue_mobile/src/data/fightcue_api.dart';
import 'package:fightcue_mobile/src/features/alerts/alerts_screen.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';
import 'package:fightcue_mobile/src/models/mock_data.dart';

import 'test_fakes.dart';

const _alertsSnapshot = AlertsSnapshot(
  fighterPresetsById: {
    'ftr_katie_taylor': {AlertPreset.before24h, AlertPreset.timeChanges},
  },
  eventPresetsById: {
    'evt_matchroom_taylor_serrano': {
      AlertPreset.before24h,
      AlertPreset.watchUpdates,
    },
  },
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Alerts screen shows tracked fighters and events when alerts load', (
    tester,
  ) async {
    final api = FakeFightCueApi(alertsResult: _alertsSnapshot);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: AlertsScreen(
              api: api,
              snapshotListenable: ValueNotifier(sampleHomeSnapshot),
              strings: AppStrings.of(context),
              onOpenEvent: (_) {},
              onOpenFighter: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KATIE TAYLOR'), findsOneWidget);
    expect(find.text('FIGHTER ALERTS'), findsOneWidget);
    expect(find.text('24 hours before'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('EVENT ALERTS'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('EVENT ALERTS'), findsOneWidget);
  });

  testWidgets('Alerts screen shows fallback notice when alerts fail to load', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      alertsError: StateError('alerts offline'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: AlertsScreen(
              api: api,
              snapshotListenable: ValueNotifier(sampleHomeSnapshot),
              strings: AppStrings.of(context),
              onOpenEvent: (_) {},
              onOpenFighter: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved alerts unavailable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Alerts screen shows cached notice with sync timestamp', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      alertsFetchResult: ApiFetchResult(
        data: _alertsSnapshot,
        isFromCache: true,
        lastSyncedAt: DateTime.utc(2026, 3, 31, 12, 45),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: AlertsScreen(
              api: api,
              snapshotListenable: ValueNotifier(sampleHomeSnapshot),
              strings: AppStrings.of(context),
              onOpenEvent: (_) {},
              onOpenFighter: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showing saved alerts'), findsOneWidget);
    expect(find.textContaining('Last synced:'), findsOneWidget);
  });
}
