part of 'rankings_screen.dart';

class _RankingsContent extends StatelessWidget {
  const _RankingsContent({
    required this.future,
    required this.strings,
    required this.selectedGroup,
    required this.selectedWeightClass,
    required this.didRequestStaleRefresh,
    required this.onRetry,
    required this.onRefreshStaleCache,
    required this.onOpenFighter,
    required this.onGroupChanged,
    required this.onWeightClassChanged,
    required this.onMarkStaleRefreshRequested,
    required this.onResetStaleRefreshRequested,
  });

  final Future<ApiFetchResult<List<LeaderboardSummary>>> future;
  final AppStrings strings;
  final RankingGroup selectedGroup;
  final String? selectedWeightClass;
  final bool didRequestStaleRefresh;
  final VoidCallback onRetry;
  final VoidCallback onRefreshStaleCache;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<RankingGroup> onGroupChanged;
  final ValueChanged<String> onWeightClassChanged;
  final VoidCallback onMarkStaleRefreshRequested;
  final VoidCallback onResetStaleRefreshRequested;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiFetchResult<List<LeaderboardSummary>>>(
      future: future,
      builder: (context, snapshot) {
        final rankingsResult = snapshot.data;
        final divisions = rankingsResult?.data ?? const <LeaderboardSummary>[];
        final availableDivisions = divisions
            .where((division) => division.group == selectedGroup)
            .toList();
        final effectiveWeightClass = selectedWeightClass ??
            (availableDivisions.isNotEmpty ? availableDivisions.first.weightClass : null);
        LeaderboardSummary? selectedDivision;
        if (effectiveWeightClass != null && availableDivisions.isNotEmpty) {
          selectedDivision = availableDivisions.firstWhere(
            (division) => division.weightClass == effectiveWeightClass,
            orElse: () => availableDivisions.first,
          );
        }

        if (rankingsResult?.isStaleCache ?? false) {
          if (!didRequestStaleRefresh) {
            onMarkStaleRefreshRequested();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onRefreshStaleCache();
            });
          }
        } else {
          onResetStaleRefreshRequested();
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            EditorialPageHero(
              eyebrow: strings.rankingsNavLabel.toUpperCase(),
              title: strings.rankingsTitle,
              body: strings.rankingsSubtitle,
              trailingLabel: selectedGroup == RankingGroup.men
                  ? strings.menLabel
                  : strings.womenLabel,
              footer: _GroupToggle(
                strings: strings,
                selectedGroup: selectedGroup,
                onChanged: onGroupChanged,
              ),
            ),
            const SizedBox(height: 24),
            if (snapshot.connectionState == ConnectionState.waiting)
              EditorialLoadingCard(label: strings.liveSyncingLabel)
            else if (snapshot.hasError)
              EditorialNoticeCard(
                title: strings.noRankingsTitle,
                body: strings.rankingsErrorBody,
                actionLabel: strings.retryAction,
                onAction: onRetry,
              )
            else if (rankingsResult?.isFromCache ?? false)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EditorialNoticeCard(
                  title: strings.savedRankingsTitle,
                  body: strings.savedTimestampBody(
                    strings.savedRankingsBody,
                    rankingsResult?.lastSyncedAt,
                    isStale: rankingsResult?.isStaleCache ?? false,
                  ),
                  actionLabel: strings.retryAction,
                  onAction: onRetry,
                ),
              )
            else
              const SizedBox.shrink(),
            if (snapshot.connectionState != ConnectionState.waiting &&
                !snapshot.hasError) ...[
              if (selectedDivision == null)
                _EmptyCard(strings: strings)
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
                          selected: division.weightClass == effectiveWeightClass,
                          onTap: () => onWeightClassChanged(division.weightClass),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                _SourceCard(
                  division: selectedDivision,
                  body: strings.rankingsSourceBody,
                  sourceLabel: strings.sourceLabel,
                ),
                const SizedBox(height: 16),
                ...selectedDivision.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RankingEntryCard(
                      entry: entry,
                      strings: strings,
                      onTap: entry.fighterId.isEmpty
                          ? null
                          : () => onOpenFighter(entry.fighterId),
                    ),
                  ),
                ),
              ],
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
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
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
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.accent : border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : textPrimary,
              fontWeight: FontWeight.w700,
            ),
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
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadows.cardFor(context),
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
                  style: TextStyle(
                    color: AppColors.textSecondaryFor(context),
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
    final surface = AppColors.surfaceFor(context);
    final border = AppColors.borderFor(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return Semantics(
      button: onTap != null,
      label: entry.fighterName,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: AppShadows.cardFor(context),
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
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.recordLabel,
                            style: TextStyle(
                              color: textSecondary,
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
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSecondary = AppColors.textSecondaryFor(context);

    return EditorialSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.noRankingsTitle,
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.noRankingsBody,
            style: TextStyle(
              color: textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
