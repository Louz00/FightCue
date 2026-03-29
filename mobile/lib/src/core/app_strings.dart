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
  String get homeSubtitle => _pick(
        en: 'Boxing, MMA, and kickboxing in your timezone.',
        nl: 'Boxing, MMA en kickboksen in jouw tijdzone.',
        es: 'Boxeo, MMA y kickboxing en tu zona horaria.',
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
  String get rankingsNavLabel => _pick(
        en: 'Rankings',
        nl: 'Ranglijsten',
        es: 'Rankings',
      );
  String get rankingsTitle => _pick(
        en: 'Division rankings',
        nl: 'Divisie-ranglijsten',
        es: 'Rankings por division',
      );
  String get rankingsSubtitle => _pick(
        en: 'Clean weight-class leaderboards with a clear source label for every list.',
        nl: 'Strakke gewichtsklasse-ranglijsten met een duidelijke bronvermelding per lijst.',
        es: 'Rankings limpios por peso con una fuente clara para cada lista.',
      );
  String get menLabel => _pick(
        en: 'Men',
        nl: 'Mannen',
        es: 'Hombres',
      );
  String get womenLabel => _pick(
        en: 'Women',
        nl: 'Vrouwen',
        es: 'Mujeres',
      );
  String get championLabel => _pick(
        en: 'Champion',
        nl: 'Kampioen',
        es: 'Campeon',
      );
  String get rankingsSourceBody => _pick(
        en: 'Each leaderboard must stay source-labeled. UFC can ship earlier because official division rankings are clearer than boxing.',
        nl: 'Elke ranglijst moet een duidelijke bron houden. UFC kan eerder live omdat officiele divisierankings daar helderder zijn dan in boxing.',
        es: 'Cada ranking debe mostrar su fuente. UFC puede lanzarse antes porque sus rankings oficiales por division son mas claros que en boxeo.',
      );
  String get noRankingsTitle => _pick(
        en: 'No rankings loaded',
        nl: 'Geen ranglijsten geladen',
        es: 'No se cargaron rankings',
      );
  String get noRankingsBody => _pick(
        en: 'The app will keep the event flow usable even if rankings are temporarily unavailable.',
        nl: 'De app houdt de eventflow bruikbaar, ook als ranglijsten tijdelijk niet beschikbaar zijn.',
        es: 'La app mantiene util el flujo de eventos aunque los rankings no esten disponibles temporalmente.',
      );
  String get stylizedAvatarNote => _pick(
        en: 'Stylized avatar',
        nl: 'Gestileerde avatar',
        es: 'Avatar estilizado',
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
  String get mainEventBannerLabel => _pick(
        en: 'Main event',
        nl: 'Hoofdgevecht',
        es: 'Evento principal',
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
  String get viewEventDetails => _pick(
        en: 'View event details',
        nl: 'Bekijk eventdetails',
        es: 'Ver detalles del evento',
      );
  String get fightCardTitle => _pick(
        en: 'Fight card',
        nl: 'Fight card',
        es: 'Cartelera',
      );
  String get eventOverviewTitle => _pick(
        en: 'Event overview',
        nl: 'Eventoverzicht',
        es: 'Resumen del evento',
      );
  String get venueLabel => _pick(
        en: 'Venue',
        nl: 'Locatie',
        es: 'Sede',
      );
  String get organizationLabel => _pick(
        en: 'Organization',
        nl: 'Organisatie',
        es: 'Organizacion',
      );
  String get sourceLabel => _pick(
        en: 'Source',
        nl: 'Bron',
        es: 'Fuente',
      );
  String get yourTimeLabel => _pick(
        en: 'Your time',
        nl: 'Jouw tijd',
        es: 'Tu hora',
      );
  String get eventLocalStartLabel => _pick(
        en: 'Event local start',
        nl: 'Lokale starttijd event',
        es: 'Hora local del evento',
      );
  String get watchProvidersTitle => _pick(
        en: 'Watch providers',
        nl: 'Kijkproviders',
        es: 'Proveedores para ver',
      );
  String get relatedEventsTitle => _pick(
        en: 'Related events',
        nl: 'Gerelateerde evenementen',
        es: 'Eventos relacionados',
      );
  String get aboutFighterTitle => _pick(
        en: 'Fighter profile',
        nl: 'Vechtersprofiel',
        es: 'Perfil del peleador',
      );
  String get recordLabel => _pick(
        en: 'Record',
        nl: 'Record',
        es: 'Record',
      );
  String get nationalityLabel => _pick(
        en: 'Nationality',
        nl: 'Nationaliteit',
        es: 'Nacionalidad',
      );
  String get nextAppearanceTitle => _pick(
        en: 'Next appearance',
        nl: 'Volgende optreden',
        es: 'Proxima aparicion',
      );
  String get unfollowAction => _pick(
        en: 'Unfollow',
        nl: 'Ontvolgen',
        es: 'Dejar de seguir',
      );
  String get favoriteFighterAction => _pick(
        en: 'Favorite fighter',
        nl: 'Favoriete vechter',
        es: 'Peleador favorito',
      );
  String get openFighterHint => _pick(
        en: 'Tap a fighter to open the profile',
        nl: 'Tik op een vechter om het profiel te openen',
        es: 'Toca un peleador para abrir el perfil',
      );
  String get sourcePilotTitle => _pick(
        en: 'UFC source pilot',
        nl: 'UFC bronpilot',
        es: 'Piloto de fuente UFC',
      );
  String get sourcePilotBody => _pick(
        en: 'The first real source path is being wired against the official UFC events page.',
        nl: 'Het eerste echte bronpad wordt gekoppeld aan de officiele UFC events-pagina.',
        es: 'La primera fuente real se esta conectando a la pagina oficial de eventos de UFC.',
      );
  String get followedFightersEmptyTitle => _pick(
        en: 'No followed fighters yet',
        nl: 'Nog geen gevolgde vechters',
        es: 'Aun no hay peleadores seguidos',
      );
  String get followedFightersEmptyBody => _pick(
        en: 'Favorite fighters to keep them visible on the home screen and to unlock quieter alerts later.',
        nl: 'Markeer vechters als favoriet om ze op de home te houden en later rustigere meldingen te krijgen.',
        es: 'Marca peleadores como favoritos para mantenerlos visibles en inicio y activar alertas mas discretas despues.',
      );
  String get followedEventsEmptyTitle => _pick(
        en: 'No followed events yet',
        nl: 'Nog geen gevolgde evenementen',
        es: 'Aun no hay eventos seguidos',
      );
  String get followedEventsEmptyBody => _pick(
        en: 'Follow whole cards when you want card-level reminders, watch updates, and calendar export.',
        nl: 'Volg hele kaarten als je kaartniveau-herinneringen, kijkupdates en agenda-export wilt.',
        es: 'Sigue carteleras completas si quieres recordatorios, actualizaciones para ver y exportacion al calendario.',
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
  String get calendarLinkCopied => _pick(
        en: 'Calendar link copied',
        nl: 'Kalenderlink gekopieerd',
        es: 'Enlace de calendario copiado',
      );
  String get quietAdsTitle => _pick(
        en: 'Quiet ads',
        nl: 'Rustige advertenties',
        es: 'Anuncios discretos',
      );
  String get trackedTagLabel => _pick(
        en: 'Tracked',
        nl: 'Gevolgd',
        es: 'Seguido',
      );
  String get followedTagLabel => _pick(
        en: 'Followed',
        nl: 'Gevolgd',
        es: 'Seguido',
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
  String get currentTimezoneTitle => _pick(
        en: 'Current timezone',
        nl: 'Huidige tijdzone',
        es: 'Zona horaria actual',
      );
  String get currentTimezoneBody => _pick(
        en: 'Event times are recalculated from your saved timezone preference.',
        nl: 'Eventtijden worden opnieuw berekend vanuit je opgeslagen tijdzonevoorkeur.',
        es: 'Las horas de los eventos se recalculan desde tu preferencia guardada de zona horaria.',
      );
  String get languageEnglishLabel => _pick(
        en: 'English',
        nl: 'Engels',
        es: 'Ingles',
      );
  String get languageDutchLabel => _pick(
        en: 'Dutch',
        nl: 'Nederlands',
        es: 'Neerlandes',
      );
  String get languageSpanishLabel => _pick(
        en: 'Spanish',
        nl: 'Spaans',
        es: 'Espanol',
      );
  String get countryNetherlandsLabel => _pick(
        en: 'Netherlands',
        nl: 'Nederland',
        es: 'Paises Bajos',
      );
  String get countryUnitedKingdomLabel => _pick(
        en: 'United Kingdom',
        nl: 'Verenigd Koninkrijk',
        es: 'Reino Unido',
      );
  String get countryUnitedStatesLabel => _pick(
        en: 'United States',
        nl: 'Verenigde Staten',
        es: 'Estados Unidos',
      );
  String get countrySpainLabel => _pick(
        en: 'Spain',
        nl: 'Spanje',
        es: 'Espana',
      );
}
