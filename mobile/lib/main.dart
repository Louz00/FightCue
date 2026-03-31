import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/core/runtime/app_diagnostics.dart';

Future<void> main() async {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        logUiError(
          details.exception,
          details.stack ?? StackTrace.current,
          context: 'flutter_error',
        );
      };

      ErrorWidget.builder = (details) {
        logUiError(
          details.exception,
          details.stack ?? StackTrace.current,
          context: 'error_widget',
        );

        return const Material(
          color: Color(0xFF101010),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'FightCue hit an unexpected screen error.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        logUiError(error, stackTrace, context: 'platform_dispatcher');
        return true;
      };

      runApp(const FightCueApp());
    },
    (error, stackTrace) => logUiError(
      error,
      stackTrace,
      context: 'run_zoned_guarded',
    ),
  );
}
