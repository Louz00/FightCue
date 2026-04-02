import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../models/event_summary_utils.dart';
import '../../widgets/editorial_ui.dart';
import '../../widgets/fighter_avatar.dart';

part 'following_content.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({
    super.key,
    required this.snapshotListenable,
    required this.cachedFallbackListenable,
    required this.lastSyncedAtListenable,
    required this.strings,
    required this.onOpenEvent,
    required this.onOpenFighter,
    required this.onToggleEventFollow,
    required this.onToggleFighterFollow,
  });

  final ValueListenable<HomeSnapshot> snapshotListenable;
  final ValueListenable<bool> cachedFallbackListenable;
  final ValueListenable<DateTime?> lastSyncedAtListenable;
  final AppStrings strings;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenFighter;
  final ValueChanged<String> onToggleEventFollow;
  final ValueChanged<String> onToggleFighterFollow;

  @override
  Widget build(BuildContext context) {
    return _FollowingContent(
      snapshotListenable: snapshotListenable,
      cachedFallbackListenable: cachedFallbackListenable,
      lastSyncedAtListenable: lastSyncedAtListenable,
      strings: strings,
      onOpenEvent: onOpenEvent,
      onOpenFighter: onOpenFighter,
      onToggleEventFollow: onToggleEventFollow,
      onToggleFighterFollow: onToggleFighterFollow,
    );
  }
}
