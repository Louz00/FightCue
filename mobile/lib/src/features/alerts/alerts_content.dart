part of 'alerts_screen.dart';

class _AlertsContent extends StatelessWidget {
  const _AlertsContent({
    required this.snapshotListenable,
    required this.strings,
    required this.alerts,
    required this.isLoading,
    required this.loadFailed,
    required this.usingCachedFallback,
    required this.lastSyncedAt,
    required this.didRequestStaleRefresh,
    required this.onMarkStaleRefreshRequested,
    required this.onResetStaleRefreshRequested,
    required this.onRefreshAlerts,
    required this.onToggleFighterPreset,
    required this.onToggleEventPreset,
    required this.onOpenEvent,
    required this.onOpenFighter,
  });

  final ValueListenable<HomeSnapshot> snapshotListenable;
  final AppStrings strings;
  final AlertsSnapshot? alerts;
  final bool isLoading;
  final bool loadFailed;
  final bool usingCachedFallback;
  final DateTime? lastSyncedAt;
  final bool didRequestStaleRefresh;
  final VoidCallback onMarkStaleRefreshRequested;
  final VoidCallback onResetStaleRefreshRequested;
  final Future<void> Function({bool resetStaleRefresh}) onRefreshAlerts;
  final Future<void> Function(String fighterId, AlertPreset preset)
      onToggleFighterPreset;
  final Future<void> Function(String eventId, AlertPreset preset)
      onToggleEventPreset;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenFighter;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: snapshotListenable,
      builder: (context, snapshot, _) {
        final isStaleCachedAlerts = usingCachedFallback &&
            lastSyncedAt != null &&
            DateTime.now().toUtc().difference(lastSyncedAt!.toUtc()) >
                ApiFetchResult.staleThreshold;

        if (isStaleCachedAlerts && !didRequestStaleRefresh) {
          onMarkStaleRefreshRequested();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onRefreshAlerts(resetStaleRefresh: false);
          });
        } else if (!isStaleCachedAlerts) {
          onResetStaleRefreshRequested();
        }

        return RefreshIndicator(
          onRefresh: onRefreshAlerts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              EditorialPageHero(
                eyebrow: strings.alerts.toUpperCase(),
                title: strings.alerts,
                body: strings.alertsSubtitle,
                trailingLabel:
                    '${snapshot.followedFighters.length + snapshot.followedEvents.length}',
              ),
              const SizedBox(height: 24),
              if (loadFailed) ...[
                EditorialNoticeCard(
                  title: strings.alertsFallbackTitle,
                  body: strings.alertsFallbackBody,
                  actionLabel: strings.retryAction,
                  onAction: onRefreshAlerts,
                ),
                const SizedBox(height: 16),
              ] else if (usingCachedFallback) ...[
                EditorialNoticeCard(
                  title: strings.savedAlertsTitle,
                  body: strings.savedTimestampBody(
                    strings.savedAlertsBody,
                    lastSyncedAt,
                    isStale: isStaleCachedAlerts,
                  ),
                  actionLabel: strings.retryAction,
                  onAction: onRefreshAlerts,
                ),
                const SizedBox(height: 16),
              ] else if (isLoading && alerts == null) ...[
                EditorialLoadingCard(label: strings.liveSyncingLabel),
                const SizedBox(height: 16),
              ],
              EditorialSectionTitle(label: strings.fighterReminderPresetsTitle),
              const SizedBox(height: 12),
              if (snapshot.followedFighters.isEmpty)
                _EmptyReminderCard(
                  title: strings.followedFightersEmptyTitle,
                  body: strings.followedFightersEmptyBody,
                )
              else
                ...snapshot.followedFighters.map(
                  (fighter) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FighterReminderCard(
                      fighter: fighter,
                      presets: [
                        _PresetChipData(
                          label: strings.reminderPreset24h,
                          selected:
                              (alerts?.fighterPresetsFor(fighter.id) ??
                                      {
                                        AlertPreset.before24h,
                                        AlertPreset.before1h,
                                        AlertPreset.timeChanges,
                                      })
                                  .contains(AlertPreset.before24h),
                          onTap: () => onToggleFighterPreset(
                            fighter.id,
                            AlertPreset.before24h,
                          ),
                        ),
                        _PresetChipData(
                          label: strings.reminderPreset1h,
                          selected:
                              (alerts?.fighterPresetsFor(fighter.id) ??
                                      {
                                        AlertPreset.before24h,
                                        AlertPreset.before1h,
                                        AlertPreset.timeChanges,
                                      })
                                  .contains(AlertPreset.before1h),
                          onTap: () => onToggleFighterPreset(
                            fighter.id,
                            AlertPreset.before1h,
                          ),
                        ),
                        _PresetChipData(
                          label: strings.reminderPresetChanges,
                          selected:
                              (alerts?.fighterPresetsFor(fighter.id) ??
                                      {
                                        AlertPreset.before24h,
                                        AlertPreset.before1h,
                                        AlertPreset.timeChanges,
                                      })
                                  .contains(AlertPreset.timeChanges),
                          onTap: () => onToggleFighterPreset(
                            fighter.id,
                            AlertPreset.timeChanges,
                          ),
                        ),
                      ],
                      strings: strings,
                      onTap: () => onOpenFighter(fighter.id),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              EditorialSectionTitle(label: strings.eventReminderPresetsTitle),
              const SizedBox(height: 12),
              if (snapshot.followedEvents.isEmpty)
                _EmptyReminderCard(
                  title: strings.followedEventsEmptyTitle,
                  body: strings.followedEventsEmptyBody,
                )
              else
                ...snapshot.followedEvents.map(
                  (event) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EventReminderCard(
                      event: event,
                      presets: [
                        _PresetChipData(
                          label: strings.reminderPreset24h,
                          selected:
                              (alerts?.eventPresetsFor(event.id) ??
                                      {
                                        AlertPreset.before24h,
                                        AlertPreset.timeChanges,
                                        AlertPreset.watchUpdates,
                                      })
                                  .contains(AlertPreset.before24h),
                          onTap: () => onToggleEventPreset(
                            event.id,
                            AlertPreset.before24h,
                          ),
                        ),
                        _PresetChipData(
                          label: strings.reminderPresetChanges,
                          selected:
                              (alerts?.eventPresetsFor(event.id) ??
                                      {
                                        AlertPreset.before24h,
                                        AlertPreset.timeChanges,
                                        AlertPreset.watchUpdates,
                                      })
                                  .contains(AlertPreset.timeChanges),
                          onTap: () => onToggleEventPreset(
                            event.id,
                            AlertPreset.timeChanges,
                          ),
                        ),
                        _PresetChipData(
                          label: strings.reminderPresetWatch,
                          selected:
                              (alerts?.eventPresetsFor(event.id) ??
                                      {
                                        AlertPreset.before24h,
                                        AlertPreset.timeChanges,
                                        AlertPreset.watchUpdates,
                                      })
                                  .contains(AlertPreset.watchUpdates),
                          onTap: () => onToggleEventPreset(
                            event.id,
                            AlertPreset.watchUpdates,
                          ),
                        ),
                      ],
                      strings: strings,
                      onTap: () => onOpenEvent(event.id),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _PolicyCard(
                eyebrow: strings.policyLabel.toUpperCase(),
                title: strings.alertPolicyTitle,
                body: strings.alertPolicyBody,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FighterReminderCard extends StatelessWidget {
  const _FighterReminderCard({
    required this.fighter,
    required this.presets,
    required this.strings,
    required this.onTap,
  });

  final FighterSummary fighter;
  final List<_PresetChipData> presets;
  final AppStrings strings;
  final VoidCallback onTap;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditorialCardHeaderBand(
              pillLabel: fighter.organizationHint,
              title: fighter.name,
              trailingLabel: strings.aboutFighterTitle,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FighterAvatar(
                    name: fighter.name,
                    size: 68,
                    showInitialsChip: false,
                    framed: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fighter.nextAppearanceLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: presets
                              .map(
                                (chip) => _ReminderPill(
                                  label: chip.label,
                                  selected: chip.selected,
                                  onTap: chip.onTap,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                        EditorialActionPill(
                          label: strings.aboutFighterTitle,
                          emphasized: true,
                          onTap: onTap,
                        ),
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

class _EventReminderCard extends StatelessWidget {
  const _EventReminderCard({
    required this.event,
    required this.presets,
    required this.strings,
    required this.onTap,
  });

  final EventSummary event;
  final List<_PresetChipData> presets;
  final AppStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mainBout = headlineBoutForEvent(event);

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
                    mainBout == null
                        ? strings.pendingCardTitle
                        : '${mainBout.fighterAName} vs ${mainBout.fighterBName}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  EditorialMetaBand(
                    label: mainBout == null
                        ? strings.pendingCardBody
                        : '${event.localTimeLabel}  •  ${event.locationLabel}',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets
                        .map(
                          (chip) => _ReminderPill(
                            label: chip.label,
                            selected: chip.selected,
                            onTap: chip.onTap,
                          ),
                        )
                        .toList(),
                  ),
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

class _PresetChipData {
  const _PresetChipData({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
}

class _ReminderPill extends StatelessWidget {
  const _ReminderPill({
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.surfaceAlt,
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
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.title,
    required this.body,
    required this.eyebrow,
  });

  final String title;
  final String body;
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return EditorialPageHero(
      eyebrow: eyebrow,
      title: title,
      body: body,
    );
  }
}

class _EmptyReminderCard extends StatelessWidget {
  const _EmptyReminderCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return EditorialSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
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
