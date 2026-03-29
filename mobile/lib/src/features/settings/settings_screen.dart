import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/domain_models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.snapshotListenable,
    required this.strings,
  });

  final ValueListenable<HomeSnapshot> snapshotListenable;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: snapshotListenable,
      builder: (context, snapshot, _) {
        final planLabel = snapshot.premiumState == PremiumState.premium
            ? strings.premiumPlanLabel
            : strings.freePlanLabel;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              strings.settings.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 10),
            Text(
              strings.settings,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              strings.settingsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            _SettingCard(
              title: strings.accountModelTitle,
              body: snapshot.accountModeLabel,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _SettingCard(
              title: strings.currentPlanTitle,
              body: planLabel,
              icon: Icons.workspace_premium_outlined,
              accent: true,
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
            _SettingCard(
              title: strings.sourcePilotTitle,
              body: strings.sourcePilotBody,
              icon: Icons.sports_mma_outlined,
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
      },
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.body,
    required this.icon,
    this.accent = false,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final background = accent ? AppColors.accent : AppColors.surface;
    final iconBackground = accent ? Colors.white : AppColors.surfaceAlt;
    final iconColor = accent ? AppColors.accent : AppColors.textPrimary;
    final titleColor = accent ? Colors.white : AppColors.textPrimary;
    final bodyColor = accent ? const Color(0xFFFDE5E8) : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent ? AppColors.accent : AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    color: bodyColor,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
