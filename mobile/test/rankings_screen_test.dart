import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fightcue_mobile/src/core/app_strings.dart';
import 'package:fightcue_mobile/src/features/rankings/rankings_screen.dart';
import 'package:fightcue_mobile/src/models/domain_models.dart';

import 'test_fakes.dart';

const _rankings = [
  LeaderboardSummary(
    id: 'lb_men_lightweight',
    title: 'Lightweight',
    organization: 'UFC',
    group: RankingGroup.men,
    weightClass: 'Lightweight',
    sourceLabel: 'Official UFC rankings',
    entries: [
      LeaderboardEntrySummary(
        id: 'entry_1',
        rank: 1,
        fighterId: 'ftr_islam',
        fighterName: 'Islam Makhachev',
        recordLabel: '27-1-0',
        organization: 'UFC',
        isChampion: true,
      ),
    ],
  ),
  LeaderboardSummary(
    id: 'lb_women_strawweight',
    title: 'Women Strawweight',
    organization: 'UFC',
    group: RankingGroup.women,
    weightClass: 'Strawweight',
    sourceLabel: 'Official UFC rankings',
    entries: [
      LeaderboardEntrySummary(
        id: 'entry_2',
        rank: 1,
        fighterId: 'ftr_zhang',
        fighterName: 'Zhang Weili',
        recordLabel: '25-3-0',
        organization: 'UFC',
        isChampion: true,
      ),
    ],
  ),
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Rankings screen loads leaderboards and switches groups', (
    tester,
  ) async {
    final api = FakeFightCueApi(leaderboards: _rankings);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: RankingsScreen(
              api: api,
              strings: AppStrings.of(context),
              onOpenFighter: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leaderboard'), findsWidgets);
    expect(find.text('Lightweight'), findsWidgets);
    expect(find.text('Strawweight'), findsNothing);

    await tester.tap(find.text('Women'));
    await tester.pumpAndSettle();

    expect(find.text('Strawweight'), findsWidgets);
  });

  testWidgets('Rankings screen shows retry notice when loading fails', (
    tester,
  ) async {
    final api = FakeFightCueApi(
      leaderboardsError: StateError('rankings offline'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: RankingsScreen(
              api: api,
              strings: AppStrings.of(context),
              onOpenFighter: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No rankings loaded'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
