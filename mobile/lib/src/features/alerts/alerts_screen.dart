import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/domain_models.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({
    super.key,
    required this.snapshotListenable,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
  });

  final ValueListenable<HomeSnapshot> snapshotListenable;
  final AppStrings strings;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenFighter;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: snapshotListenable,
      builder: (context, snapshot, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              strings.alerts.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 10),
            Text(
              strings.alerts,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              strings.alertsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            _SectionHeader(label: strings.fighterReminderPresetsTitle),
            const SizedBox(height: 12),
            ...snapshot.followedFighters.map(
              (fighter) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReminderCard(
                  title: fighter.name,
                  subtitle: fighter.nextAppearanceLabel,
                  reminders: [
                    strings.reminderPreset24h,
                    strings.reminderPreset1h,
                    strings.reminderPresetChanges,
                  ],
                  actionLabel: strings.aboutFighterTitle,
                  onTap: () => onOpenFighter(fighter.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionHeader(label: strings.eventReminderPresetsTitle),
            const SizedBox(height: 12),
            ...snapshot.followedEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReminderCard(
                  title: event.title,
                  subtitle: '${event.localDateLabel}  •  ${event.localTimeLabel}',
                  reminders: [
                    strings.reminderPreset24h,
                    strings.reminderPresetChanges,
                    strings.reminderPresetWatch,
                  ],
                  actionLabel: strings.viewEventDetails,
                  onTap: () => onOpenEvent(event.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PolicyCard(
              title: strings.alertPolicyTitle,
              body: strings.alertPolicyBody,
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
    required this.reminders,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<String> reminders;
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
              children: reminders
                  .map((reminder) => _ReminderPill(label: reminder))
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

class _ReminderPill extends StatelessWidget {
  const _ReminderPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
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
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
