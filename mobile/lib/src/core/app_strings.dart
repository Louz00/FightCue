import 'package:flutter/material.dart';

import '../models/domain_models.dart';

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
  String get navigationSectionsLabel => _pick(
        en: 'Main navigation',
        nl: 'Hoofdnavigatie',
        es: 'Navegacion principal',
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
  String get filterAllLabel => _pick(
        en: 'All',
        nl: 'Alles',
        es: 'Todo',
      );
  String get filterBoxingLabel => _pick(
        en: 'Boxing',
        nl: 'Boksen',
        es: 'Boxeo',
      );
  String get filterUfcLabel => _pick(
        en: 'UFC',
        nl: 'UFC',
        es: 'UFC',
      );
  String get filterGloryLabel => _pick(
        en: 'GLORY',
        nl: 'GLORY',
        es: 'GLORY',
      );
  String get filterFollowingLabel => _pick(
        en: 'Following',
        nl: 'Volgend',
        es: 'Seguidos',
      );
  String get upcomingEventsTitle => _pick(
        en: 'Upcoming events',
        nl: 'Aankomende evenementen',
        es: 'Proximos eventos',
      );
  String get filteredFeedTitle => _pick(
        en: 'Filter the feed',
        nl: 'Filter de feed',
        es: 'Filtra el feed',
      );
  String get noFilteredEventsTitle => _pick(
        en: 'No events in this filter yet',
        nl: 'Nog geen evenementen in dit filter',
        es: 'Aun no hay eventos en este filtro',
      );
  String get noFilteredEventsBody => _pick(
        en: 'We will keep this feed ready as more live UFC data and future GLORY sources are added.',
        nl: 'We houden deze feed klaar terwijl meer live UFC-data en toekomstige GLORY-bronnen worden toegevoegd.',
        es: 'Mantendremos este feed listo mientras se agregan mas datos en vivo de UFC y futuras fuentes de GLORY.',
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
  String get retryAction => _pick(
        en: 'Retry',
        nl: 'Opnieuw proberen',
        es: 'Reintentar',
      );
  String get liveSyncErrorTitle => _pick(
        en: 'Live sync unavailable',
        nl: 'Live sync niet beschikbaar',
        es: 'Sincronizacion en vivo no disponible',
      );
  String get liveSyncErrorBody => _pick(
        en: 'FightCue is showing the saved preview while the backend reconnects.',
        nl: 'FightCue toont tijdelijk de opgeslagen preview terwijl de backend opnieuw verbindt.',
        es: 'FightCue muestra la vista guardada mientras el backend vuelve a conectarse.',
      );
  String get liveSyncingLabel => _pick(
        en: 'Syncing live events...',
        nl: 'Live events worden gesynchroniseerd...',
        es: 'Sincronizando eventos en vivo...',
      );
  String get savedPreviewTitle => _pick(
        en: 'Showing saved preview',
        nl: 'Opgeslagen preview wordt getoond',
        es: 'Mostrando vista guardada',
      );
  String get savedPreviewBody => _pick(
        en: 'FightCue is using the last synced feed while live data reconnects.',
        nl: 'FightCue gebruikt de laatst gesynchroniseerde feed terwijl live data opnieuw verbindt.',
        es: 'FightCue usa el ultimo feed sincronizado mientras los datos en vivo vuelven a conectarse.',
      );
  String get pullToRefreshHint => _pick(
        en: 'Pull down to refresh the live feed.',
        nl: 'Trek omlaag om de live feed te vernieuwen.',
        es: 'Desliza hacia abajo para actualizar el feed en vivo.',
      );
  String get pendingCardTitle => _pick(
        en: 'Fight card pending',
        nl: 'Fight card volgt nog',
        es: 'Cartelera pendiente',
      );
  String get pendingCardBody => _pick(
        en: 'The event is live in the schedule, but the bout lineup is not fully confirmed yet.',
        nl: 'Het event staat al in de agenda, maar de volledige bout-line-up is nog niet bevestigd.',
        es: 'El evento ya figura en el calendario, pero la cartelera todavia no esta totalmente confirmada.',
      );
  String get detailFallbackTitle => _pick(
        en: 'Live details unavailable',
        nl: 'Live details niet beschikbaar',
        es: 'Detalles en vivo no disponibles',
      );
  String get detailFallbackBody => _pick(
        en: 'FightCue is showing the last known event data until live details load again.',
        nl: 'FightCue toont de laatst bekende eventdata totdat live details weer laden.',
        es: 'FightCue muestra los ultimos datos conocidos del evento hasta que vuelvan a cargar los detalles en vivo.',
      );
  String get fighterFallbackBody => _pick(
        en: 'FightCue is showing the last known fighter data until the live profile responds again.',
        nl: 'FightCue toont de laatst bekende vechtersdata totdat het live profiel weer reageert.',
        es: 'FightCue muestra los ultimos datos conocidos del peleador hasta que el perfil en vivo vuelva a responder.',
      );
  String get savedDetailTitle => _pick(
        en: 'Showing saved event details',
        nl: 'Opgeslagen eventdetails worden getoond',
        es: 'Mostrando detalles guardados del evento',
      );
  String get savedDetailBody => _pick(
        en: 'FightCue is using the last synced event detail while the live card reconnects.',
        nl: 'FightCue gebruikt de laatst gesynchroniseerde eventdetails terwijl de live card opnieuw verbindt.',
        es: 'FightCue usa el ultimo detalle sincronizado del evento mientras la cartelera en vivo vuelve a conectarse.',
      );
  String get savedFighterTitle => _pick(
        en: 'Showing saved fighter profile',
        nl: 'Opgeslagen vechtersprofiel wordt getoond',
        es: 'Mostrando perfil guardado del peleador',
      );
  String get savedFighterBody => _pick(
        en: 'FightCue is using the last synced fighter profile while the live source reconnects.',
        nl: 'FightCue gebruikt het laatst gesynchroniseerde vechtersprofiel terwijl de live bron opnieuw verbindt.',
        es: 'FightCue usa el ultimo perfil sincronizado del peleador mientras la fuente en vivo vuelve a conectarse.',
      );
  String savedTimestampBody(
    String baseBody,
    DateTime? syncedAt, {
    bool isStale = false,
  }) {
    final timestampLine = syncedAt == null ? offlineTimestampUnknown : offlineTimestampLabel(syncedAt);
    final staleLine = isStale ? '\n\n$staleDataWarning' : '';
    return '$baseBody\n\n$timestampLine$staleLine';
  }

  String get offlineTimestampUnknown => _pick(
        en: 'Last synced: unknown',
        nl: 'Laatst gesynchroniseerd: onbekend',
        es: 'Ultima sincronizacion: desconocida',
      );

  String offlineTimestampLabel(DateTime syncedAt) {
    final local = syncedAt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final formatted = '$day-$month $hour:$minute';

    return _pick(
      en: 'Last synced: $formatted',
      nl: 'Laatst gesynchroniseerd: $formatted',
      es: 'Ultima sincronizacion: $formatted',
    );
  }
  String get staleDataWarning => _pick(
        en: 'This saved data may be out of date until the next live refresh succeeds.',
        nl: 'Deze opgeslagen data kan verouderd zijn totdat de volgende live verversing lukt.',
        es: 'Estos datos guardados pueden estar desactualizados hasta que la siguiente actualizacion en vivo funcione.',
      );
  String get alertsFallbackTitle => _pick(
        en: 'Saved alerts unavailable',
        nl: 'Opgeslagen meldingen niet beschikbaar',
        es: 'Alertas guardadas no disponibles',
      );
  String get alertsFallbackBody => _pick(
        en: 'FightCue is using the default quiet presets until your saved alert settings load again.',
        nl: 'FightCue gebruikt tijdelijk de standaard rustige presets totdat je opgeslagen meldingen weer laden.',
        es: 'FightCue usa temporalmente los ajustes discretos por defecto hasta que vuelvan a cargar tus alertas guardadas.',
      );
  String get savedAlertsTitle => _pick(
        en: 'Showing saved alerts',
        nl: 'Opgeslagen meldingen worden getoond',
        es: 'Mostrando alertas guardadas',
      );
  String get savedAlertsBody => _pick(
        en: 'FightCue is using the last synced alert presets while the live settings reconnect.',
        nl: 'FightCue gebruikt de laatst gesynchroniseerde meldingsinstellingen terwijl de live instellingen opnieuw verbinden.',
        es: 'FightCue usa los ultimos ajustes de alertas sincronizados mientras la configuracion en vivo vuelve a conectarse.',
      );
  String get rankingsErrorBody => _pick(
        en: 'The rankings feed could not be loaded right now. You can retry without affecting the event flow.',
        nl: 'De rankingsfeed kon nu niet worden geladen. Je kunt opnieuw proberen zonder de eventflow te verstoren.',
        es: 'No se pudo cargar el feed de rankings ahora mismo. Puedes reintentar sin afectar el flujo de eventos.',
      );
  String get savedRankingsTitle => _pick(
        en: 'Showing saved rankings',
        nl: 'Opgeslagen ranglijsten worden getoond',
        es: 'Mostrando rankings guardados',
      );
  String get savedRankingsBody => _pick(
        en: 'FightCue is using the last synced rankings while the live list reconnects.',
        nl: 'FightCue gebruikt de laatst gesynchroniseerde ranglijsten terwijl de live lijst opnieuw verbindt.',
        es: 'FightCue usa los ultimos rankings sincronizados mientras la lista en vivo vuelve a conectarse.',
      );
  String get savedPushTitle => _pick(
        en: 'Showing saved push setup',
        nl: 'Opgeslagen pushstatus wordt getoond',
        es: 'Mostrando configuracion guardada de notificaciones',
      );
  String get savedPushBody => _pick(
        en: 'FightCue is using the last synced push reminder setup while the live status reconnects.',
        nl: 'FightCue gebruikt de laatst gesynchroniseerde push-instellingen terwijl de live status opnieuw verbindt.',
        es: 'FightCue usa la ultima configuracion sincronizada de notificaciones mientras el estado en vivo vuelve a conectarse.',
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
  String get mainCardTabLabel => _pick(
        en: 'Main card',
        nl: 'Main card',
        es: 'Cartelera principal',
      );
  String get preliminaryCardTabLabel => _pick(
        en: 'Preliminary card',
        nl: 'Preliminary card',
        es: 'Cartelera preliminar',
      );
  String get officialCardLabel => _pick(
        en: 'Official card',
        nl: 'Officiele kaart',
        es: 'Cartelera oficial',
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
  String get runtimeSectionTitle => _pick(
        en: 'Runtime',
        nl: 'Runtime',
        es: 'Runtime',
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
  String get quietAdSlotTitle => _pick(
        en: 'Quiet ad slot',
        nl: 'Rustige advertentieplek',
        es: 'Espacio de anuncio discreto',
      );
  String get quietAdSlotBody => _pick(
        en: 'This reserved placement is where a low-noise sponsored message will appear for free users after consent.',
        nl: 'Op deze gereserveerde plek verschijnt later een rustige gesponsorde boodschap voor gratis gebruikers na toestemming.',
        es: 'En este espacio reservado aparecera un mensaje patrocinado discreto para usuarios gratuitos despues del consentimiento.',
      );
  String get quietAdsConsentBody => _pick(
        en: 'Quiet ad slots stay disabled until ad consent is enabled in settings.',
        nl: 'Rustige advertentieplekken blijven uitgeschakeld totdat advertentietoestemming in instellingen aanstaat.',
        es: 'Los espacios de anuncios discretos permanecen desactivados hasta activar el consentimiento en ajustes.',
      );
  String get sponsoredLabel => _pick(
        en: 'Sponsored',
        nl: 'Gesponsord',
        es: 'Patrocinado',
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
  String get policyLabel => _pick(
        en: 'Policy',
        nl: 'Beleid',
        es: 'Politica',
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
  String get monetizationTitle => _pick(
        en: 'Billing and ads',
        nl: 'Billing en advertenties',
        es: 'Facturacion y anuncios',
      );
  String get monetizationBody => _pick(
        en: 'Store billing is still foundation-only, but consent, quiet-ad behavior, and premium state are already wired.',
        nl: 'Store-billing staat nog in de basisfase, maar toestemming, rustige advertentielogica en premiumstatus zijn al aangesloten.',
        es: 'La facturacion en tiendas sigue en fase base, pero el consentimiento, el comportamiento de anuncios discretos y el estado premium ya estan conectados.',
      );
  String get adConsentTitle => _pick(
        en: 'Ad consent',
        nl: 'Advertentietoestemming',
        es: 'Consentimiento de anuncios',
      );
  String get analyticsConsentTitle => _pick(
        en: 'Analytics consent',
        nl: 'Analytics-toestemming',
        es: 'Consentimiento de analiticas',
      );
  String get adConsentEnabledLabel => _pick(
        en: 'Ads allowed',
        nl: 'Ads toegestaan',
        es: 'Anuncios permitidos',
      );
  String get adConsentDisabledLabel => _pick(
        en: 'Ads off',
        nl: 'Ads uit',
        es: 'Anuncios desactivados',
      );
  String get analyticsEnabledLabel => _pick(
        en: 'Analytics on',
        nl: 'Analytics aan',
        es: 'Analiticas activadas',
      );
  String get analyticsDisabledLabel => _pick(
        en: 'Analytics off',
        nl: 'Analytics uit',
        es: 'Analiticas desactivadas',
      );
  String get monetizationSavingLabel => _pick(
        en: 'Updating',
        nl: 'Bijwerken',
        es: 'Actualizando',
      );
  String get monetizationFallbackBody => _pick(
        en: 'Billing and consent status could not be refreshed right now. The saved monetization setup stays visible.',
        nl: 'Billing- en toestemmingsstatus konden nu niet worden vernieuwd. De opgeslagen monetization-status blijft zichtbaar.',
        es: 'No se pudo actualizar el estado de facturacion y consentimiento. La configuracion guardada sigue visible.',
      );
  String get savedMonetizationTitle => _pick(
        en: 'Showing saved billing setup',
        nl: 'Opgeslagen billingstatus wordt getoond',
        es: 'Mostrando configuracion guardada de facturacion',
      );
  String get savedMonetizationBody => _pick(
        en: 'FightCue is using the last synced billing and ad-consent state while the live status reconnects.',
        nl: 'FightCue gebruikt de laatst gesynchroniseerde billing- en advertentietoestemming terwijl de live status opnieuw verbindt.',
        es: 'FightCue usa el ultimo estado sincronizado de facturacion y consentimiento de anuncios mientras el estado en vivo vuelve a conectarse.',
      );
  String get quietAdsEnabledLabel => _pick(
        en: 'Quiet ads active',
        nl: 'Rustige ads actief',
        es: 'Anuncios discretos activos',
      );
  String get quietAdsDisabledLabel => _pick(
        en: 'Quiet ads paused',
        nl: 'Rustige ads gepauzeerd',
        es: 'Anuncios discretos pausados',
      );
  String get billingFoundationTitle => _pick(
        en: 'Store billing foundation',
        nl: 'Store-billing basis',
        es: 'Base de facturacion en tienda',
      );
  String get billingFoundationBody => _pick(
        en: 'The app is prepared for Play Billing and StoreKit wiring next. Premium still stays source-of-truth driven by the backend until stores are connected.',
        nl: 'De app is voorbereid op de volgende stap met Play Billing en StoreKit. Premium blijft nog door de backend bepaald totdat stores zijn gekoppeld.',
        es: 'La app ya esta preparada para conectar Play Billing y StoreKit. Premium sigue gobernado por el backend hasta que las tiendas esten conectadas.',
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
  String get pushSetupTitle => _pick(
        en: 'Push foundations',
        nl: 'Push-basis',
        es: 'Base de notificaciones',
      );
  String get pushSetupBody => _pick(
        en: 'Quiet alert delivery is being prepared. Token registration and permissions will plug in here next.',
        nl: 'De levering van rustige meldingen wordt voorbereid. Tokenregistratie en toestemmingen sluiten hier daarna op aan.',
        es: 'La entrega de alertas discretas se esta preparando. El registro del token y los permisos se conectaran aqui despues.',
      );
  String get pushSetupFallbackBody => _pick(
        en: 'Push status could not be refreshed right now. The saved reminder setup stays intact.',
        nl: 'De pushstatus kon nu niet worden vernieuwd. De opgeslagen reminderinstellingen blijven intact.',
        es: 'No se pudo actualizar el estado de las notificaciones ahora. La configuracion guardada se mantiene.',
      );
  String get pushOffLabel => _pick(
        en: 'Off',
        nl: 'Uit',
        es: 'Desactivado',
      );
  String get pushQuietAlertsLabel => _pick(
        en: 'Quiet alerts',
        nl: 'Rustige meldingen',
        es: 'Alertas discretas',
      );
  String get pushSavingLabel => _pick(
        en: 'Saving',
        nl: 'Opslaan',
        es: 'Guardando',
      );
  String get pushConnectDeviceAction => _pick(
        en: 'Connect this device',
        nl: 'Koppel dit apparaat',
        es: 'Conectar este dispositivo',
      );
  String get pushRefreshDeviceAction => _pick(
        en: 'Refresh device status',
        nl: 'Ververs apparaatstatus',
        es: 'Actualizar estado del dispositivo',
      );
  String get pushDeviceLinkingLabel => _pick(
        en: 'Linking device',
        nl: 'Apparaat koppelen',
        es: 'Conectando dispositivo',
      );
  String get pushDeviceReadyLabel => _pick(
        en: 'Device connected',
        nl: 'Apparaat gekoppeld',
        es: 'Dispositivo conectado',
      );
  String get pushDevicePendingLabel => _pick(
        en: 'Device token pending',
        nl: 'Apparaattoken in afwachting',
        es: 'Token del dispositivo pendiente',
      );
  String get pushPermissionDeniedBody => _pick(
        en: 'Device notifications are blocked right now. Re-enable notification permission in the system settings to receive FightCue reminders on this device.',
        nl: 'Apparaatmeldingen zijn nu geblokkeerd. Zet notificatietoestemming weer aan in de systeeminstellingen om FightCue-herinneringen op dit apparaat te ontvangen.',
        es: 'Las notificaciones del dispositivo estan bloqueadas. Vuelve a activar el permiso en los ajustes del sistema para recibir recordatorios de FightCue en este dispositivo.',
      );
  String get pushPermissionPromptBody => _pick(
        en: 'FightCue can now ask the operating system for notification permission and register this device when permission is granted.',
        nl: 'FightCue kan nu het besturingssysteem om notificatietoestemming vragen en dit apparaat registreren zodra toestemming is gegeven.',
        es: 'FightCue ya puede pedir permiso de notificaciones al sistema y registrar este dispositivo cuando se conceda.',
      );
  String get pushTokenPendingBody => _pick(
        en: 'Permission is available, but this device still needs a delivery token. That can remain pending until platform push services are fully configured.',
        nl: 'Toestemming is beschikbaar, maar dit apparaat heeft nog een leveringstoken nodig. Dat kan in afwachting blijven totdat platform push-services volledig zijn geconfigureerd.',
        es: 'El permiso esta disponible, pero este dispositivo todavia necesita un token de entrega. Puede seguir pendiente hasta que los servicios push de la plataforma esten completamente configurados.',
      );
  String get pushTokenReadyBody => _pick(
        en: 'This device is ready for push delivery. FightCue can now store the platform token server-side for future reminder delivery.',
        nl: 'Dit apparaat is klaar voor push-delivery. FightCue kan nu het platformtoken server-side opslaan voor toekomstige herinneringen.',
        es: 'Este dispositivo esta listo para recibir notificaciones push. FightCue ahora puede guardar el token de la plataforma en el servidor para futuros recordatorios.',
      );
  String get pushTokenRegisteredLabel => _pick(
        en: 'Token linked',
        nl: 'Token gekoppeld',
        es: 'Token conectado',
      );
  String get pushTokenMissingLabel => _pick(
        en: 'Token pending',
        nl: 'Token ontbreekt nog',
        es: 'Token pendiente',
      );
  String pushPermissionLabel(PushPermissionStatus status) {
    switch (status) {
      case PushPermissionStatus.prompt:
        return _pick(
          en: 'Permission pending',
          nl: 'Toestemming in afwachting',
          es: 'Permiso pendiente',
        );
      case PushPermissionStatus.granted:
        return _pick(
          en: 'Permission granted',
          nl: 'Toestemming gegeven',
          es: 'Permiso concedido',
        );
      case PushPermissionStatus.denied:
        return _pick(
          en: 'Permission denied',
          nl: 'Toestemming geweigerd',
          es: 'Permiso denegado',
        );
      case PushPermissionStatus.unknown:
        return _pick(
          en: 'Permission unknown',
          nl: 'Toestemming onbekend',
          es: 'Permiso desconocido',
        );
    }
  }

  String pushStatusSummary({
    required bool enabled,
    required String permissionLabel,
    required String tokenLabel,
  }) {
    return _pick(
      en: enabled
          ? 'Quiet alerts are enabled for this device foundation. $permissionLabel. $tokenLabel.'
          : 'Quiet alerts are currently off for this device foundation. $permissionLabel. $tokenLabel.',
      nl: enabled
          ? 'Rustige meldingen staan aan voor deze device-basis. $permissionLabel. $tokenLabel.'
          : 'Rustige meldingen staan nu uit voor deze device-basis. $permissionLabel. $tokenLabel.',
      es: enabled
          ? 'Las alertas discretas estan activadas para esta base del dispositivo. $permissionLabel. $tokenLabel.'
          : 'Las alertas discretas estan desactivadas para esta base del dispositivo. $permissionLabel. $tokenLabel.',
    );
  }
}
