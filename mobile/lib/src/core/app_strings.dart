import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings._(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('nl'),
    Locale('es'),
  ];

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings._(locale);
  }

  bool get isDutch => locale.languageCode == 'nl';
  bool get isSpanish => locale.languageCode == 'es';

  String get appName => 'FightCue';
  String get homeTitle => isDutch
      ? 'Aankomende gevechten'
      : isSpanish
          ? 'Proximas peleas'
          : 'Upcoming fights';
  String get following => isDutch
      ? 'Volgend'
      : isSpanish
          ? 'Siguiendo'
          : 'Following';
  String get alerts => isDutch
      ? 'Meldingen'
      : isSpanish
          ? 'Alertas'
          : 'Alerts';
  String get settings => isDutch
      ? 'Instellingen'
      : isSpanish
          ? 'Ajustes'
          : 'Settings';
  String get yourTime => isDutch
      ? 'jouw tijd'
      : isSpanish
          ? 'tu hora'
          : 'your time';
  String get storeReadyNote => isDutch
      ? 'Store-ready opzet zonder gekoppelde store-accounts.'
      : isSpanish
          ? 'Configuracion preparada para tiendas sin cuentas conectadas.'
          : 'Store-ready setup without connected store accounts.';
  String get languageNote => isDutch
      ? 'Lancering gepland in Engels, Nederlands en Spaans.'
      : isSpanish
          ? 'Lanzamiento previsto en ingles, neerlandes y espanol.'
          : 'Launch planned in English, Dutch, and Spanish.';
  String get sourceNote => isDutch
      ? 'Eerste bronkandidaten: Matchroom, UFC en GLORY.'
      : isSpanish
          ? 'Primeras fuentes candidatas: Matchroom, UFC y GLORY.'
          : 'First source candidates: Matchroom, UFC, and GLORY.';
}
