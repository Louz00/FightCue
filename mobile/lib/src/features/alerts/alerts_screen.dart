import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mock_data.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final snapshot = sampleHomeSnapshot;
    final followedEvents = snapshot.events.where((event) => event.isFollowed).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(strings.alerts, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(strings.alertsSubtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
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
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SectionHeader(label: strings.eventReminderPresetsTitle),
        const SizedBox(height: 12),
        ...followedEvents.map(
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
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.title,
    required this.subtitle,
    required this.reminders,
  });

  final String title;
  final String subtitle;
  final List<String> reminders;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reminders.map((reminder) => _ReminderPill(label: reminder)).toList(),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          colors: [AppColors.surface, AppColors.surfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
