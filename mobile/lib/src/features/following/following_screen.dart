import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/domain_models.dart';
import '../../widgets/editorial_ui.dart';
import '../../widgets/fighter_avatar.dart';

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
            EditorialPageHero(
              eyebrow: strings.following.toUpperCase(),
              title: strings.followingTitle,
              body: strings.followingSubtitle,
              trailingLabel:
                  '${snapshot.followedFighters.length + snapshot.followedEvents.length}',
            ),
            const SizedBox(height: 24),
            EditorialSectionTitle(label: strings.followedFightersTitle),
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
            const SizedBox(height: 20),
            EditorialSectionTitle(label: strings.followedEventsTitle),
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          children: [
            EditorialCardHeaderBand(
              pillLabel: fighter.organizationHint,
              title: fighter.name,
              trailingLabel: strings.trackedTagLabel.toUpperCase(),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FighterAvatar(
                    name: fighter.name,
                    size: 72,
                    showInitialsChip: false,
                    framed: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fighter.headline,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        EditorialMetaBand(label: fighter.nextAppearanceLabel),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: EditorialActionPill(
                                label: strings.aboutFighterTitle,
                                emphasized: true,
                                onTap: onOpenFighter,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: EditorialActionPill(
                                label: strings.unfollowAction,
                                onTap: onToggleFollow,
                              ),
                            ),
                          ],
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
    final mainBout = event.bouts.firstWhere(
      (bout) => bout.isMainEvent,
      orElse: () => event.bouts.first,
    );
    final followedBouts =
        event.bouts.where((bout) => bout.includesFollowedFighter).length;
    final watchLabel = event.watchProviders.isEmpty
        ? event.sourceLabel
        : '${strings.whereToWatch}: ${event.watchProviders.first.label}';

    return InkWell(
      onTap: onOpenEvent,
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
                    '${event.localTimeLabel}  •  ${event.locationLabel}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactFighterPreview(
                          label: mainBout.fighterAName,
                          alignEnd: false,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _CompactFighterPreview(
                          label: mainBout.fighterBName,
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  EditorialMetaBand(label: watchLabel),
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
                        child: EditorialActionPill(
                          label: strings.viewEventDetails,
                          emphasized: true,
                          onTap: onOpenEvent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: EditorialActionPill(
                          label: strings.unfollowAction,
                          onTap: onToggleFollow,
                        ),
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
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

class _CompactFighterPreview extends StatelessWidget {
  const _CompactFighterPreview({
    required this.label,
    required this.alignEnd,
  });

  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final avatar = FighterAvatar(
      name: label,
      size: 48,
      showInitialsChip: false,
      framed: true,
    );
    final name = Expanded(
      child: Text(
        label,
        textAlign: alignEnd ? TextAlign.right : TextAlign.left,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [name, const SizedBox(width: 8), avatar]
          : [avatar, const SizedBox(width: 8), name],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.body});

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
