part of 'app_strings.dart';

extension AppStringsOffline on AppStrings {
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
    final timestampLine =
        syncedAt == null ? offlineTimestampUnknown : offlineTimestampLabel(syncedAt);
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
  String get pushSetupFallbackBody => _pick(
        en: 'Push status could not be refreshed right now. The saved reminder setup stays intact.',
        nl: 'De pushstatus kon nu niet worden vernieuwd. De opgeslagen reminderinstellingen blijven intact.',
        es: 'No se pudo actualizar el estado de las notificaciones ahora. La configuracion guardada se mantiene.',
      );
}
