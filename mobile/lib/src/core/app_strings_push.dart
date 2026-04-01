part of 'app_strings.dart';

extension AppStringsPush on AppStrings {
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

  String pushProviderLabel(PushProviderType provider) {
    switch (provider) {
      case PushProviderType.disabled:
        return _pick(
          en: 'Provider disabled',
          nl: 'Provider uitgeschakeld',
          es: 'Proveedor desactivado',
        );
      case PushProviderType.log:
        return _pick(
          en: 'Local log delivery',
          nl: 'Lokale log-delivery',
          es: 'Entrega local en logs',
        );
      case PushProviderType.firebase:
        return _pick(
          en: 'Firebase delivery',
          nl: 'Firebase-delivery',
          es: 'Entrega con Firebase',
        );
    }
  }

  String pushProviderStatusBody({
    required bool configured,
    required String description,
  }) {
    return _pick(
      en: configured
          ? description
          : 'Provider setup still needs credentials. $description',
      nl: configured
          ? description
          : 'De provider-inrichting heeft nog credentials nodig. $description',
      es: configured
          ? description
          : 'La configuracion del proveedor aun necesita credenciales. $description',
    );
  }

  String pushReadinessLabel(PushDeliveryReadiness readiness) {
    switch (readiness) {
      case PushDeliveryReadiness.ready:
        return _pick(
          en: 'Ready to send',
          nl: 'Klaar om te verzenden',
          es: 'Listo para enviar',
        );
      case PushDeliveryReadiness.disabled:
        return _pick(
          en: 'Push disabled',
          nl: 'Push uitgeschakeld',
          es: 'Push desactivado',
        );
      case PushDeliveryReadiness.permissionRequired:
        return _pick(
          en: 'Permission still needed',
          nl: 'Nog toestemming nodig',
          es: 'Aun falta permiso',
        );
      case PushDeliveryReadiness.tokenMissing:
        return _pick(
          en: 'Token still missing',
          nl: 'Token ontbreekt nog',
          es: 'Aun falta el token',
        );
    }
  }

  String pushPreviewCountsLabel({
    required int scheduledCount,
    required int signalCount,
  }) {
    return _pick(
      en: '$scheduledCount scheduled, $signalCount signal-based reminders',
      nl: '$scheduledCount geplande, $signalCount signaalgebaseerde herinneringen',
      es: '$scheduledCount programados, $signalCount recordatorios por senal',
    );
  }

  String get pushSendTestAction => _pick(
        en: 'Send test reminder',
        nl: 'Verstuur testherinnering',
        es: 'Enviar recordatorio de prueba',
      );

  String get pushTestQueuedLabel => _pick(
        en: 'Test reminder queued',
        nl: 'Testherinnering ingepland',
        es: 'Recordatorio de prueba en cola',
      );
}
