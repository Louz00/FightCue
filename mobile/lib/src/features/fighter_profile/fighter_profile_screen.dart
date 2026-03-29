import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../widgets/fighter_avatar.dart';

class FighterProfileScreen extends StatefulWidget {
  const FighterProfileScreen({
    super.key,
    required this.api,
    required this.snapshotListenable,
    required this.fighterId,
    required this.onOpenEvent,
    required this.onToggleFighterFollow,
  });

  final FightCueApi api;
  final ValueListenable<HomeSnapshot> snapshotListenable;
  final String fighterId;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  State<FighterProfileScreen> createState() => _FighterProfileScreenState();
}

class _FighterProfileScreenState extends State<FighterProfileScreen> {
  late Future<FighterDetailSnapshot> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.api.fetchFighterDetail(widget.fighterId);
  }

  Future<void> _refreshDetails() async {
    setState(() {
      _detailFuture = widget.api.fetchFighterDetail(widget.fighterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          strings.aboutFighterTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ValueListenableBuilder<HomeSnapshot>(
        valueListenable: widget.snapshotListenable,
        builder: (context, snapshot, _) {
          return FutureBuilder<FighterDetailSnapshot>(
            future: _detailFuture,
            builder: (context, detailSnapshot) {
              final snapshotFighter = snapshot.fighterById(widget.fighterId);
              final fetchedFighter = detailSnapshot.data?.fighter;
              final baseFighter = fetchedFighter ?? snapshotFighter;

              if (baseFighter == null) {
                return Center(
                  child: Text(
                    strings.aboutFighterTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                );
              }

              final fighter = baseFighter.copyWith(
                isFollowed: snapshotFighter?.isFollowed ?? baseFighter.isFollowed,
              );
              final relatedEvents =
                  detailSnapshot.data?.relatedEvents ??
                  snapshot.relatedEventsForFighter(widget.fighterId);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _FighterHeroCard(
                    fighter: fighter,
                    strings: strings,
                    onToggleFollow: () {
                      widget.onToggleFighterFollow(fighter.id);
                      _refreshDetails();
                    },
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(label: strings.aboutFighterTitle),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.card,
                    ),
                    child: Text(
                      fighter.headline,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(label: strings.relatedEventsTitle),
                  const SizedBox(height: 12),
                  ...relatedEvents.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RelatedEventCard(
                        event: event,
                        onTap: () => widget.onOpenEvent(event.id),
                        strings: strings,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FighterHeroCard extends StatelessWidget {
  const _FighterHeroCard({
    required this.fighter,
    required this.strings,
    required this.onToggleFollow,
  });

  final FighterSummary fighter;
  final AppStrings strings;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final nickname = fighter.nickname == null ? '' : ' "${fighter.nickname}"';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              fighter.organizationHint,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 18),
          FighterAvatar(name: fighter.name, size: 104),
          const SizedBox(height: 18),
          Text(
            '${fighter.name}$nickname',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 30,
              height: 0.98,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: strings.recordLabel,
                  value: fighter.recordLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: strings.nationalityLabel,
                  value: fighter.nationalityLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HeroMetric(
            label: strings.nextAppearanceTitle,
            value: fighter.nextAppearanceLabel,
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: onToggleFollow,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                fighter.isFollowed
                    ? strings.unfollowAction
                    : strings.favoriteFighterAction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFDE5E8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedEventCard extends StatelessWidget {
  const _RelatedEventCard({
    required this.event,
    required this.onTap,
    required this.strings,
  });

  final EventSummary event;
  final VoidCallback onTap;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final mainBout = event.bouts.firstWhere(
      (bout) => bout.isMainEvent,
      orElse: () => event.bouts.first,
    );

    return InkWell(
      onTap: onTap,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    event.organization,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
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
            const SizedBox(height: 8),
            Text(
              '${event.localTimeLabel}  •  ${event.locationLabel}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.accent),
                ),
                child: Text(
                  strings.viewEventDetails,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
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
