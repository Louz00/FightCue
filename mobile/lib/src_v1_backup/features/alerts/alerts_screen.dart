import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/runtime/app_diagnostics.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../models/event_summary_utils.dart';
import '../../widgets/editorial_ui.dart';
import '../../widgets/fighter_avatar.dart';

part 'alerts_content.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({
    super.key,
    required this.api,
    required this.snapshotListenable,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
  });

  final FightCueApi api;
  final ValueListenable<HomeSnapshot> snapshotListenable;
  final AppStrings strings;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenFighter;

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AlertsSnapshot? _alerts;
  bool _isLoading = false;
  bool _loadFailed = false;
  bool _usingCachedFallback = false;
  DateTime? _lastSyncedAt;
  bool _didRequestStaleRefresh = false;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts({bool resetStaleRefresh = true}) async {
    if (!mounted) {
      return;
    }

    if (resetStaleRefresh) {
      _didRequestStaleRefresh = false;
    }

    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final result = await widget.api.fetchAlertsResult();
      final alerts = result.data;
      if (!mounted) {
        return;
      }

      setState(() {
        _alerts = alerts;
        _loadFailed = false;
        _usingCachedFallback = result.isFromCache;
        _lastSyncedAt = result.lastSyncedAt;
      });
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'alerts.load');
      if (!mounted) {
        return;
      }

      setState(() {
        _loadFailed = true;
        _usingCachedFallback = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFighterPreset(
    String fighterId,
    AlertPreset preset,
  ) async {
    final current = _alerts ??
        const AlertsSnapshot(
          fighterPresetsById: {},
          eventPresetsById: {},
        );
    final nextSet = {...current.fighterPresetsFor(fighterId)};
    if (nextSet.contains(preset)) {
      nextSet.remove(preset);
    } else {
      nextSet.add(preset);
    }

    final optimistic = current.copyWith(
      fighterPresetsById: {
        ...current.fighterPresetsById,
        fighterId: nextSet,
      },
    );

    setState(() {
      _alerts = optimistic;
    });

    try {
      final saved = await widget.api.updateFighterAlerts(fighterId, nextSet);
      if (!mounted) {
        return;
      }

      setState(() {
        _alerts = saved;
      });
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'alerts.toggle_fighter_preset');
      if (!mounted) {
        return;
      }

      setState(() {
        _alerts = current;
      });
    }
  }

  Future<void> _toggleEventPreset(
    String eventId,
    AlertPreset preset,
  ) async {
    final current = _alerts ??
        const AlertsSnapshot(
          fighterPresetsById: {},
          eventPresetsById: {},
        );
    final nextSet = {...current.eventPresetsFor(eventId)};
    if (nextSet.contains(preset)) {
      nextSet.remove(preset);
    } else {
      nextSet.add(preset);
    }

    final optimistic = current.copyWith(
      eventPresetsById: {
        ...current.eventPresetsById,
        eventId: nextSet,
      },
    );

    setState(() {
      _alerts = optimistic;
    });

    try {
      final saved = await widget.api.updateEventAlerts(eventId, nextSet);
      if (!mounted) {
        return;
      }

      setState(() {
        _alerts = saved;
      });
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'alerts.toggle_event_preset');
      if (!mounted) {
        return;
      }

      setState(() {
        _alerts = current;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AlertsContent(
      snapshotListenable: widget.snapshotListenable,
      strings: widget.strings,
      alerts: _alerts,
      isLoading: _isLoading,
      loadFailed: _loadFailed,
      usingCachedFallback: _usingCachedFallback,
      lastSyncedAt: _lastSyncedAt,
      didRequestStaleRefresh: _didRequestStaleRefresh,
      onMarkStaleRefreshRequested: () {
        _didRequestStaleRefresh = true;
      },
      onResetStaleRefreshRequested: () {
        _didRequestStaleRefresh = false;
      },
      onRefreshAlerts: _loadAlerts,
      onToggleFighterPreset: _toggleFighterPreset,
      onToggleEventPreset: _toggleEventPreset,
      onOpenEvent: widget.onOpenEvent,
      onOpenFighter: widget.onOpenFighter,
    );
  }
}
