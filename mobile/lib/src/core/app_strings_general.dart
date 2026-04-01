part of 'app_strings.dart';

extension AppStringsGeneral on AppStrings {
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
}
