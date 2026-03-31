import 'package:flutter/foundation.dart';

void logUiError(
  Object error,
  StackTrace stackTrace, {
  required String context,
}) {
  debugPrint('[FightCue][$context] $error');
  debugPrint('$stackTrace');
}

