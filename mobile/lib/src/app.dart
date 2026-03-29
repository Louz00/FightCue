import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/app_shell.dart';

class FightCueApp extends StatefulWidget {
  const FightCueApp({super.key});

  @override
  State<FightCueApp> createState() => _FightCueAppState();
}

class _FightCueAppState extends State<FightCueApp> {
  Locale? _locale;

  void _updateLanguage(String languageCode) {
    if (!AppStrings.supportedLocales.any(
      (locale) => locale.languageCode == languageCode,
    )) {
      return;
    }

    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FightCue',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: buildAppTheme(),
      locale: _locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AppShell(onLanguageChanged: _updateLanguage),
    );
  }
}
