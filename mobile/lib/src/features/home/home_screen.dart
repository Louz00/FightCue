import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/domain_models.dart';
import '../../models/mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final snapshot = sampleHomeSnapshot;
    final heroEvent = snapshot.events.first;
    final followedEvents = snapshot.events.where((event) => event.isFollowed).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(strings.appName, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(strings.homeTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        _SectionTitle(label: strings.nextFight),
        const SizedBox(height: 12),
        _HeroEventCard(event: heroEvent, strings: strings),
        const SizedBox(height: 20),
        _SectionTitle(label: strings.followedFightersTitle),
        const SizedBox(height: 12),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.followedFighters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _FollowedFighterCard(fighter: snapshot.followedFighters[index]);
            },
          ),
        ),
        const SizedBox(height: 20),
        if (followedEvents.isNotEmpty) ...[
          _SectionTitle(label: strings.followedEventsTitle),
          const SizedBox(height: 12),
          ...followedEvents.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExpandableEventCard(event: event, strings: strings),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _SectionTitle(label: strings.upcomingEventsTitle),
        const SizedBox(height: 12),
        ...snapshot.events.map(
          (event) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ExpandableEventCard(event: event, strings: strings),
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
          body: snapshot.accountModeLabel,
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: strings.watchInfoTitle,
          body: strings.watchInfoBody,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _HeroEventCard extends StatelessWidget {
  const _HeroEventCard({required this.event, required this.strings});

  final EventSummary event;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final mainBout = event.bouts.firstWhere((bout) => bout.isMainEvent);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
          _OrgPill(label: event.organization),
          const SizedBox(height: 14),
          Text(
            '${mainBout.fighterAName} vs ${mainBout.fighterBName}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          Text(
            event.localTimeLabel,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(strings.yourTime, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '${event.localDateLabel}  •  ${event.locationLabel}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(
            '${strings.whereToWatch}: ${event.watchProviders.first.label}',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '${strings.selectedCountryLabel}: ${event.selectedCountryCode}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _FollowedFighterCard extends StatelessWidget {
  const _FollowedFighterCard({required this.fighter});

  final FighterSummary fighter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fighter.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
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
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                fighter.nextAppearanceLabel,
                style: const TextStyle(color: AppColors.accent),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableEventCard extends StatelessWidget {
  const _ExpandableEventCard({required this.event, required this.strings});

  final EventSummary event;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final mainBout = event.bouts.firstWhere((bout) => bout.isMainEvent);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _OrgPill(label: event.organization),
                  const Spacer(),
                  Text(
                    event.localDateLabel,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${mainBout.fighterAName} vs ${mainBout.fighterBName}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${event.localTimeLabel}  •  ${event.locationLabel}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                '${strings.whereToWatch}: ${event.watchProviders.first.label}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              strings.expandCardHint,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          children: [
            Row(
              children: [
                _ActionPill(label: strings.followAction),
                const SizedBox(width: 8),
                _ActionPill(label: strings.alertAction),
                const SizedBox(width: 8),
                _ActionPill(label: strings.calendarAction),
              ],
            ),
            const SizedBox(height: 14),
            ...event.bouts.map(
              (bout) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BoutRow(bout: bout),
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
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
    );
  }
}

class _BoutRow extends StatelessWidget {
  const _BoutRow({required this.bout});

  final BoutSummary bout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              bout.slotLabel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bout.fighterAName} vs ${bout.fighterBName}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'FOLLOWED',
                style: TextStyle(
                  color: AppColors.accent,
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

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
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
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
