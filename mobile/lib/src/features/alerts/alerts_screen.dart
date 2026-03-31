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

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final alerts = await widget.api.fetchAlerts();
      if (!mounted) {
        return;
      }

      setState(() {
        _alerts = alerts;
        _loadFailed = false;
      });
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'alerts.load');
      if (!mounted) {
        return;
      }

      setState(() {
        _loadFailed = true;
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
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: widget.snapshotListenable,
      builder: (context, snapshot, _) {
        final alerts = _alerts;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            EditorialPageHero(
              eyebrow: widget.strings.alerts.toUpperCase(),
              title: widget.strings.alerts,
              body: widget.strings.alertsSubtitle,
              trailingLabel:
                  '${snapshot.followedFighters.length + snapshot.followedEvents.length}',
            ),
            const SizedBox(height: 24),
            if (_loadFailed) ...[
              EditorialNoticeCard(
                title: widget.strings.alertsFallbackTitle,
                body: widget.strings.alertsFallbackBody,
                actionLabel: widget.strings.retryAction,
                onAction: _loadAlerts,
              ),
              const SizedBox(height: 16),
            ] else if (_isLoading && alerts == null) ...[
              EditorialLoadingCard(label: widget.strings.liveSyncingLabel),
              const SizedBox(height: 16),
            ],
            EditorialSectionTitle(label: widget.strings.fighterReminderPresetsTitle),
            const SizedBox(height: 12),
            if (snapshot.followedFighters.isEmpty)
              _EmptyReminderCard(
                title: widget.strings.followedFightersEmptyTitle,
                body: widget.strings.followedFightersEmptyBody,
              )
            else
              ...snapshot.followedFighters.map(
                (fighter) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FighterReminderCard(
                    fighter: fighter,
                    presets: [
                      _PresetChipData(
                        label: widget.strings.reminderPreset24h,
                        selected:
                            (alerts?.fighterPresetsFor(fighter.id) ??
                                    {
                                      AlertPreset.before24h,
                                      AlertPreset.before1h,
                                      AlertPreset.timeChanges,
                                    })
                                .contains(AlertPreset.before24h),
                        onTap: () => _toggleFighterPreset(
                          fighter.id,
                          AlertPreset.before24h,
                        ),
                      ),
                      _PresetChipData(
                        label: widget.strings.reminderPreset1h,
                        selected:
                            (alerts?.fighterPresetsFor(fighter.id) ??
                                    {
                                      AlertPreset.before24h,
                                      AlertPreset.before1h,
                                      AlertPreset.timeChanges,
                                    })
                                .contains(AlertPreset.before1h),
                        onTap: () => _toggleFighterPreset(
                          fighter.id,
                          AlertPreset.before1h,
                        ),
                      ),
                      _PresetChipData(
                        label: widget.strings.reminderPresetChanges,
                        selected:
                            (alerts?.fighterPresetsFor(fighter.id) ??
                                    {
                                      AlertPreset.before24h,
                                      AlertPreset.before1h,
                                      AlertPreset.timeChanges,
                                    })
                                .contains(AlertPreset.timeChanges),
                        onTap: () => _toggleFighterPreset(
                          fighter.id,
                          AlertPreset.timeChanges,
                        ),
                      ),
                    ],
                    strings: widget.strings,
                    onTap: () => widget.onOpenFighter(fighter.id),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            EditorialSectionTitle(label: widget.strings.eventReminderPresetsTitle),
            const SizedBox(height: 12),
            if (snapshot.followedEvents.isEmpty)
              _EmptyReminderCard(
                title: widget.strings.followedEventsEmptyTitle,
                body: widget.strings.followedEventsEmptyBody,
              )
            else
              ...snapshot.followedEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EventReminderCard(
                    event: event,
                    presets: [
                      _PresetChipData(
                        label: widget.strings.reminderPreset24h,
                        selected:
                            (alerts?.eventPresetsFor(event.id) ??
                                    {
                                      AlertPreset.before24h,
                                      AlertPreset.timeChanges,
                                      AlertPreset.watchUpdates,
                                    })
                                .contains(AlertPreset.before24h),
                        onTap: () => _toggleEventPreset(
                          event.id,
                          AlertPreset.before24h,
                        ),
                      ),
                      _PresetChipData(
                        label: widget.strings.reminderPresetChanges,
                        selected:
                            (alerts?.eventPresetsFor(event.id) ??
                                    {
                                      AlertPreset.before24h,
                                      AlertPreset.timeChanges,
                                      AlertPreset.watchUpdates,
                                    })
                                .contains(AlertPreset.timeChanges),
                        onTap: () => _toggleEventPreset(
                          event.id,
                          AlertPreset.timeChanges,
                        ),
                      ),
                      _PresetChipData(
                        label: widget.strings.reminderPresetWatch,
                        selected:
                            (alerts?.eventPresetsFor(event.id) ??
                                    {
                                      AlertPreset.before24h,
                                      AlertPreset.timeChanges,
                                      AlertPreset.watchUpdates,
                                    })
                                .contains(AlertPreset.watchUpdates),
                        onTap: () => _toggleEventPreset(
                          event.id,
                          AlertPreset.watchUpdates,
                        ),
                      ),
                    ],
                    strings: widget.strings,
                    onTap: () => widget.onOpenEvent(event.id),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _PolicyCard(
              eyebrow: widget.strings.policyLabel.toUpperCase(),
              title: widget.strings.alertPolicyTitle,
              body: widget.strings.alertPolicyBody,
            ),
          ],
        );
      },
    );
  }
}

class _FighterReminderCard extends StatelessWidget {
  const _FighterReminderCard({
    required this.fighter,
    required this.presets,
    required this.strings,
    required this.onTap,
  });

  final FighterSummary fighter;
  final List<_PresetChipData> presets;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditorialCardHeaderBand(
              pillLabel: fighter.organizationHint,
              title: fighter.name,
              trailingLabel: strings.aboutFighterTitle,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FighterAvatar(
                    name: fighter.name,
                    size: 68,
                    showInitialsChip: false,
                    framed: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fighter.nextAppearanceLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: presets
                              .map(
                                (chip) => _ReminderPill(
                                  label: chip.label,
                                  selected: chip.selected,
                                  onTap: chip.onTap,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                        EditorialActionPill(
                          label: strings.aboutFighterTitle,
                          emphasized: true,
                          onTap: onTap,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventReminderCard extends StatelessWidget {
  const _EventReminderCard({
    required this.event,
    required this.presets,
    required this.strings,
    required this.onTap,
  });

  final EventSummary event;
  final List<_PresetChipData> presets;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mainBout = headlineBoutForEvent(event);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditorialCardHeaderBand(
              pillLabel: event.organization,
              title: event.title,
              trailingLabel: event.localDateLabel,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainBout == null
                        ? strings.pendingCardTitle
                        : '${mainBout.fighterAName} vs ${mainBout.fighterBName}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  EditorialMetaBand(
                    label: mainBout == null
                        ? strings.pendingCardBody
                        : '${event.localTimeLabel}  •  ${event.locationLabel}',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets
                        .map(
                          (chip) => _ReminderPill(
                            label: chip.label,
                            selected: chip.selected,
                            onTap: chip.onTap,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  EditorialActionPill(
                    label: strings.viewEventDetails,
                    emphasized: true,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChipData {
  const _PresetChipData({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class _ReminderPill extends StatelessWidget {
  const _ReminderPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.title,
    required this.body,
    required this.eyebrow,
  });

  final String title;
  final String body;
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return EditorialPageHero(
      eyebrow: eyebrow,
      title: title,
      body: body,
    );
  }
}

class _EmptyReminderCard extends StatelessWidget {
  const _EmptyReminderCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return EditorialSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
