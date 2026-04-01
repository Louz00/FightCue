import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/runtime/app_diagnostics.dart';
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

part 'app_shell_actions.dart';
part 'app_shell_navigation.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.onLanguageChanged,
    this.api,
  });

  final ValueChanged<String>? onLanguageChanged;
  final FightCueApi? api;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  late final FightCueApi _api;
  late final ValueNotifier<HomeSnapshot> _snapshotNotifier;
  late final ValueNotifier<bool> _homeSyncingNotifier;
  late final ValueNotifier<bool> _homeSyncErrorNotifier;
  late final ValueNotifier<bool> _homeCachedFallbackNotifier;
  late final ValueNotifier<DateTime?> _homeLastSyncedAtNotifier;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? FightCueApi();
    _snapshotNotifier = ValueNotifier(sampleHomeSnapshot);
    _homeSyncingNotifier = ValueNotifier(false);
    _homeSyncErrorNotifier = ValueNotifier(false);
    _homeCachedFallbackNotifier = ValueNotifier(false);
    _homeLastSyncedAtNotifier = ValueNotifier(null);
    unawaited(_bootstrap());
  }

  @override
  void dispose() {
    _snapshotNotifier.dispose();
    _homeSyncingNotifier.dispose();
    _homeSyncErrorNotifier.dispose();
    _homeCachedFallbackNotifier.dispose();
    _homeLastSyncedAtNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tabs = _buildTabs(strings);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(color: AppColors.backgroundFor(context)),
        child: SafeArea(child: tabs[index]),
      ),
      bottomNavigationBar: Semantics(
        container: true,
        label: strings.navigationSectionsLabel,
        child: NavigationBar(
          height: 72,
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.sports_mma_outlined),
              tooltip: strings.homeNavLabel,
              label: strings.homeNavLabel,
            ),
            NavigationDestination(
              icon: const Icon(Icons.star_border),
              tooltip: strings.rankingsNavLabel,
              label: strings.rankingsNavLabel,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark_border),
              tooltip: strings.following,
              label: strings.following,
            ),
            NavigationDestination(
              icon: const Icon(Icons.notifications_none),
              tooltip: strings.alerts,
              label: strings.alerts,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              tooltip: strings.settings,
              label: strings.settings,
            ),
          ],
        ),
      ),
    );
  }
}
