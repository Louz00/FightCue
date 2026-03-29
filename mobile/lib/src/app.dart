import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_shell.dart';

class FightCueApp extends StatelessWidget {
  const FightCueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FightCue',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: buildAppTheme(),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppShell(),
    );
  }
}
