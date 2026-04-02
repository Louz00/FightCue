import 'package:flutter/foundation.dart';

typedef UiErrorReporter = Future<void> Function(
  Object error,
  StackTrace stackTrace, {
  required String context,
});

UiErrorReporter? _secondaryReporter;

void registerUiErrorReporter(UiErrorReporter reporter) {
  _secondaryReporter = reporter;
}

void clearUiErrorReporter() {
  _secondaryReporter = null;
}

void logUiNotice(
  String message, {
  required String context,
}) {
  debugPrint('[FightCue][$context] $message');
}

void logUiError(
  Object error,
  StackTrace stackTrace, {
  required String context,
}) {
  debugPrint('[FightCue][$context] $error');
  debugPrint('$stackTrace');
  final reporter = _secondaryReporter;
  if (reporter != null) {
    reporter(error, stackTrace, context: context);
  }
}
