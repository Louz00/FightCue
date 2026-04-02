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

part 'event_detail_content.dart';
part 'event_detail_header.dart';
part 'event_detail_bouts.dart';
part 'event_detail_info.dart';

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
              final fetchedResult = detailSnapshot.data;
              final fetchedDetail = fetchedResult?.data;
              final snapshotEvent = snapshot.eventById(widget.eventId);
              final baseEvent = fetchedDetail?.event ?? snapshotEvent;

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
                  _EventDetailStatusBanner(
                    fetchedResult: fetchedResult,
                    hasError: detailSnapshot.hasError,
                    strings: strings,
                    onRetry: _refreshDetails,
                  ),
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
                  _EventDetailBoutSection(
                    visibleBouts: visibleBouts,
                    event: event,
                    snapshot: snapshot,
                    strings: strings,
                    onOpenFighter: widget.onOpenFighter,
                    onToggleFighterFollow: widget.onToggleFighterFollow,
                  ),
                  const SizedBox(height: 12),
                  _EventDetailInfoSections(
                    event: event,
                    strings: strings,
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
