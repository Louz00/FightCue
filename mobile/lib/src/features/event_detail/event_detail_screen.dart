import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../models/event_summary_utils.dart';
import '../../widgets/editorial_ui.dart';
import '../../widgets/fighter_avatar.dart';

enum _FightCardSection { main, prelims }

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
  late Future<ApiFetchResult<EventDetailSnapshot>> _detailFuture;
  _FightCardSection _selectedSection = _FightCardSection.main;
  bool _didRequestStaleRefresh = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.api.fetchEventDetailResult(widget.eventId);
  }

  Future<void> _refreshDetails() async {
    setState(() {
      _didRequestStaleRefresh = false;
      _detailFuture = widget.api.fetchEventDetailResult(widget.eventId);
    });
  }

  void _refreshStaleCache() {
    setState(() {
      _detailFuture = widget.api.fetchEventDetailResult(widget.eventId);
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
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceFor(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          strings.eventOverviewTitle,
          style: TextStyle(
            color: AppColors.textPrimaryFor(context),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ValueListenableBuilder<HomeSnapshot>(
        valueListenable: widget.snapshotListenable,
        builder: (context, snapshot, _) {
          return FutureBuilder<ApiFetchResult<EventDetailSnapshot>>(
            future: _detailFuture,
            builder: (context, detailSnapshot) {
              final snapshotEvent = snapshot.eventById(widget.eventId);
              final fetchedResult = detailSnapshot.data;
              final fetchedDetail = fetchedResult?.data;
              final fetchedEvent = fetchedDetail?.event;
              final baseEvent = fetchedEvent ?? snapshotEvent;

              if (detailSnapshot.connectionState == ConnectionState.waiting &&
                  baseEvent == null) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    EditorialLoadingCard(label: strings.liveSyncingLabel),
                  ],
                );
              }

              if (baseEvent == null) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    EditorialNoticeCard(
                      title: strings.detailFallbackTitle,
                      body: strings.detailFallbackBody,
                      actionLabel: strings.retryAction,
                      onAction: _refreshDetails,
                    ),
                  ],
                );
              }

              final event = baseEvent.copyWith(
                isFollowed: snapshotEvent?.isFollowed ?? baseEvent.isFollowed,
              );
              final mainBout = headlineBoutForEvent(event);
              final mainCardBouts = _boutsForSection(
                event,
                section: _FightCardSection.main,
              );
              final prelimBouts = _boutsForSection(
                event,
                section: _FightCardSection.prelims,
              );
              final hasPrelims = prelimBouts.isNotEmpty;
              final effectiveSection =
                  _selectedSection == _FightCardSection.prelims && !hasPrelims
                  ? _FightCardSection.main
                  : _selectedSection;
              final visibleBouts = effectiveSection == _FightCardSection.prelims
                  ? prelimBouts
                  : mainCardBouts;
              final calendarExportPath =
                  fetchedDetail?.calendarExportPath ??
                  '/v1/events/${widget.eventId}/calendar.ics';

              if (fetchedResult?.isStaleCache ?? false) {
                if (!_didRequestStaleRefresh) {
                  _didRequestStaleRefresh = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _refreshStaleCache();
                    }
                  });
                }
              } else {
                _didRequestStaleRefresh = false;
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  _EventScoreboardHeader(
                    event: event,
                    mainBout: mainBout,
                    fighterA: mainBout == null
                        ? null
                        : snapshot.fighterById(mainBout.fighterAId),
                    fighterB: mainBout == null
                        ? null
                        : snapshot.fighterById(mainBout.fighterBId),
                    strings: strings,
                    onToggleFollow: () {
                      widget.onToggleEventFollow(event.id);
                      _refreshDetails();
                    },
                    onCalendarExport: () =>
                        _copyCalendarLink(context, calendarExportPath),
                  ),
                  if (fetchedResult?.isFromCache ?? false) ...[
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EditorialNoticeCard(
                        title: strings.savedDetailTitle,
                        body: strings.savedTimestampBody(
                          strings.savedDetailBody,
                          fetchedResult?.lastSyncedAt,
                          isStale: fetchedResult?.isStaleCache ?? false,
                        ),
                        actionLabel: strings.retryAction,
                        onAction: _refreshDetails,
                      ),
                    ),
                  ] else if (detailSnapshot.hasError) ...[
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: EditorialNoticeCard(
                        title: strings.detailFallbackTitle,
                        body: strings.detailFallbackBody,
                        actionLabel: strings.retryAction,
                        onAction: _refreshDetails,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _FightCardSectionBar(
                      strings: strings,
                      hasPrelims: hasPrelims,
                      selectedSection: effectiveSection,
                      onSelect: (section) {
                        setState(() {
                          _selectedSection = section;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (visibleBouts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _EmptyFightCardCard(strings: strings),
                    )
                  else
                    ...visibleBouts.map(
                      (bout) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _EditorialBoutTile(
                          event: event,
                          bout: bout,
                          fighterA: snapshot.fighterById(bout.fighterAId),
                          fighterB: snapshot.fighterById(bout.fighterBId),
                          onOpenFighter: widget.onOpenFighter,
                          onToggleFighterFollow: widget.onToggleFighterFollow,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (event.watchProviders.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _PanelTitle(label: strings.watchProvidersTitle),
                    ),
                    const SizedBox(height: 12),
                    ...event.watchProviders.map(
                      (provider) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _ProviderCard(
                          provider: provider,
                          strings: strings,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _PanelTitle(label: strings.eventOverviewTitle),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _OverviewCard(
                      event: event,
                      strings: strings,
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

class _EventScoreboardHeader extends StatelessWidget {
  const _EventScoreboardHeader({
    required this.event,
    required this.mainBout,
    required this.fighterA,
    required this.fighterB,
    required this.strings,
    required this.onToggleFollow,
    required this.onCalendarExport,
  });

  final EventSummary event;
  final BoutSummary? mainBout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;
  final AppStrings strings;
  final VoidCallback onToggleFollow;
  final VoidCallback onCalendarExport;

  @override
  Widget build(BuildContext context) {
    final primaryWatchProvider = primaryWatchProviderLabel(event);
    final watchLabel = primaryWatchProvider == null
        ? null
        : '${strings.whereToWatch}: $primaryWatchProvider';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                _HeaderBrandPill(label: event.organization),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.officialCardLabel,
                    style: const TextStyle(
                      color: Color(0xFFFFE4E8),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            color: const Color(0x26000000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.06,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.tagline,
                  style: const TextStyle(
                    color: Color(0xFFFFE4E8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeaderMetaChip(
                      icon: Icons.schedule_rounded,
                      label: '${event.localDateLabel}  •  ${event.localTimeLabel}',
                    ),
                    _HeaderMetaChip(
                      icon: Icons.location_on_outlined,
                      label: event.locationLabel,
                    ),
                    if (watchLabel != null)
                      _HeaderMetaChip(
                        icon: Icons.play_circle_outline_rounded,
                        label: watchLabel,
                      ),
                  ],
                ),
                if (mainBout != null) ...[
                  const SizedBox(height: 18),
                  _HeadlineFightRow(
                    bout: mainBout!,
                    fighterA: fighterA,
                    fighterB: fighterB,
                  ),
                ] else ...[
                  const SizedBox(height: 18),
                  _HeaderMetaChip(
                    icon: Icons.pending_actions_outlined,
                    label: strings.pendingCardTitle,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _HeaderActionButton(
                        label: event.isFollowed
                            ? strings.unfollowAction
                            : strings.followAction,
                        filled: true,
                        onTap: onToggleFollow,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeaderActionButton(
                        label: strings.calendarAction,
                        filled: false,
                        onTap: onCalendarExport,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBrandPill extends StatelessWidget {
  const _HeaderBrandPill({required this.label});

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
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _HeaderMetaChip extends StatelessWidget {
  const _HeaderMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x36FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadlineFightRow extends StatelessWidget {
  const _HeadlineFightRow({
    required this.bout,
    required this.fighterA,
    required this.fighterB,
  });

  final BoutSummary bout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '${bout.fighterAName} versus ${bout.fighterBName}, ${bout.slotLabel}',
      child: Row(
      children: [
        Expanded(
          child: _HeadlineFighterBlock(
            name: bout.fighterAName,
            recordLabel: fighterA?.recordLabel,
            avatarOnLeadingEdge: true,
          ),
        ),
        Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x22FFFFFF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x34FFFFFF)),
          ),
          child: Text(
            bout.slotLabel.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: _HeadlineFighterBlock(
            name: bout.fighterBName,
            recordLabel: fighterB?.recordLabel,
            avatarOnLeadingEdge: false,
          ),
        ),
      ],
      ),
    );
  }
}

class _HeadlineFighterBlock extends StatelessWidget {
  const _HeadlineFighterBlock({
    required this.name,
    required this.recordLabel,
    required this.avatarOnLeadingEdge,
  });

  final String name;
  final String? recordLabel;
  final bool avatarOnLeadingEdge;

  @override
  Widget build(BuildContext context) {
    final textColumn = Expanded(
      child: Column(
        crossAxisAlignment: avatarOnLeadingEdge
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            name,
            textAlign: avatarOnLeadingEdge ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (recordLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              recordLabel!,
              textAlign: avatarOnLeadingEdge ? TextAlign.left : TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFFFD8DE),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );

    final avatar = FighterAvatar(
      name: name,
      size: 72,
      showInitialsChip: false,
      framed: true,
    );

    return Row(
      mainAxisAlignment: avatarOnLeadingEdge
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: avatarOnLeadingEdge
          ? [
              avatar,
              const SizedBox(width: 12),
              textColumn,
            ]
          : [
              textColumn,
              const SizedBox(width: 12),
              avatar,
            ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: filled
                ? Colors.white
                : (AppColors.isDark(context)
                      ? AppColors.darkSurface
                      : AppColors.ink),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: filled ? Colors.white : const Color(0x33FFFFFF),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: filled ? AppColors.accent : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _FightCardSectionBar extends StatelessWidget {
  const _FightCardSectionBar({
    required this.strings,
    required this.hasPrelims,
    required this.selectedSection,
    required this.onSelect,
  });

  final AppStrings strings;
  final bool hasPrelims;
  final _FightCardSection selectedSection;
  final ValueChanged<_FightCardSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SectionToggleButton(
              label: strings.mainCardTabLabel,
              selected: selectedSection == _FightCardSection.main,
              onTap: () => onSelect(_FightCardSection.main),
            ),
          ),
          if (hasPrelims)
            Expanded(
              child: _SectionToggleButton(
                label: strings.preliminaryCardTabLabel,
                selected: selectedSection == _FightCardSection.prelims,
                onTap: () => onSelect(_FightCardSection.prelims),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionToggleButton extends StatelessWidget {
  const _SectionToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          decoration: BoxDecoration(
            border: selected
                ? Border(
                    bottom: BorderSide(
                      color: textPrimary,
                      width: 2.5,
                    ),
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? textPrimary : textSecondary,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorialBoutTile extends StatelessWidget {
  const _EditorialBoutTile({
    required this.event,
    required this.bout,
    required this.fighterA,
    required this.fighterB,
    required this.onOpenFighter,
    required this.onToggleFighterFollow,
  });

  final EventSummary event;
  final BoutSummary bout;
  final FighterSummary? fighterA;
  final FighterSummary? fighterB;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    final surfaceAlt = AppColors.surfaceAltFor(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${event.localDateLabel}, ${event.localTimeLabel}',
                  style: TextStyle(
                    color: textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (bout.includesFollowedFighter)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE7EB),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x1AD30F2F)),
                  ),
                  child: const Text(
                    'FOLLOWING',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _boutHeadline(bout),
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 21,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BoutFighterSide(
                  fighterId: bout.fighterAId,
                  displayName: bout.fighterAName,
                  fighter: fighterA,
                  alignEnd: false,
                  onOpenFighter: onOpenFighter,
                  onToggleFighterFollow: onToggleFighterFollow,
                ),
              ),
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Expanded(
                child: _BoutFighterSide(
                  fighterId: bout.fighterBId,
                  displayName: bout.fighterBName,
                  fighter: fighterB,
                  alignEnd: true,
                  onOpenFighter: onOpenFighter,
                  onToggleFighterFollow: onToggleFighterFollow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoutFighterSide extends StatelessWidget {
  const _BoutFighterSide({
    required this.fighterId,
    required this.displayName,
    required this.fighter,
    required this.alignEnd,
    required this.onOpenFighter,
    required this.onToggleFighterFollow,
  });

  final String fighterId;
  final String displayName;
  final FighterSummary? fighter;
  final bool alignEnd;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  Widget build(BuildContext context) {
    final isFollowed = fighter?.isFollowed ?? false;
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    final surface = AppColors.surfaceFor(context);
    final avatar = FighterAvatar(
      name: displayName,
      size: 60,
      showInitialsChip: false,
      framed: true,
    );
    final info = Expanded(
      child: Semantics(
        button: true,
        label: 'Open fighter profile for $displayName',
        child: InkWell(
          onTap: () => onOpenFighter(fighterId),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: alignEnd
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: isFollowed ? AppColors.accent : textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fighter?.recordLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    fighter!.recordLabel,
                    textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (fighter?.organizationHint != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    fighter!.organizationHint,
                    textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    final followButton = Semantics(
      button: true,
      toggled: isFollowed,
      label: isFollowed
          ? 'Unfollow $displayName'
          : 'Follow $displayName',
      child: InkWell(
        onTap: () => onToggleFighterFollow(fighterId),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isFollowed ? AppColors.accent : surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accent),
          ),
          child: Icon(
            isFollowed ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 16,
            color: isFollowed ? Colors.white : AppColors.accent,
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [
              followButton,
              info,
              avatar,
            ]
          : [
              avatar,
              info,
              followButton,
            ],
    );
  }
}

class _EmptyFightCardCard extends StatelessWidget {
  const _EmptyFightCardCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Text(
        strings.noFilteredEventsBody,
        style: TextStyle(
          color: textSecondary,
          height: 1.45,
        ),
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
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
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
    final textSecondary = AppColors.textSecondaryFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: textPrimary,
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
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    final surfaceAlt = AppColors.surfaceAltFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: surfaceAlt,
              borderRadius: BorderRadius.circular(14),
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
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${strings.selectedCountryLabel}: ${provider.countryCode}  •  ${provider.confidenceLabel}',
                  style: TextStyle(
                    color: textSecondary,
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

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    return Row(
      children: [
        Semantics(
          header: true,
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textPrimary,
                ),
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

List<BoutSummary> _boutsForSection(
  EventSummary event, {
  required _FightCardSection section,
}) {
  if (event.bouts.isEmpty) {
    return const [];
  }

  final prelims = event.bouts.where(_isPrelimBout).toList();
  final mains = event.bouts.where((bout) => !_isPrelimBout(bout)).toList();

  if (section == _FightCardSection.prelims) {
    return prelims;
  }

  return mains.isEmpty ? event.bouts : mains;
}

bool _isPrelimBout(BoutSummary bout) {
  final slot = bout.slotLabel.toLowerCase();
  return slot.contains('prelim') || slot.contains('early');
}

String _boutHeadline(BoutSummary bout) {
  final hasWeight = bout.weightClass != null && bout.weightClass!.isNotEmpty;
  if (!hasWeight) {
    return bout.slotLabel;
  }
  return '${bout.weightClass} · ${bout.slotLabel}';
}
