import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/domain_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.snapshotListenable,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
    required this.onToggleEventFollow,
  });

  final ValueListenable<HomeSnapshot> snapshotListenable;
  final AppStrings strings;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleEventFollow;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: snapshotListenable,
      builder: (context, snapshot, _) {
        final heroEvent = snapshot.events.first;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              strings.appName.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 10),
            Text(strings.homeTitle, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            SizedBox(
              width: 280,
              child: Text(
                strings.homeSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 28),
            _SectionTitle(label: strings.nextFight),
            const SizedBox(height: 12),
            _HeroEventCard(
              event: heroEvent,
              strings: strings,
              onOpenEvent: () => onOpenEvent(heroEvent.id),
              onToggleFollow: () => onToggleEventFollow(heroEvent.id),
            ),
            const SizedBox(height: 24),
            _SectionTitle(label: strings.followedFightersTitle),
            const SizedBox(height: 12),
            SizedBox(
              height: 152,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.followedFighters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final fighter = snapshot.followedFighters[index];
                  return _FollowedFighterCard(
                    fighter: fighter,
                    strings: strings,
                    onTap: () => onOpenFighter(fighter.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            if (snapshot.followedEvents.isNotEmpty) ...[
              _SectionTitle(label: strings.followedEventsTitle),
              const SizedBox(height: 12),
              ...snapshot.followedEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ExpandableEventCard(
                    event: event,
                    strings: strings,
                    onOpenEvent: () => onOpenEvent(event.id),
                    onOpenFighter: onOpenFighter,
                    onToggleFollow: () => onToggleEventFollow(event.id),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            _SectionTitle(label: strings.upcomingEventsTitle),
            const SizedBox(height: 12),
            ...snapshot.events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExpandableEventCard(
                  event: event,
                  strings: strings,
                  onOpenEvent: () => onOpenEvent(event.id),
                  onOpenFighter: onOpenFighter,
                  onToggleFollow: () => onToggleEventFollow(event.id),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (snapshot.premiumState == PremiumState.free) ...[
              _SectionTitle(label: strings.quietAdsTitle),
              const SizedBox(height: 12),
              _InfoPanel(
                title: strings.quietAdsTitle,
                body: strings.quietAdsBody,
              ),
              const SizedBox(height: 12),
            ],
            _InfoPanel(
              title: strings.accountModelTitle,
              body: strings.accountModelBody,
            ),
            const SizedBox(height: 12),
            _InfoPanel(
              title: strings.watchInfoTitle,
              body: strings.watchInfoBody,
            ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

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

class _HeroEventCard extends StatelessWidget {
  const _HeroEventCard({
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

    return InkWell(
      onTap: onOpenEvent,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _InversePill(label: event.organization),
                const Spacer(),
                Text(
                  strings.mainEventBannerLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '${mainBout.fighterAName}\nvs\n${mainBout.fighterBName}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                height: 0.98,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              event.localTimeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strings.yourTime,
              style: const TextStyle(
                color: Color(0xFFFCE1E5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event.localDateLabel}  •  ${event.locationLabel}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.tagline,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionPill(
                          label: strings.viewEventDetails,
                          emphasized: true,
                          onTap: onOpenEvent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionPill(
                          label: event.isFollowed
                              ? strings.unfollowAction
                              : strings.followAction,
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

class _FollowedFighterCard extends StatelessWidget {
  const _FollowedFighterCard({
    required this.fighter,
    required this.strings,
    required this.onTap,
  });

  final FighterSummary fighter;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.trackedTagLabel.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              fighter.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              fighter.organizationHint,
              style: const TextStyle(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              fighter.recordLabel,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableEventCard extends StatelessWidget {
  const _ExpandableEventCard({
    required this.event,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
    required this.onToggleFollow,
  });

  final EventSummary event;
  final AppStrings strings;
  final VoidCallback onOpenEvent;
  final ValueChanged<String> onOpenFighter;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final mainBout = event.bouts.firstWhere((bout) => bout.isMainEvent);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _OrgPill(label: event.organization),
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
              const SizedBox(height: 14),
              Text(
                '${mainBout.fighterAName} vs ${mainBout.fighterBName}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
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
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              strings.expandCardHint,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: _ActionPill(
                    label: strings.viewEventDetails,
                    emphasized: true,
                    onTap: onOpenEvent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionPill(
                    label: event.isFollowed
                        ? strings.unfollowAction
                        : strings.followAction,
                    onTap: onToggleFollow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              strings.openFighterHint,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            ...event.bouts.map(
              (bout) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BoutRow(
                  bout: bout,
                  strings: strings,
                  onOpenFighter: onOpenFighter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrgPill extends StatelessWidget {
  const _OrgPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InversePill extends StatelessWidget {
  const _InversePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink,
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

class _ActionPill extends StatelessWidget {
  const _ActionPill({
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
    final borderColor = AppColors.accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
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

class _BoutRow extends StatelessWidget {
  const _BoutRow({
    required this.bout,
    required this.strings,
    required this.onOpenFighter,
  });

  final BoutSummary bout;
  final AppStrings strings;
  final ValueChanged<String> onOpenFighter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              bout.slotLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _FighterLink(
                      label: bout.fighterAName,
                      onTap: () => onOpenFighter(bout.fighterAId),
                    ),
                    const Text(
                      'vs',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _FighterLink(
                      label: bout.fighterBName,
                      onTap: () => onOpenFighter(bout.fighterBId),
                    ),
                  ],
                ),
                if (bout.weightClass != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    bout.weightClass!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (bout.includesFollowedFighter)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                strings.followedTagLabel.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FighterLink extends StatelessWidget {
  const _FighterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accent,
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
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
          Text(body, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
