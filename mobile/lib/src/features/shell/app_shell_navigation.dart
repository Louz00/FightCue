part of 'app_shell.dart';

extension _AppShellNavigation on _AppShellState {
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

  List<Widget> _buildTabs(AppStrings strings) {
    return [
      HomeScreen(
        snapshotListenable: _snapshotNotifier,
        syncingListenable: _homeSyncingNotifier,
        syncErrorListenable: _homeSyncErrorNotifier,
        cachedFallbackListenable: _homeCachedFallbackNotifier,
        lastSyncedAtListenable: _homeLastSyncedAtNotifier,
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
        cachedFallbackListenable: _homeCachedFallbackNotifier,
        lastSyncedAtListenable: _homeLastSyncedAtNotifier,
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
        api: _api,
        snapshotListenable: _snapshotNotifier,
        strings: strings,
        onMonetizationChanged: _applyMonetizationSnapshot,
        onSelectLanguage: (languageCode) {
          unawaited(_updateLanguage(languageCode));
        },
        onSelectViewingCountry: (countryCode) {
          unawaited(_updateViewingCountry(countryCode));
        },
      ),
    ];
  }
}
