import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fightcue_mobile/src/data/fightcue_api.dart';
import 'package:fightcue_mobile/src/features/event_detail/event_detail_screen.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';
import 'package:fightcue_mobile/src/models/mock_data.dart';

import 'test_fakes.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Event detail shows saved-detail notice when cached data is used', (
    tester,
  ) async {
    final event = sampleHomeSnapshot.events.first;
    final api = FakeFightCueApi(
      eventDetailResult: ApiFetchResult(
        data: EventDetailSnapshot(
          event: event,
          calendarExportPath: '/v1/events/${event.id}/calendar.ics',
        ),
        isFromCache: true,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EventDetailScreen(
          api: api,
          snapshotListenable: ValueNotifier(sampleHomeSnapshot),
          eventId: event.id,
          onOpenFighter: (_) {},
          onToggleEventFollow: (_) {},
          onToggleFighterFollow: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Showing saved event details'), findsOneWidget);
    expect(find.text(event.title.toUpperCase()), findsOneWidget);
  });

  testWidgets('Event detail falls back to home snapshot when live detail fails', (
    tester,
  ) async {
    final event = sampleHomeSnapshot.events.first;
    final api = FakeFightCueApi(
      eventDetailError: StateError('detail offline'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EventDetailScreen(
          api: api,
          snapshotListenable: ValueNotifier(sampleHomeSnapshot),
          eventId: event.id,
          onOpenFighter: (_) {},
          onToggleEventFollow: (_) {},
          onToggleFighterFollow: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live details unavailable'), findsOneWidget);
    expect(find.text(event.title.toUpperCase()), findsOneWidget);
  });
}
