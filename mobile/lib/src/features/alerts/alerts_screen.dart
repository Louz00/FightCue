import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final alerts = await widget.api.fetchAlerts();
      if (!mounted) {
        return;
      }

      setState(() {
        _alerts = alerts;
      });
    } catch (_) {
      // Keep the screen functional with local defaults if the backend is unavailable.
    }
  }

  Future<void> _toggleFighterPreset(
    String fighterId,
    AlertPreset preset,
  ) async {
    final current = _alerts ?? const AlertsSnapshot(
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
    } catch (_) {
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
    final current = _alerts ?? const AlertsSnapshot(
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
    } catch (_) {
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
            Text(
              widget.strings.alerts.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 10),
            Text(
              widget.strings.alerts,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              widget.strings.alertsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            _SectionHeader(label: widget.strings.fighterReminderPresetsTitle),
            const SizedBox(height: 12),
            ...snapshot.followedFighters.map(
              (fighter) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReminderCard(
                  title: fighter.name,
                  subtitle: fighter.nextAppearanceLabel,
                  reminderChips: [
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
                  actionLabel: widget.strings.aboutFighterTitle,
                  onTap: () => widget.onOpenFighter(fighter.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionHeader(label: widget.strings.eventReminderPresetsTitle),
            const SizedBox(height: 12),
            ...snapshot.followedEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReminderCard(
                  title: event.title,
                  subtitle: '${event.localDateLabel}  •  ${event.localTimeLabel}',
                  reminderChips: [
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
                  actionLabel: widget.strings.viewEventDetails,
                  onTap: () => widget.onOpenEvent(event.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PolicyCard(
              title: widget.strings.alertPolicyTitle,
              body: widget.strings.alertPolicyBody,
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 2,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.title,
    required this.subtitle,
    required this.reminderChips,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<_PresetChipData> reminderChips;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 21,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reminderChips
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
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.accent),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
  const _PolicyCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFFDE5E8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
