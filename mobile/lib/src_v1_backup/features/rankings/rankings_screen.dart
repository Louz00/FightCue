import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../widgets/editorial_ui.dart';
import '../../widgets/fighter_avatar.dart';

part 'rankings_content.dart';

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
  late Future<ApiFetchResult<List<LeaderboardSummary>>> _future;
  RankingGroup _selectedGroup = RankingGroup.men;
  String? _selectedWeightClass;
  bool _didRequestStaleRefresh = false;

  @override
  void initState() {
    super.initState();
    _future = _loadRankings();
  }

  Future<ApiFetchResult<List<LeaderboardSummary>>> _loadRankings() {
    return widget.api.fetchLeaderboardsResult();
  }

  void _retry() {
    setState(() {
      _didRequestStaleRefresh = false;
      _future = _loadRankings();
    });
  }

  void _refreshStaleCache() {
    setState(() {
      _future = _loadRankings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _RankingsContent(
      future: _future,
      strings: widget.strings,
      selectedGroup: _selectedGroup,
      selectedWeightClass: _selectedWeightClass,
      didRequestStaleRefresh: _didRequestStaleRefresh,
      onRetry: _retry,
      onRefreshStaleCache: _refreshStaleCache,
      onOpenFighter: widget.onOpenFighter,
      onGroupChanged: (group) {
        setState(() {
          _selectedGroup = group;
          _selectedWeightClass = null;
        });
      },
      onWeightClassChanged: (weightClass) {
        setState(() {
          _selectedWeightClass = weightClass;
        });
      },
      onMarkStaleRefreshRequested: () {
        _didRequestStaleRefresh = true;
      },
      onResetStaleRefreshRequested: () {
        _didRequestStaleRefresh = false;
      },
    );
  }
}
