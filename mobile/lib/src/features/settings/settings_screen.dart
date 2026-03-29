import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/domain_models.dart';
import '../../models/mock_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final snapshot = sampleHomeSnapshot;
    final planLabel = snapshot.premiumState == PremiumState.premium
        ? strings.premiumPlanLabel
        : strings.freePlanLabel;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(strings.settings, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(strings.settingsSubtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        _SettingCard(
          title: strings.accountModelTitle,
          body: strings.accountModelBody,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _SettingCard(
          title: strings.currentPlanTitle,
          body: planLabel,
          icon: Icons.workspace_premium_outlined,
        ),
        const SizedBox(height: 12),
        _SettingCard(
          title: strings.languagePreferencesTitle,
          body: strings.languagePreferencesBody,
          icon: Icons.language_outlined,
        ),
        const SizedBox(height: 12),
        _SettingCard(
          title: strings.watchInfoTitle,
          body: strings.watchInfoBody,
          icon: Icons.public_outlined,
        ),
        const SizedBox(height: 12),
        _SettingCard(
          title: strings.notificationStyleTitle,
          body: strings.notificationStyleBody,
          icon: Icons.notifications_outlined,
        ),
        const SizedBox(height: 12),
        if (snapshot.premiumState == PremiumState.free)
          _SettingCard(
            title: strings.quietAdsTitle,
            body: strings.quietAdsBody,
            icon: Icons.campaign_outlined,
          ),
      ],
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
