import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../widgets/editorial_ui.dart';
import '../../widgets/fighter_avatar.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({
    super.key,
    required this.api,
    required this.strings,
    required this.onOpenFighter,
  });

  final FightCueApi api;
  final AppStrings strings;
  final ValueChanged<String> onOpenFighter;

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  late Future<List<LeaderboardSummary>> _future;
  RankingGroup _selectedGroup = RankingGroup.men;
  String? _selectedWeightClass;

  @override
  void initState() {
    super.initState();
    _future = _loadRankings();
  }

  Future<List<LeaderboardSummary>> _loadRankings() {
    return widget.api.fetchLeaderboards();
  }

  void _retry() {
    setState(() {
      _future = _loadRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LeaderboardSummary>>(
      future: _future,
      builder: (context, snapshot) {
        final divisions = snapshot.data ?? const <LeaderboardSummary>[];
        final availableDivisions = divisions
            .where((division) => division.group == _selectedGroup)
            .toList();
        final selectedWeightClass = _selectedWeightClass ??
            (availableDivisions.isNotEmpty
                ? availableDivisions.first.weightClass
                : null);
        LeaderboardSummary? selectedDivision;
        if (selectedWeightClass != null && availableDivisions.isNotEmpty) {
          selectedDivision = availableDivisions.firstWhere(
            (division) => division.weightClass == selectedWeightClass,
            orElse: () => availableDivisions.first,
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            EditorialPageHero(
              eyebrow: widget.strings.rankingsNavLabel.toUpperCase(),
              title: widget.strings.rankingsTitle,
              body: widget.strings.rankingsSubtitle,
              trailingLabel: _selectedGroup == RankingGroup.men
                  ? widget.strings.menLabel
                  : widget.strings.womenLabel,
              footer: _GroupToggle(
                strings: widget.strings,
                selectedGroup: _selectedGroup,
                onChanged: (group) {
                  setState(() {
                    _selectedGroup = group;
                    _selectedWeightClass = null;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            if (snapshot.connectionState == ConnectionState.waiting)
              EditorialLoadingCard(label: widget.strings.liveSyncingLabel)
            else if (snapshot.hasError)
              EditorialNoticeCard(
                title: widget.strings.noRankingsTitle,
                body: widget.strings.rankingsErrorBody,
                actionLabel: widget.strings.retryAction,
                onAction: _retry,
              )
            else if (selectedDivision == null)
              _EmptyCard(strings: widget.strings)
            else ...[
              EditorialSectionTitle(label: selectedDivision.title),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableDivisions
                    .map(
                      (division) => _WeightChip(
                        label: division.weightClass,
                        selected: division.weightClass == selectedWeightClass,
                        onTap: () => setState(
                          () => _selectedWeightClass = division.weightClass,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              _SourceCard(
                division: selectedDivision,
                body: widget.strings.rankingsSourceBody,
                sourceLabel: widget.strings.sourceLabel,
              ),
              const SizedBox(height: 16),
              ...selectedDivision.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RankingEntryCard(
                    entry: entry,
                    strings: widget.strings,
                    onTap: entry.fighterId.isEmpty
                        ? null
                        : () => widget.onOpenFighter(entry.fighterId),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _GroupToggle extends StatelessWidget {
  const _GroupToggle({
    required this.strings,
    required this.selectedGroup,
    required this.onChanged,
  });

  final AppStrings strings;
  final RankingGroup selectedGroup;
  final ValueChanged<RankingGroup> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x32FFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TogglePill(
              label: strings.menLabel,
              selected: selectedGroup == RankingGroup.men,
              onTap: () => onChanged(RankingGroup.men),
            ),
          ),
          Expanded(
            child: _TogglePill(
              label: strings.womenLabel,
              selected: selectedGroup == RankingGroup.women,
              onTap: () => onChanged(RankingGroup.women),
            ),
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.accent : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _WeightChip extends StatelessWidget {
  const _WeightChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.division,
    required this.body,
    required this.sourceLabel,
  });

  final LeaderboardSummary division;
  final String body;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            pillLabel: division.organization,
            title: division.weightClass,
            trailingLabel: sourceLabel,
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditorialMetaBand(label: division.sourceLabel),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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

class _RankingEntryCard extends StatelessWidget {
  const _RankingEntryCard({
    required this.entry,
    required this.strings,
    this.onTap,
  });

  final LeaderboardEntrySummary entry;
  final AppStrings strings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      entry.rank.toString(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.organization.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  if (entry.isChampion)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x22FFFFFF),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0x33FFFFFF)),
                      ),
                      child: Text(
                        strings.championLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  FighterAvatar(
                    name: entry.fighterName,
                    size: 64,
                    showInitialsChip: false,
                    framed: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.fighterName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.recordLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (entry.pointsLabel != null) ...[
                          const SizedBox(height: 10),
                          EditorialMetaBand(label: entry.pointsLabel!),
                        ],
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

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return EditorialSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.noRankingsTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.noRankingsBody,
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
