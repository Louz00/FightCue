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
        en: 'Upcoming boxing, MMA, UFC, and Glory Kickboxing events in your timezone.',
        nl: 'Aankomende boksen-, MMA-, UFC- en Glory Kickboxing-events in jouw tijdzone.',
        es: 'Proximos eventos de boxeo, MMA, UFC y Glory Kickboxing en tu zona horaria.',
      );
  String get following => _pick(
        en: 'Favorites',
        nl: 'Favorieten',
        es: 'Favoritos',
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
        en: 'Leaderboard',
        nl: 'Leaderboard',
        es: 'Leaderboard',
      );
  String get rankingsTitle => _pick(
        en: 'Leaderboard',
        nl: 'Leaderboard',
        es: 'Leaderboard',
      );
  String get rankingsSubtitle => _pick(
        en: 'Clean combat-sports leaderboards with clear source labels and room for longer lists.',
        nl: 'Strakke combat-sports leaderboards met duidelijke bronvermelding en ruimte voor langere lijsten.',
        es: 'Leaderboards limpios de deportes de combate con fuente clara y espacio para listas mas largas.',
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
        en: 'Language, notifications, timezone, and premium.',
        nl: 'Taal, meldingen, tijdzone en premium.',
        es: 'Idioma, notificaciones, zona horaria y premium.',
      );
  String get yourTime => _pick(
        en: 'your time',
        nl: 'jouw tijd',
        es: 'tu hora',
      );
  String get followingTitle => _pick(
        en: 'Favorites',
        nl: 'Favorieten',
        es: 'Favoritos',
      );
  String get followingSubtitle => _pick(
        en: 'Quick access to saved fighters and saved events.',
        nl: 'Snelle toegang tot opgeslagen vechters en opgeslagen events.',
        es: 'Acceso rapido a peleadores guardados y eventos guardados.',
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
        en: 'Saved fighters',
        nl: 'Opgeslagen vechters',
        es: 'Peleadores guardados',
      );
  String get followedEventsTitle => _pick(
        en: 'Saved events',
        nl: 'Opgeslagen events',
        es: 'Eventos guardados',
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
        en: 'Glory Kickboxing',
        nl: 'Glory Kickboxing',
        es: 'Glory Kickboxing',
      );
  String get filterMmaLabel => _pick(
        en: 'MMA',
        nl: 'MMA',
        es: 'MMA',
      );
  String get filterResetLabel => _pick(
        en: 'All',
        nl: 'Alles',
        es: 'Todo',
      );
  String get upcomingEventsTitle => _pick(
        en: 'Upcoming events',
        nl: 'Aankomende evenementen',
        es: 'Proximos eventos',
      );
  String get filteredFeedTitle => _pick(
        en: 'Choose one or more filters',
        nl: 'Kies een of meer filters',
        es: 'Elige uno o mas filtros',
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
