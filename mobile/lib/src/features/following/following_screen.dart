import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/domain_models.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({
    super.key,
    required this.snapshotListenable,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
    required this.onToggleEventFollow,
    required this.onToggleFighterFollow,
  });

  final ValueListenable<HomeSnapshot> snapshotListenable;
  final AppStrings strings;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleEventFollow;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: snapshotListenable,
      builder: (context, snapshot, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              strings.following.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 10),
            Text(
              strings.followingTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              strings.followingSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            _SectionHeader(label: strings.followedFightersTitle),
            const SizedBox(height: 12),
            if (snapshot.followedFighters.isEmpty)
              _EmptyStateCard(
                title: strings.followedFightersEmptyTitle,
                body: strings.followedFightersEmptyBody,
              )
            else
              ...snapshot.followedFighters.map(
                (fighter) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FollowedFighterTile(
                    fighter: fighter,
                    strings: strings,
                    onOpenFighter: () => onOpenFighter(fighter.id),
                    onToggleFollow: () => onToggleFighterFollow(fighter.id),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _SectionHeader(label: strings.followedEventsTitle),
            const SizedBox(height: 12),
            if (snapshot.followedEvents.isEmpty)
              _EmptyStateCard(
                title: strings.followedEventsEmptyTitle,
                body: strings.followedEventsEmptyBody,
              )
            else
              ...snapshot.followedEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FollowedEventCard(
                    event: event,
                    strings: strings,
                    onOpenEvent: () => onOpenEvent(event.id),
                    onToggleFollow: () => onToggleEventFollow(event.id),
                  ),
                ),
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

class _FollowedFighterTile extends StatelessWidget {
  const _FollowedFighterTile({
    required this.fighter,
    required this.strings,
    required this.onOpenFighter,
    required this.onToggleFollow,
  });

  final FighterSummary fighter;
  final AppStrings strings;
  final VoidCallback onOpenFighter;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenFighter,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fighter.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fighter.organizationHint,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fighter.headline,
                    style: const TextStyle(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            fighter.nextAppearanceLabel,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _TinyActionPill(
                        label: strings.unfollowAction,
                        emphasized: true,
                        onTap: onToggleFollow,
                      ),
                    ],
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

class _FollowedEventCard extends StatelessWidget {
  const _FollowedEventCard({
    required this.event,
    required this.strings,
    required this.onOpenEvent,
    required this.onToggleFollow,
  });

  final EventSummary event;
  final AppStrings strings;
  final VoidCallback onOpenEvent;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final mainBout = event.bouts.firstWhere((bout) => bout.isMainEvent);
    final followedBouts =
        event.bouts.where((bout) => bout.includesFollowedFighter).length;

    return InkWell(
      onTap: onOpenEvent,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Pill(label: event.organization),
                const Spacer(),
                Text(
                  event.localDateLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${mainBout.fighterAName} vs ${mainBout.fighterBName}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${event.localTimeLabel}  •  ${event.locationLabel}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${strings.whereToWatch}: ${event.watchProviders.first.label}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: strings.followedFightersTitle,
                    value: followedBouts.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Metric(
                    label: strings.selectedCountryLabel,
                    value: event.selectedCountryCode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TinyActionPill(
                    label: strings.viewEventDetails,
                    emphasized: true,
                    onTap: onOpenEvent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TinyActionPill(
                    label: strings.unfollowAction,
                    onTap: onToggleFollow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _TinyActionPill extends StatelessWidget {
  const _TinyActionPill({
    required this.label,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final background = emphasized ? AppColors.accent : Colors.white;
    final textColor = emphasized ? Colors.white : AppColors.accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.accent),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              fontSize: 18,
              letterSpacing: -0.3,
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
