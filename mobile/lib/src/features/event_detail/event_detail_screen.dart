import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../widgets/fighter_avatar.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.api,
    required this.snapshotListenable,
    required this.eventId,
    required this.onOpenFighter,
    required this.onToggleEventFollow,
    required this.onToggleFighterFollow,
  });

  final FightCueApi api;
  final ValueListenable<HomeSnapshot> snapshotListenable;
  final String eventId;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleEventFollow;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<EventDetailSnapshot> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.api.fetchEventDetail(widget.eventId);
  }

  Future<void> _refreshDetails() async {
    setState(() {
      _detailFuture = widget.api.fetchEventDetail(widget.eventId);
    });
  }

  Future<void> _copyCalendarLink(
    BuildContext context,
    String calendarExportPath,
  ) async {
    final url = widget.api.calendarUrlForEvent(
      widget.eventId,
      calendarExportPath: calendarExportPath,
    );
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).calendarLinkCopied)),
    );
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
          strings.eventOverviewTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ValueListenableBuilder<HomeSnapshot>(
        valueListenable: widget.snapshotListenable,
        builder: (context, snapshot, _) {
          return FutureBuilder<EventDetailSnapshot>(
            future: _detailFuture,
            builder: (context, detailSnapshot) {
              final snapshotEvent = snapshot.eventById(widget.eventId);
              final fetchedDetail = detailSnapshot.data;
              final fetchedEvent = fetchedDetail?.event;
              final baseEvent = fetchedEvent ?? snapshotEvent;

              if (baseEvent == null) {
                return Center(
                  child: Text(
                    strings.eventOverviewTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                );
              }

              final event = baseEvent.copyWith(
                isFollowed: snapshotEvent?.isFollowed ?? baseEvent.isFollowed,
              );
              final mainBout = event.bouts.firstWhere(
                (bout) => bout.isMainEvent,
                orElse: () => event.bouts.first,
              );
              final calendarExportPath =
                  fetchedDetail?.calendarExportPath ??
                  '/v1/events/${widget.eventId}/calendar.ics';

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _EventHeroCard(
                    event: event,
                    mainBout: mainBout,
                    strings: strings,
                    onToggleFollow: () {
                      widget.onToggleEventFollow(event.id);
                      _refreshDetails();
                    },
                    onCalendarExport: () =>
                        _copyCalendarLink(context, calendarExportPath),
                  ),
                  const SizedBox(height: 16),
                  _PanelTitle(label: strings.eventOverviewTitle),
                  const SizedBox(height: 12),
                  _OverviewCard(
                    event: event,
                    strings: strings,
                  ),
                  const SizedBox(height: 16),
                  _PanelTitle(label: strings.watchProvidersTitle),
                  const SizedBox(height: 12),
                  ...event.watchProviders.map(
                    (provider) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ProviderCard(
                        provider: provider,
                        strings: strings,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PanelTitle(label: strings.fightCardTitle),
                  const SizedBox(height: 12),
                  ...event.bouts.map(
                    (bout) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BoutCard(
                        bout: bout,
                        fighterA: snapshot.fighterById(bout.fighterAId),
                        fighterB: snapshot.fighterById(bout.fighterBId),
                        strings: strings,
                        onOpenFighter: widget.onOpenFighter,
                        onToggleFighterFollow: widget.onToggleFighterFollow,
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

class _EventHeroCard extends StatelessWidget {
  const _EventHeroCard({
    required this.event,
    required this.mainBout,
    required this.strings,
    required this.onToggleFollow,
    required this.onCalendarExport,
  });

  final EventSummary event;
  final BoutSummary mainBout;
  final AppStrings strings;
  final VoidCallback onToggleFollow;
  final VoidCallback onCalendarExport;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              _DarkPill(label: event.organization),
              const Spacer(),
              Text(
                strings.mainEventBannerLabel.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 30,
              height: 0.98,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            event.tagline,
            style: const TextStyle(
              color: Color(0xFFFDE5E8),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '${mainBout.fighterAName} vs ${mainBout.fighterBName}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: strings.yourTimeLabel,
                  value: event.localTimeLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: strings.eventLocalStartLabel,
                  value: event.eventLocalTimeLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onToggleFollow,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      event.isFollowed ? strings.unfollowAction : strings.followAction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onCalendarExport,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: Text(
                      strings.calendarAction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.event, required this.strings});

  final EventSummary event;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          _OverviewRow(
            label: strings.organizationLabel,
            value: event.organization,
          ),
          const SizedBox(height: 12),
          _OverviewRow(
            label: strings.venueLabel,
            value: event.venueLabel,
          ),
          const SizedBox(height: 12),
          _OverviewRow(
            label: strings.selectedCountryLabel,
            value: event.selectedCountryCode,
          ),
          const SizedBox(height: 12),
          _OverviewRow(
            label: strings.sourceLabel,
            value: event.sourceLabel,
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.strings,
  });

  final WatchProviderSummary provider;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${strings.selectedCountryLabel}: ${provider.countryCode}  •  ${provider.confidenceLabel}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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

class _BoutCard extends StatelessWidget {
  const _BoutCard({
    required this.bout,
    required this.fighterA,
    required this.fighterB,
    required this.strings,
    required this.onOpenFighter,
    required this.onToggleFighterFollow,
  });

  final BoutSummary bout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;
  final AppStrings strings;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleFighterFollow;

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
          Row(
            children: [
              Text(
                bout.slotLabel,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (bout.weightClass != null)
                Text(
                  bout.weightClass!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _FighterRow(
            fighterId: bout.fighterAId,
            displayName: bout.fighterAName,
            fighter: fighterA,
            strings: strings,
            onOpenFighter: onOpenFighter,
            onToggleFighterFollow: onToggleFighterFollow,
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'vs',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _FighterRow(
            fighterId: bout.fighterBId,
            displayName: bout.fighterBName,
            fighter: fighterB,
            strings: strings,
            onOpenFighter: onOpenFighter,
            onToggleFighterFollow: onToggleFighterFollow,
          ),
        ],
      ),
    );
  }
}

class _FighterRow extends StatelessWidget {
  const _FighterRow({
    required this.fighterId,
    required this.displayName,
    required this.fighter,
    required this.strings,
    required this.onOpenFighter,
    required this.onToggleFighterFollow,
  });

  final String fighterId;
  final String displayName;
  final FighterSummary? fighter;
  final AppStrings strings;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  Widget build(BuildContext context) {
    final isFollowed = fighter?.isFollowed ?? false;

    return Row(
      children: [
        FighterAvatar(name: displayName, size: 52),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => onOpenFighter(fighterId),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  if (fighter != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${fighter!.organizationHint}  •  ${fighter!.recordLabel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => onToggleFighterFollow(fighterId),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isFollowed ? AppColors.accent : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.accent),
            ),
            child: Text(
              isFollowed ? strings.unfollowAction : strings.favoriteFighterAction,
              style: TextStyle(
                color: isFollowed ? Colors.white : AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.label});

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

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.label});

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
