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
  String get homeNavLabel => _pick(
        en: 'Home',
        nl: 'Home',
        es: 'Inicio',
      );
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
  String get alertsSubtitle => _pick(
        en: 'Quiet reminders for the fighters and events you care about most.',
        nl: 'Rustige herinneringen voor de vechters en evenementen die voor jou tellen.',
        es: 'Recordatorios discretos para los peleadores y eventos que mas te interessan.',
      );
  String get settings => _pick(
        en: 'Settings',
        nl: 'Instellingen',
        es: 'Ajustes',
      );
  String get settingsSubtitle => _pick(
        en: 'Language, country, account, and premium preferences.',
        nl: 'Taal, land, account en premiumvoorkeuren.',
        es: 'Idioma, pais, cuenta y preferencias premium.',
      );
  String get yourTime => _pick(
        en: 'your time',
        nl: 'jouw tijd',
        es: 'tu hora',
      );
  String get followingTitle => _pick(
        en: 'Your follows',
        nl: 'Jouw favorieten',
        es: 'Tus seguidos',
      );
  String get followingSubtitle => _pick(
        en: 'Fast access to tracked fighters and event cards.',
        nl: 'Snelle toegang tot gevolgde vechters en event cards.',
        es: 'Acceso rapido a peleadores seguidos y carteleras.',
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
  String get accountModelBody => _pick(
        en: 'Anonymous by default. Optional email sign-in can be added later for sync and restore.',
        nl: 'Standaard anoniem. Optioneel e-mail inloggen kan later worden toegevoegd voor sync en herstel.',
        es: 'Anonimo por defecto. El acceso por correo se puede anadir mas tarde para sincronizacion y restauracion.',
      );
  String get accountModelTitle => _pick(
        en: 'Account model',
        nl: 'Accountmodel',
        es: 'Modelo de cuenta',
      );
  String get reminderPresetsTitle => _pick(
        en: 'Reminder presets',
        nl: 'Herinneringsinstellingen',
        es: 'Preajustes de recordatorio',
      );
  String get fighterReminderPresetsTitle => _pick(
        en: 'Fighter alerts',
        nl: 'Vechtersmeldingen',
        es: 'Alertas de peleadores',
      );
  String get eventReminderPresetsTitle => _pick(
        en: 'Event alerts',
        nl: 'Evenementmeldingen',
        es: 'Alertas de eventos',
      );
  String get reminderPreset24h => _pick(
        en: '24 hours before',
        nl: '24 uur van tevoren',
        es: '24 horas antes',
      );
  String get reminderPreset1h => _pick(
        en: '1 hour before',
        nl: '1 uur van tevoren',
        es: '1 hora antes',
      );
  String get reminderPresetChanges => _pick(
        en: 'Time changes',
        nl: 'Tijdswijzigingen',
        es: 'Cambios de horario',
      );
  String get reminderPresetWatch => _pick(
        en: 'Watch provider updates',
        nl: 'Updates van kijkproviders',
        es: 'Actualizaciones del proveedor',
      );
  String get alertPolicyTitle => _pick(
        en: 'Alert style',
        nl: 'Meldingsstijl',
        es: 'Estilo de alertas',
      );
  String get alertPolicyBody => _pick(
        en: 'FightCue should stay useful, not noisy. Alerts focus on tracked cards, followed fighters, and confirmed timing changes.',
        nl: 'FightCue moet nuttig blijven, niet druk. Meldingen richten zich op gevolgde kaarten, gevolgde vechters en bevestigde tijdswijzigingen.',
        es: 'FightCue debe ser util, no ruidoso. Las alertas se centran en carteleras seguidas, peleadores seguidos y cambios confirmados.',
      );
  String get currentPlanTitle => _pick(
        en: 'Current plan',
        nl: 'Huidig plan',
        es: 'Plan actual',
      );
  String get freePlanLabel => _pick(
        en: 'Free tier',
        nl: 'Gratis tier',
        es: 'Plan gratuito',
      );
  String get premiumPlanLabel => _pick(
        en: 'Premium',
        nl: 'Premium',
        es: 'Premium',
      );
  String get languagePreferencesTitle => _pick(
        en: 'Languages',
        nl: 'Talen',
        es: 'Idiomas',
      );
  String get languagePreferencesBody => _pick(
        en: 'English, Dutch, and Spanish are prepared for launch.',
        nl: 'Engels, Nederlands en Spaans staan klaar voor lancering.',
        es: 'Ingles, neerlandes y espanol estan preparados para el lanzamiento.',
      );
  String get notificationStyleTitle => _pick(
        en: 'Notification style',
        nl: 'Notificatiestijl',
        es: 'Estilo de notificaciones',
      );
  String get notificationStyleBody => _pick(
        en: 'Quiet alerts only, with stronger notification confidence reserved for premium later.',
        nl: 'Alleen rustige meldingen, met sterkere meldingszekerheid later voor premium.',
        es: 'Solo alertas discretas, con mayor confianza de notificacion reservada para premium despues.',
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
