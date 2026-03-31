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
  const AppShell({
    super.key,
    this.onLanguageChanged,
  });

  final ValueChanged<String>? onLanguageChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final FightCueApi _api = FightCueApi();
  late final ValueNotifier<HomeSnapshot> _snapshotNotifier;
  late final ValueNotifier<bool> _homeSyncingNotifier;
  late final ValueNotifier<bool> _homeSyncErrorNotifier;

  @override
  void initState() {
    super.initState();
    _snapshotNotifier = ValueNotifier(sampleHomeSnapshot);
    _homeSyncingNotifier = ValueNotifier(false);
    _homeSyncErrorNotifier = ValueNotifier(false);
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _snapshotNotifier.dispose();
    _homeSyncingNotifier.dispose();
    _homeSyncErrorNotifier.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _syncHome();
  }

  Future<void> _syncHome() async {
    _homeSyncingNotifier.value = true;
    _homeSyncErrorNotifier.value = false;

    try {
      final snapshot = await _api.fetchHome();
      _snapshotNotifier.value = snapshot;
      widget.onLanguageChanged?.call(snapshot.languageCode);
      await _mergeLeaderboardFighters();
    } catch (_) {
      _homeSyncErrorNotifier.value = true;
    } finally {
      _homeSyncingNotifier.value = false;
    }
  }

  Future<void> _mergeLeaderboardFighters() async {
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
      // Rankings stay optional so the main event flow remains stable.
    }
  }

  Future<void> _toggleEventFollow(String eventId) async {
    final snapshot = _snapshotNotifier.value;
    final current = snapshot.eventById(eventId);

    if (current == null) {
      return;
    }

    final nextFollowed = !current.isFollowed;
    _snapshotNotifier.value = snapshot.copyWith(
      events: snapshot.events
          .map(
            (event) => event.id == eventId
                ? event.copyWith(isFollowed: nextFollowed)
                : event,
          )
          .toList(),
    );

    try {
      await _api.setEventFollow(eventId, nextFollowed);
      await _syncHome();
    } catch (_) {
      _snapshotNotifier.value = snapshot;
    }
  }

  Future<void> _toggleFighterFollow(String fighterId) async {
    final snapshot = _snapshotNotifier.value;
    final current = snapshot.fighterById(fighterId);

    if (current == null) {
      return;
    }

    final nextFollowed = !current.isFollowed;
    final nextFighters = snapshot.fighters
        .map(
          (fighter) => fighter.id == fighterId
              ? fighter.copyWith(isFollowed: nextFollowed)
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

    try {
      await _api.setFighterFollow(fighterId, nextFollowed);
      await _syncHome();
    } catch (_) {
      _snapshotNotifier.value = snapshot;
    }
  }

  Future<void> _updateLanguage(String languageCode) async {
    final snapshot = _snapshotNotifier.value;

    _snapshotNotifier.value = snapshot.copyWith(languageCode: languageCode);
    widget.onLanguageChanged?.call(languageCode);

    try {
      final updated = await _api.updatePreferences(languageCode: languageCode);
      _snapshotNotifier.value = updated;
      widget.onLanguageChanged?.call(updated.languageCode);
      await _mergeLeaderboardFighters();
    } catch (_) {
      _snapshotNotifier.value = snapshot;
      widget.onLanguageChanged?.call(snapshot.languageCode);
    }
  }

  Future<void> _updateViewingCountry(String countryCode) async {
    final snapshot = _snapshotNotifier.value;

    _snapshotNotifier.value = snapshot.copyWith(viewingCountryCode: countryCode);

    try {
      final updated = await _api.updatePreferences(viewingCountryCode: countryCode);
      _snapshotNotifier.value = updated;
      widget.onLanguageChanged?.call(updated.languageCode);
      await _mergeLeaderboardFighters();
    } catch (_) {
      _snapshotNotifier.value = snapshot;
    }
  }

  void _openEvent(String eventId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EventDetailScreen(
          api: _api,
          snapshotListenable: _snapshotNotifier,
          eventId: eventId,
          onOpenFighter: _openFighter,
          onToggleEventFollow: (targetEventId) {
            unawaited(_toggleEventFollow(targetEventId));
          },
          onToggleFighterFollow: (fighterId) {
            unawaited(_toggleFighterFollow(fighterId));
          },
        ),
      ),
    );
  }

  void _openFighter(String fighterId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FighterProfileScreen(
          api: _api,
          snapshotListenable: _snapshotNotifier,
          fighterId: fighterId,
          onOpenEvent: _openEvent,
          onToggleFighterFollow: (targetFighterId) {
            unawaited(_toggleFighterFollow(targetFighterId));
          },
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
        syncingListenable: _homeSyncingNotifier,
        syncErrorListenable: _homeSyncErrorNotifier,
        strings: strings,
        onOpenEvent: _openEvent,
        onOpenFighter: _openFighter,
        onToggleEventFollow: (eventId) {
          unawaited(_toggleEventFollow(eventId));
        },
        onRetrySync: _syncHome,
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
        onToggleEventFollow: (eventId) {
          unawaited(_toggleEventFollow(eventId));
        },
        onToggleFighterFollow: (fighterId) {
          unawaited(_toggleFighterFollow(fighterId));
        },
      ),
      AlertsScreen(
        api: _api,
        snapshotListenable: _snapshotNotifier,
        strings: strings,
        onOpenEvent: _openEvent,
        onOpenFighter: _openFighter,
      ),
      SettingsScreen(
        snapshotListenable: _snapshotNotifier,
        strings: strings,
        onSelectLanguage: (languageCode) {
          unawaited(_updateLanguage(languageCode));
        },
        onSelectViewingCountry: (countryCode) {
          unawaited(_updateViewingCountry(countryCode));
        },
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
