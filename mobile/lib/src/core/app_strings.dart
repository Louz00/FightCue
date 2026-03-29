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

  String _pick({
    required String en,
    required String nl,
    required String es,
  }) {
    if (isDutch) return nl;
    if (isSpanish) return es;
    return en;
  }

  String get appName => 'FightCue';
  String get homeTitle => _pick(
        en: 'Upcoming fights',
        nl: 'Aankomende gevechten',
        es: 'Proximas peleas',
      );
  String get following => _pick(
        en: 'Following',
        nl: 'Volgend',
        es: 'Siguiendo',
      );
  String get alerts => _pick(
        en: 'Alerts',
        nl: 'Meldingen',
        es: 'Alertas',
      );
  String get settings => _pick(
        en: 'Settings',
        nl: 'Instellingen',
        es: 'Ajustes',
      );
  String get yourTime => _pick(
        en: 'your time',
        nl: 'jouw tijd',
        es: 'tu hora',
      );
  String get nextFight => _pick(
        en: 'Next big fight',
        nl: 'Volgende grote gevecht',
        es: 'Proxima gran pelea',
      );
  String get followedFightersTitle => _pick(
        en: 'Followed fighters',
        nl: 'Gevolgde vechters',
        es: 'Peleadores seguidos',
      );
  String get followedEventsTitle => _pick(
        en: 'Followed events',
        nl: 'Gevolgde evenementen',
        es: 'Eventos seguidos',
      );
  String get upcomingEventsTitle => _pick(
        en: 'Upcoming events',
        nl: 'Aankomende evenementen',
        es: 'Proximos eventos',
      );
  String get whereToWatch => _pick(
        en: 'Where to watch',
        nl: 'Waar te kijken',
        es: 'Donde ver',
      );
  String get selectedCountryLabel => _pick(
        en: 'Viewing country',
        nl: 'Kijkland',
        es: 'Pais de visualizacion',
      );
  String get expandCardHint => _pick(
        en: 'Tap to see the full fight card',
        nl: 'Tik om de volledige fight card te zien',
        es: 'Toca para ver la cartelera completa',
      );
  String get followAction => _pick(
        en: 'Follow',
        nl: 'Volgen',
        es: 'Seguir',
      );
  String get alertAction => _pick(
        en: 'Alert',
        nl: 'Alert',
        es: 'Alerta',
      );
  String get calendarAction => _pick(
        en: 'Calendar',
        nl: 'Kalender',
        es: 'Calendario',
      );
  String get quietAdsTitle => _pick(
        en: 'Quiet ads',
        nl: 'Rustige advertenties',
        es: 'Anuncios discretos',
      );
  String get quietAdsBody => _pick(
        en: 'Free users get low-noise feed ads only. Premium removes all ads.',
        nl: 'Gratis gebruikers krijgen alleen rustige feed ads. Premium verwijdert alle advertenties.',
        es: 'Los usuarios gratis solo reciben anuncios discretos en el feed. Premium elimina todos los anuncios.',
      );
  String get accountModelTitle => _pick(
        en: 'Account model',
        nl: 'Accountmodel',
        es: 'Modelo de cuenta',
      );
  String get watchInfoTitle => _pick(
        en: 'Watch by country',
        nl: 'Kijken per land',
        es: 'Ver por pais',
      );
  String get watchInfoBody => _pick(
        en: 'Watch providers depend on the selected viewing country and can be changed manually.',
        nl: 'Kijkproviders hangen af van het gekozen kijkland en kunnen handmatig worden aangepast.',
        es: 'Los proveedores dependen del pais seleccionado y se pueden cambiar manualmente.',
      );
}
