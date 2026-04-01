part of 'app_strings.dart';

extension AppStringsPaywall on AppStrings {
  String get paywallTitle => _pick(
        en: 'FightCue Premium',
        nl: 'FightCue Premium',
        es: 'FightCue Premium',
      );
  String get paywallSubtitle => _pick(
        en: 'Keep the app quiet, faster to scan, and more reliable around the fights you care about most.',
        nl: 'Houd de app rustig, sneller scanbaar en betrouwbaarder rond de gevechten die jij het belangrijkst vindt.',
        es: 'Mantiene la app discreta, mas rapida de escanear y mas fiable en torno a las peleas que mas te importan.',
      );
  String get paywallBenefitsTitle => _pick(
        en: 'What premium adds',
        nl: 'Wat premium toevoegt',
        es: 'Lo que agrega premium',
      );
  String get paywallBenefitNoAds => _pick(
        en: 'No quiet ads anywhere in the app.',
        nl: 'Geen rustige advertenties meer in de app.',
        es: 'Sin anuncios discretos en toda la app.',
      );
  String get paywallBenefitAlerts => _pick(
        en: 'Stronger reminder confidence for followed fighters and cards.',
        nl: 'Sterkere herinneringszekerheid voor gevolgde vechters en fight cards.',
        es: 'Mayor confianza en recordatorios para peleadores y carteleras seguidas.',
      );
  String get paywallBenefitRestore => _pick(
        en: 'Prepared for store restore and entitlement sync once billing goes live.',
        nl: 'Voorbereid op store-herstel en entitlement-sync zodra billing live gaat.',
        es: 'Preparado para restauracion en tienda y sincronizacion de derechos cuando la facturacion este activa.',
      );
  String get paywallComparisonTitle => _pick(
        en: 'Plan comparison',
        nl: 'Vergelijking van plannen',
        es: 'Comparacion de planes',
      );
  String get paywallFreeColumnTitle => _pick(
        en: 'Free',
        nl: 'Gratis',
        es: 'Gratis',
      );
  String get paywallPremiumColumnTitle => _pick(
        en: 'Premium',
        nl: 'Premium',
        es: 'Premium',
      );
  String get paywallFreeSummary => _pick(
        en: 'Quiet feed ads after consent, full event tracking, and the same live schedules.',
        nl: 'Rustige feed-ads na toestemming, volledige event-tracking en dezelfde live agenda’s.',
        es: 'Anuncios discretos en el feed tras el consentimiento, seguimiento completo de eventos y la misma agenda en vivo.',
      );
  String get paywallPremiumSummary => _pick(
        en: 'Ad-free experience, premium-ready alert confidence, and a cleaner launch path for restore later.',
        nl: 'Advertentievrije ervaring, premium-ready meldingszekerheid en later een schonere restore-flow.',
        es: 'Experiencia sin anuncios, mayor confianza en alertas premium y una ruta mas limpia para restaurar despues.',
      );
  String get paywallCurrentPlanTitle => _pick(
        en: 'Current plan status',
        nl: 'Status van huidig plan',
        es: 'Estado del plan actual',
      );
  String paywallCurrentPlanBody(String planLabel) => _pick(
        en: 'This device is currently using $planLabel.',
        nl: 'Dit apparaat gebruikt momenteel $planLabel.',
        es: 'Este dispositivo esta usando actualmente $planLabel.',
      );
  String get paywallStoreReadinessTitle => _pick(
        en: 'Store checkout status',
        nl: 'Status van store-checkout',
        es: 'Estado del checkout en tienda',
      );
  String get paywallStoreReadinessBody => _pick(
        en: 'The app is already prepared for StoreKit and Play Billing wiring, but live checkout is not connected in this build yet.',
        nl: 'De app is al voorbereid op StoreKit- en Play Billing-koppeling, maar live checkout is in deze build nog niet verbonden.',
        es: 'La app ya esta preparada para StoreKit y Play Billing, pero el checkout en vivo aun no esta conectado en esta build.',
      );
  String get paywallPrimaryCta => _pick(
        en: 'Premium checkout next',
        nl: 'Premium-checkout volgt',
        es: 'Checkout premium despues',
      );
  String get paywallSecondaryCta => _pick(
        en: 'Keep current plan',
        nl: 'Houd huidig plan',
        es: 'Mantener plan actual',
      );
  String get paywallCheckoutPlaceholder => _pick(
        en: 'Store checkout is the next step. The premium screen is ready, but billing is not wired to Apple and Google yet.',
        nl: 'Store-checkout is de volgende stap. Het premiumscherm is klaar, maar billing is nog niet gekoppeld aan Apple en Google.',
        es: 'El checkout en tienda es el siguiente paso. La pantalla premium ya esta lista, pero la facturacion aun no esta conectada a Apple y Google.',
      );
  String get paywallViewPlansLabel => _pick(
        en: 'View premium plans',
        nl: 'Bekijk premiumplannen',
        es: 'Ver planes premium',
      );
}
