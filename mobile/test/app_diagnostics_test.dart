import 'package:flutter_test/flutter_test.dart';

import 'package:fightcue_mobile/src/core/runtime/app_diagnostics.dart';

void main() {
  tearDown(() {
    clearUiErrorReporter();
  });

  test('logUiError forwards errors to the registered secondary reporter', () async {
    Object? capturedError;
    StackTrace? capturedStackTrace;
    String? capturedContext;

    registerUiErrorReporter((error, stackTrace, {required context}) async {
      capturedError = error;
      capturedStackTrace = stackTrace;
      capturedContext = context;
    });

    final error = StateError('boom');
    final stackTrace = StackTrace.current;
    logUiError(error, stackTrace, context: 'test_context');

    await Future<void>.delayed(Duration.zero);

    expect(capturedError, same(error));
    expect(capturedStackTrace, same(stackTrace));
    expect(capturedContext, 'test_context');
  });
}
