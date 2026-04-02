part of 'app_strings.dart';

extension AppStringsSettings on AppStrings {
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
        en: 'Card updates',
        nl: 'Kaartupdates',
        es: 'Actualizaciones de cartelera',
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
  String billingProviderLabel(BillingProviderType provider) {
    switch (provider) {
      case BillingProviderType.storekitPlay:
        return _pick(
          en: 'StoreKit / Play Billing',
          nl: 'StoreKit / Play Billing',
          es: 'StoreKit / Play Billing',
        );
      case BillingProviderType.disabled:
        return _pick(
          en: 'Disabled',
          nl: 'Uitgeschakeld',
          es: 'Desactivado',
        );
    }
  }
  String adProviderLabel(AdProviderType provider) {
    switch (provider) {
      case AdProviderType.googleAdmob:
        return _pick(
          en: 'Google AdMob',
          nl: 'Google AdMob',
          es: 'Google AdMob',
        );
      case AdProviderType.disabled:
        return _pick(
          en: 'Disabled',
          nl: 'Uitgeschakeld',
          es: 'Desactivado',
        );
    }
  }
  String storeProviderStatusBody({
    required String providerLabel,
    required bool configured,
    required bool runtimeReady,
  }) =>
      _pick(
        en: '$providerLabel is ${configured ? 'configured' : 'not configured'} on the backend. Runtime store readiness is ${runtimeReady ? 'ready' : 'still pending'} on this device.',
        nl: '$providerLabel is ${configured ? 'geconfigureerd' : 'nog niet geconfigureerd'} op de backend. De runtime store-status is ${runtimeReady ? 'klaar' : 'nog in afwachting'} op dit apparaat.',
        es: '$providerLabel esta ${configured ? 'configurado' : 'sin configurar'} en el backend. La disponibilidad de la tienda en este dispositivo esta ${runtimeReady ? 'lista' : 'todavia pendiente'}.',
      );
  String adProviderStatusBody({
    required String providerLabel,
    required bool configured,
    required bool bannerConfigured,
  }) =>
      _pick(
        en: '$providerLabel is ${configured ? 'configured' : 'not fully configured'} for FightCue. Banner readiness is ${bannerConfigured ? 'available' : 'still missing unit IDs'}.',
        nl: '$providerLabel is ${configured ? 'geconfigureerd' : 'nog niet volledig geconfigureerd'} voor FightCue. Banner-readiness is ${bannerConfigured ? 'beschikbaar' : 'nog zonder unit IDs'}.',
        es: '$providerLabel esta ${configured ? 'configurado' : 'todavia no completamente configurado'} para FightCue. La disponibilidad del banner esta ${bannerConfigured ? 'lista' : 'todavia sin unit IDs'}.',
      );
  String adRuntimeStatusBody({
    required bool sdkReady,
    required bool usingTestIdentifiers,
    required bool bannerReady,
  }) =>
      _pick(
        en:
            'Local ad runtime is ${sdkReady ? 'ready' : 'not ready'} on this device. ${usingTestIdentifiers ? 'Google test IDs are active for safe local testing.' : 'FightCue is using configured production ad IDs.'} Banner rendering is ${bannerReady ? 'available' : 'still unavailable'}.',
        nl:
            'De lokale advertentie-runtime is ${sdkReady ? 'klaar' : 'nog niet klaar'} op dit apparaat. ${usingTestIdentifiers ? "Google test-ID's zijn actief voor veilig lokaal testen." : "FightCue gebruikt geconfigureerde productie-ad-ID's."} Bannerweergave is ${bannerReady ? 'beschikbaar' : 'nog niet beschikbaar'}.',
        es:
            'La ejecucion local de anuncios esta ${sdkReady ? 'lista' : 'todavia no lista'} en este dispositivo. ${usingTestIdentifiers ? 'Los IDs de prueba de Google estan activos para pruebas locales seguras.' : 'FightCue usa IDs de anuncios de produccion configurados.'} La visualizacion del banner esta ${bannerReady ? 'disponible' : 'todavia no disponible'}.',
      );
  String crashReportingStatusBody({
    required String providerLabel,
    required bool available,
    String? reason,
  }) =>
      _pick(
        en:
            'Crash reporting provider: $providerLabel. Runtime collection is ${available ? 'available' : 'disabled for this build/runtime'}${reason != null && reason.isNotEmpty ? ' ($reason)' : ''}.',
        nl:
            'Crash-reportingprovider: $providerLabel. Runtime-verzameling is ${available ? 'beschikbaar' : 'uitgeschakeld voor deze build/runtime'}${reason != null && reason.isNotEmpty ? ' ($reason)' : ''}.',
        es:
            'Proveedor de informes de fallos: $providerLabel. La recopilacion en tiempo de ejecucion esta ${available ? 'disponible' : 'desactivada para esta build/runtime'}${reason != null && reason.isNotEmpty ? ' ($reason)' : ''}.',
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
