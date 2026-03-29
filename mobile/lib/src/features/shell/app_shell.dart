import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/domain_models.dart';
import '../../models/mock_data.dart';
import '../alerts/alerts_screen.dart';
import '../event_detail/event_detail_screen.dart';
import '../fighter_profile/fighter_profile_screen.dart';
import '../following/following_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  late final ValueNotifier<HomeSnapshot> _snapshotNotifier;

  @override
  void initState() {
    super.initState();
    _snapshotNotifier = ValueNotifier(sampleHomeSnapshot);
  }

  @override
  void dispose() {
    _snapshotNotifier.dispose();
    super.dispose();
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
