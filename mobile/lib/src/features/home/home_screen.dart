import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../models/event_summary_utils.dart';
import '../../widgets/editorial_ui.dart';
import '../../widgets/fightcue_ad_slot.dart';
import '../../widgets/fighter_avatar.dart';

part 'home_widgets.dart';
part 'home_event_cards.dart';
part 'home_feature_cards.dart';

enum _HomeFeedFilter { all, boxing, ufc, glory, following }

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.snapshotListenable,
    required this.syncingListenable,
    required this.syncErrorListenable,
    required this.cachedFallbackListenable,
    required this.lastSyncedAtListenable,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
    required this.onToggleEventFollow,
    required this.onRetrySync,
  });

  final ValueListenable<HomeSnapshot> snapshotListenable;
  final ValueListenable<bool> syncingListenable;
  final ValueListenable<bool> syncErrorListenable;
  final ValueListenable<bool> cachedFallbackListenable;
  final ValueListenable<DateTime?> lastSyncedAtListenable;
  final AppStrings strings;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleEventFollow;
  final Future<void> Function() onRetrySync;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeFeedFilter _selectedFilter = _HomeFeedFilter.all;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeSnapshot>(
      valueListenable: widget.snapshotListenable,
      builder: (context, snapshot, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.syncingListenable,
          builder: (context, isSyncing, __) {
            return ValueListenableBuilder<bool>(
              valueListenable: widget.syncErrorListenable,
              builder: (context, hasSyncError, ___) {
                return ValueListenableBuilder<bool>(
                  valueListenable: widget.cachedFallbackListenable,
                  builder: (context, usingCachedFallback, ____) {
                    return ValueListenableBuilder<DateTime?>(
                      valueListenable: widget.lastSyncedAtListenable,
                      builder: (context, lastSyncedAt, _____) {
                        final filteredEvents = _filterEvents(snapshot);
                        final heroEvent = filteredEvents.isEmpty ? null : filteredEvents.first;
                        final remainingEvents = heroEvent == null
                            ? filteredEvents
                            : filteredEvents
                                .where((event) => event.id != heroEvent.id)
                                .toList();
                        final filteredFollowedEvents = snapshot.followedEvents
                            .where((event) => _matchesFilter(event))
                            .where((event) => event.id != heroEvent?.id)
                            .toList();

                        return RefreshIndicator(
                          onRefresh: widget.onRetrySync,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                            children: [
                              Text(
                                widget.strings.appName.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.strings.homeTitle,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 280,
                                child: Text(
                                  widget.strings.homeSubtitle,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.strings.pullToRefreshHint,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryFor(context),
                                    ),
                              ),
                              const SizedBox(height: 24),
                              if (hasSyncError) ...[
                                EditorialNoticeCard(
                                  title: widget.strings.liveSyncErrorTitle,
                                  body: widget.strings.savedTimestampBody(
                                    widget.strings.liveSyncErrorBody,
                                    lastSyncedAt,
                                    isStale: usingCachedFallback &&
                                        lastSyncedAt != null &&
                                        DateTime.now().toUtc().difference(
                                              lastSyncedAt.toUtc(),
                                            ) >
                                            ApiFetchResult.staleThreshold,
                                  ),
                                  actionLabel: widget.strings.retryAction,
                                  onAction: () {
                                    widget.onRetrySync();
                                  },
                                ),
                                const SizedBox(height: 16),
                              ] else if (usingCachedFallback) ...[
                                EditorialNoticeCard(
                                  title: widget.strings.savedPreviewTitle,
                                  body: widget.strings.savedTimestampBody(
                                    widget.strings.savedPreviewBody,
                                    lastSyncedAt,
                                    isStale: usingCachedFallback &&
                                        lastSyncedAt != null &&
                                        DateTime.now().toUtc().difference(
                                              lastSyncedAt.toUtc(),
                                            ) >
                                            ApiFetchResult.staleThreshold,
                                  ),
                                  actionLabel: widget.strings.retryAction,
                                  onAction: () {
                                    widget.onRetrySync();
                                  },
                                ),
                                const SizedBox(height: 16),
                              ] else if (isSyncing) ...[
                                EditorialLoadingCard(label: widget.strings.liveSyncingLabel),
                                const SizedBox(height: 16),
                              ],
                              _SectionTitle(label: widget.strings.filteredFeedTitle),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _FilterChip(
                                      label: widget.strings.filterAllLabel,
                                      selected: _selectedFilter == _HomeFeedFilter.all,
                                      onTap: () => setState(
                                        () => _selectedFilter = _HomeFeedFilter.all,
                                      ),
                                    ),
                                    _FilterChip(
                                      label: widget.strings.filterBoxingLabel,
                                      selected: _selectedFilter == _HomeFeedFilter.boxing,
                                      onTap: () => setState(
                                        () => _selectedFilter = _HomeFeedFilter.boxing,
                                      ),
                                    ),
                                    _FilterChip(
                                      label: widget.strings.filterUfcLabel,
                                      selected: _selectedFilter == _HomeFeedFilter.ufc,
                                      onTap: () => setState(
                                        () => _selectedFilter = _HomeFeedFilter.ufc,
                                      ),
                                    ),
                                    _FilterChip(
                                      label: widget.strings.filterGloryLabel,
                                      selected: _selectedFilter == _HomeFeedFilter.glory,
                                      onTap: () => setState(
                                        () => _selectedFilter = _HomeFeedFilter.glory,
                                      ),
                                    ),
                                    _FilterChip(
                                      label: widget.strings.filterFollowingLabel,
                                      selected: _selectedFilter == _HomeFeedFilter.following,
                                      onTap: () => setState(
                                        () => _selectedFilter = _HomeFeedFilter.following,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (heroEvent != null) ...[
                                _SectionTitle(label: widget.strings.nextFight),
                                const SizedBox(height: 12),
                                _HeroEventCard(
                                  event: heroEvent,
                                  strings: widget.strings,
                                  onOpenEvent: () => widget.onOpenEvent(heroEvent.id),
                                  onToggleFollow: () =>
                                      widget.onToggleEventFollow(heroEvent.id),
                                ),
                                const SizedBox(height: 24),
                              ] else ...[
                                _EmptyFilterState(strings: widget.strings),
                                const SizedBox(height: 24),
                              ],
                              _SectionTitle(label: widget.strings.followedFightersTitle),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 224,
                                child: snapshot.followedFighters.isEmpty
                                    ? _EmptyFollowedFightersCard(strings: widget.strings)
                                    : ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.followedFighters.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, index) {
                                          final fighter = snapshot.followedFighters[index];
                                          return _FollowedFighterCard(
                                            fighter: fighter,
                                            strings: widget.strings,
                                            onTap: () => widget.onOpenFighter(fighter.id),
                                          );
                                        },
                                      ),
                              ),
                              const SizedBox(height: 24),
                              if (filteredFollowedEvents.isNotEmpty) ...[
                                _SectionTitle(label: widget.strings.followedEventsTitle),
                                const SizedBox(height: 12),
                                ...filteredFollowedEvents.map(
                                  (event) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _ExpandableEventCard(
                                      event: event,
                                      strings: widget.strings,
                                      onOpenEvent: () => widget.onOpenEvent(event.id),
                                      onOpenFighter: widget.onOpenFighter,
                                      onToggleFollow: () =>
                                          widget.onToggleEventFollow(event.id),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (remainingEvents.isNotEmpty) ...[
                                _SectionTitle(label: widget.strings.upcomingEventsTitle),
                                const SizedBox(height: 12),
                                ...remainingEvents.map(
                                  (event) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _ExpandableEventCard(
                                      event: event,
                                      strings: widget.strings,
                                      onOpenEvent: () => widget.onOpenEvent(event.id),
                                      onOpenFighter: widget.onOpenFighter,
                                      onToggleFollow: () =>
                                          widget.onToggleEventFollow(event.id),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (snapshot.premiumState == PremiumState.free) ...[
                                _SectionTitle(label: widget.strings.quietAdsTitle),
                                const SizedBox(height: 12),
                                _QuietAdFoundationSlot(
                                  strings: widget.strings,
                                  adsEnabled: snapshot.quietAdsEnabled,
                                ),
                                const SizedBox(height: 12),
                              ],
                              _InfoPanel(
                                title: widget.strings.accountModelTitle,
                                body: widget.strings.accountModelBody,
                              ),
                              const SizedBox(height: 12),
                              _InfoPanel(
                                title: widget.strings.watchInfoTitle,
                                body: widget.strings.watchInfoBody,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<EventSummary> _filterEvents(HomeSnapshot snapshot) {
    return snapshot.events.where(_matchesFilter).toList();
  }

  bool _matchesFilter(EventSummary event) {
    switch (_selectedFilter) {
      case _HomeFeedFilter.all:
        return true;
      case _HomeFeedFilter.boxing:
        return event.sport == Sport.boxing;
      case _HomeFeedFilter.ufc:
        return event.organization.toLowerCase() == 'ufc';
      case _HomeFeedFilter.glory:
        return event.organization.toLowerCase() == 'glory';
      case _HomeFeedFilter.following:
        return event.isFollowed;
    }
  }
}
