import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../models/event_summary_utils.dart';
import '../../widgets/editorial_ui.dart';
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
        backgroundColor: AppColors.surface,
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

              if (detailSnapshot.connectionState == ConnectionState.waiting &&
                  baseFighter == null) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    EditorialLoadingCard(label: strings.liveSyncingLabel),
                  ],
                );
              }

              if (baseFighter == null) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    EditorialNoticeCard(
                      title: strings.detailFallbackTitle,
                      body: strings.fighterFallbackBody,
                      actionLabel: strings.retryAction,
                      onAction: _refreshDetails,
                    ),
                  ],
                );
              }

              final fighter = baseFighter.copyWith(
                isFollowed: snapshotFighter?.isFollowed ?? baseFighter.isFollowed,
              );
              final relatedEvents =
                  detailSnapshot.data?.relatedEvents ??
                  snapshot.relatedEventsForFighter(widget.fighterId);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  if (detailSnapshot.hasError) ...[
                    EditorialNoticeCard(
                      title: strings.detailFallbackTitle,
                      body: strings.fighterFallbackBody,
                      actionLabel: strings.retryAction,
                      onAction: _refreshDetails,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _FighterHeroCard(
                    fighter: fighter,
                    strings: strings,
                    onToggleFollow: () {
                      widget.onToggleFighterFollow(fighter.id);
                      _refreshDetails();
                    },
                  ),
                  const SizedBox(height: 24),
                  EditorialSectionTitle(label: strings.aboutFighterTitle),
                  const SizedBox(height: 12),
                  EditorialSurfaceCard(
                    child: Text(
                      fighter.headline,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  EditorialSectionTitle(label: strings.relatedEventsTitle),
                  const SizedBox(height: 12),
                  if (relatedEvents.isEmpty)
                    EditorialSurfaceCard(
                      child: Text(
                        strings.noFilteredEventsBody,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    )
                  else
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
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorialCardHeaderBand(
            pillLabel: fighter.organizationHint,
            title: fighter.name,
            trailingLabel: fighter.nationalityLabel,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FighterAvatar(
                      name: fighter.name,
                      size: 96,
                      showInitialsChip: false,
                      framed: true,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${fighter.name}$nickname',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                              height: 1.02,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            fighter.headline,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFFE4E8),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                EditorialActionPill(
                  label: fighter.isFollowed
                      ? strings.unfollowAction
                      : strings.favoriteFighterAction,
                  emphasized: true,
                  onTap: onToggleFollow,
                ),
              ],
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
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x36FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFE4E8),
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
    final mainBout = headlineBoutForEvent(event);
    final primaryWatchProvider = primaryWatchProviderLabel(event);
    final watchLabel = primaryWatchProvider == null
        ? event.sourceLabel
        : '${strings.whereToWatch}: $primaryWatchProvider';

    return InkWell(
      onTap: onTap,
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
                  if (mainBout == null)
                    EditorialMetaBand(label: strings.pendingCardTitle)
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _CompactPortraitName(
                            name: mainBout.fighterAName,
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
                          child: _CompactPortraitName(
                            name: mainBout.fighterBName,
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  EditorialMetaBand(label: watchLabel),
                  const SizedBox(height: 14),
                  EditorialActionPill(
                    label: strings.viewEventDetails,
                    emphasized: true,
                    onTap: onTap,
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

class _CompactPortraitName extends StatelessWidget {
  const _CompactPortraitName({
    required this.name,
    required this.alignEnd,
  });

  final String name;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final avatar = FighterAvatar(
      name: name,
      size: 48,
      showInitialsChip: false,
      framed: true,
    );
    final text = Expanded(
      child: Text(
        name,
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
          ? [text, const SizedBox(width: 8), avatar]
          : [avatar, const SizedBox(width: 8), text],
    );
  }
}
