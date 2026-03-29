import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../models/mock_data.dart';
import '../alerts/alerts_screen.dart';
import '../event_detail/event_detail_screen.dart';
import '../fighter_profile/fighter_profile_screen.dart';
import '../following/following_screen.dart';
import '../home/home_screen.dart';
import '../rankings/rankings_screen.dart';
import '../settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final FightCueApi _api = FightCueApi();
  late final ValueNotifier<HomeSnapshot> _snapshotNotifier;

  @override
  void initState() {
    super.initState();
    _snapshotNotifier = ValueNotifier(sampleHomeSnapshot);
    unawaited(_loadUfcSourcePilot());
    unawaited(_loadLeaderboardFighters());
  }

  @override
  void dispose() {
    _snapshotNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUfcSourcePilot() async {
    try {
      final preview = await _api.fetchUfcEventsPreview();
      final snapshot = _snapshotNotifier.value;

      _snapshotNotifier.value = snapshot.copyWith(
        fighters: _mergePilotFighters(snapshot, preview.items),
        events: _mergePilotEvents(snapshot, preview.items),
      );
    } catch (_) {
      // Keep the curated mock snapshot if the local backend is not available.
    }
  }

  Future<void> _loadLeaderboardFighters() async {
    try {
      final leaderboards = await _api.fetchLeaderboards();
      final snapshot = _snapshotNotifier.value;
      final fightersById = {
        for (final fighter in snapshot.fighters) fighter.id: fighter,
      };
      final fightersByName = {
        for (final fighter in snapshot.fighters) fighter.name.toLowerCase(): fighter,
      };
      final nextFighters = [...snapshot.fighters];

      for (final leaderboard in leaderboards) {
        for (final entry in leaderboard.entries) {
          final existingById = fightersById[entry.fighterId];
          if (existingById != null) {
            continue;
          }

          final existingByName = fightersByName[entry.fighterName.toLowerCase()];
          if (existingByName != null) {
            final updated = existingByName.copyWith(
              recordLabel: entry.recordLabel,
              organizationHint: leaderboard.organization,
            );
            final index = nextFighters.indexOf(existingByName);
            nextFighters[index] = updated;
            fightersById[entry.fighterId] = updated;
            fightersByName[entry.fighterName.toLowerCase()] = updated;
            continue;
          }

          final created = FighterSummary(
            id: entry.fighterId,
            name: entry.fighterName,
            sport: Sport.mma,
            organizationHint: leaderboard.organization,
            recordLabel: entry.recordLabel,
            nationalityLabel: 'TBD',
            headline: 'Official ranking preview fighter entry.',
            nextAppearanceLabel: leaderboard.weightClass,
            isFollowed: false,
          );
          nextFighters.add(created);
          fightersById[entry.fighterId] = created;
          fightersByName[entry.fighterName.toLowerCase()] = created;
        }
      }

      _snapshotNotifier.value = snapshot.copyWith(fighters: nextFighters);
    } catch (_) {
      // Keep the local roster if leaderboards are not available.
    }
  }

  void _toggleEventFollow(String eventId) {
    final snapshot = _snapshotNotifier.value;
    final nextEvents = snapshot.events
        .map(
          (event) => event.id == eventId
              ? event.copyWith(isFollowed: !event.isFollowed)
              : event,
        )
        .toList();

    _snapshotNotifier.value = snapshot.copyWith(events: nextEvents);
  }

  void _toggleFighterFollow(String fighterId) {
    final snapshot = _snapshotNotifier.value;
    final nextFighters = snapshot.fighters
        .map(
          (fighter) => fighter.id == fighterId
              ? fighter.copyWith(isFollowed: !fighter.isFollowed)
              : fighter,
        )
        .toList();
    final followedIds = nextFighters
        .where((fighter) => fighter.isFollowed)
        .map((fighter) => fighter.id)
        .toSet();
    final nextEvents = snapshot.events
        .map(
          (event) => event.copyWith(
            bouts: event.bouts
                .map(
                  (bout) => bout.copyWith(
                    includesFollowedFighter: followedIds.contains(bout.fighterAId) ||
                        followedIds.contains(bout.fighterBId),
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    _snapshotNotifier.value = snapshot.copyWith(
      fighters: nextFighters,
      events: nextEvents,
    );
  }

  List<EventSummary> _mergePilotEvents(
    HomeSnapshot snapshot,
    List<EventSummary> liveUfcEvents,
  ) {
    final existingTitles = {
      for (final event in snapshot.events) event.title.toLowerCase(): event,
    };
    final nonUfcEvents = snapshot.events
        .where((event) => event.organization != 'UFC')
        .toList();
    final mergedUfcEvents = liveUfcEvents
        .map((event) {
          final existing = existingTitles[event.title.toLowerCase()];
          return event.copyWith(isFollowed: existing?.isFollowed ?? false);
        })
        .toList();

    return [...nonUfcEvents, ...mergedUfcEvents];
  }

  List<FighterSummary> _mergePilotFighters(
    HomeSnapshot snapshot,
    List<EventSummary> liveUfcEvents,
  ) {
    final fightersById = {
      for (final fighter in snapshot.fighters) fighter.id: fighter,
    };
    final fightersByName = {
      for (final fighter in snapshot.fighters) fighter.name.toLowerCase(): fighter,
    };
    final nextFighters = [...snapshot.fighters];

    for (final event in liveUfcEvents) {
      for (final bout in event.bouts) {
        _upsertPilotFighter(
          nextFighters,
          fightersById,
          fightersByName,
          fighterId: bout.fighterAId,
          fighterName: bout.fighterAName,
          nextAppearanceLabel: event.localDateLabel,
        );
        _upsertPilotFighter(
          nextFighters,
          fightersById,
          fightersByName,
          fighterId: bout.fighterBId,
          fighterName: bout.fighterBName,
          nextAppearanceLabel: event.localDateLabel,
        );
      }
    }

    return nextFighters;
  }

  void _upsertPilotFighter(
    List<FighterSummary> fighters,
    Map<String, FighterSummary> fightersById,
    Map<String, FighterSummary> fightersByName, {
    required String fighterId,
    required String fighterName,
    required String nextAppearanceLabel,
  }) {
    final existingById = fightersById[fighterId];
    if (existingById != null) {
      return;
    }

    final existingByName = fightersByName[fighterName.toLowerCase()];
    if (existingByName != null) {
      final updated = existingByName.copyWith(
        nextAppearanceLabel: nextAppearanceLabel,
      );
      final index = fighters.indexOf(existingByName);
      fighters[index] = updated;
      fightersById[fighterId] = updated;
      fightersByName[fighterName.toLowerCase()] = updated;
      return;
    }

    final created = FighterSummary(
      id: fighterId,
      name: fighterName,
      sport: Sport.mma,
      organizationHint: 'UFC',
      recordLabel: 'Record pending',
      nationalityLabel: 'TBD',
      headline: 'Official UFC source pilot fighter entry.',
      nextAppearanceLabel: nextAppearanceLabel,
      isFollowed: false,
    );
    fighters.add(created);
    fightersById[fighterId] = created;
    fightersByName[fighterName.toLowerCase()] = created;
  }

  void _openEvent(String eventId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EventDetailScreen(
          snapshotListenable: _snapshotNotifier,
          eventId: eventId,
          onOpenFighter: _openFighter,
          onToggleEventFollow: _toggleEventFollow,
          onToggleFighterFollow: _toggleFighterFollow,
        ),
      ),
    );
  }

  void _openFighter(String fighterId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FighterProfileScreen(
          snapshotListenable: _snapshotNotifier,
          fighterId: fighterId,
          onOpenEvent: _openEvent,
          onToggleFighterFollow: _toggleFighterFollow,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tabs = [
      HomeScreen(
        snapshotListenable: _snapshotNotifier,
        strings: strings,
        onOpenEvent: _openEvent,
        onOpenFighter: _openFighter,
        onToggleEventFollow: _toggleEventFollow,
      ),
      RankingsScreen(
        api: _api,
        strings: strings,
        onOpenFighter: _openFighter,
      ),
      FollowingScreen(
        snapshotListenable: _snapshotNotifier,
        strings: strings,
        onOpenEvent: _openEvent,
        onOpenFighter: _openFighter,
        onToggleEventFollow: _toggleEventFollow,
        onToggleFighterFollow: _toggleFighterFollow,
      ),
      AlertsScreen(
        snapshotListenable: _snapshotNotifier,
        strings: strings,
        onOpenEvent: _openEvent,
        onOpenFighter: _openFighter,
      ),
      SettingsScreen(
        snapshotListenable: _snapshotNotifier,
        strings: strings,
      ),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(child: tabs[index]),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.sports_mma_outlined),
            label: strings.homeNavLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_border),
            label: strings.rankingsNavLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            label: strings.following,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none),
            label: strings.alerts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: strings.settings,
          ),
        ],
      ),
    );
  }
}
