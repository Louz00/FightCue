import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
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
    _future = widget.api.fetchLeaderboards();
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
            Text(
              widget.strings.rankingsNavLabel.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 10),
            Text(
              widget.strings.rankingsTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              widget.strings.rankingsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _GroupToggle(
              strings: widget.strings,
              selectedGroup: _selectedGroup,
              onChanged: (group) {
                setState(() {
                  _selectedGroup = group;
                  _selectedWeightClass = null;
                });
              },
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const _LoadingCard()
            else if (snapshot.hasError || selectedDivision == null)
              _EmptyCard(strings: widget.strings)
            else ...[
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
                sourceLabel: selectedDivision.sourceLabel,
                body: widget.strings.rankingsSourceBody,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
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
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
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
    required this.sourceLabel,
    required this.body,
  });

  final String sourceLabel;
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
            sourceLabel,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
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
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: entry.isChampion ? AppColors.accent : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.rank.toString(),
                style: TextStyle(
                  color: entry.isChampion ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            FighterAvatar(name: entry.fighterName, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.fighterName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: -0.2,
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
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            strings.championLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.recordLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (entry.pointsLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.pointsLabel!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
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
