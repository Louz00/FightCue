import 'package:flutter/material.dart';

import '../../core/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/billing_runtime.dart';
import '../../data/fightcue_api.dart';
import '../../models/domain_models.dart';
import '../../widgets/editorial_ui.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({
    super.key,
    required this.api,
    required this.strings,
    required this.snapshot,
    this.billingRuntimeService,
  });

  final FightCueApi api;
  final AppStrings strings;
  final MonetizationSnapshot snapshot;
  final BillingRuntimeService? billingRuntimeService;

  @override
  Widget build(BuildContext context) {
    final isPremium = snapshot.premiumState == PremiumState.premium;
    final planLabel = isPremium ? strings.premiumPlanLabel : strings.freePlanLabel;

    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundFor(context),
        foregroundColor: AppColors.textPrimaryFor(context),
        title: Text(strings.paywallTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          EditorialPageHero(
            eyebrow: strings.premiumPlanLabel.toUpperCase(),
            title: strings.paywallTitle,
            body: strings.paywallSubtitle,
            trailingLabel: planLabel,
          ),
          const SizedBox(height: 24),
          EditorialSectionTitle(label: strings.paywallCurrentPlanTitle),
          const SizedBox(height: 12),
          EditorialNoticeCard(
            title: planLabel,
            body: strings.paywallCurrentPlanBody(planLabel),
          ),
          const SizedBox(height: 20),
          EditorialSectionTitle(label: strings.paywallBenefitsTitle),
          const SizedBox(height: 12),
          EditorialSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BenefitRow(label: strings.paywallBenefitNoAds),
                const SizedBox(height: 12),
                _BenefitRow(label: strings.paywallBenefitAlerts),
                const SizedBox(height: 12),
                _BenefitRow(label: strings.paywallBenefitRestore),
              ],
            ),
          ),
          const SizedBox(height: 20),
          EditorialSectionTitle(label: strings.paywallComparisonTitle),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PlanCard(
                  title: strings.paywallFreeColumnTitle,
                  body: strings.paywallFreeSummary,
                  active: !isPremium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PlanCard(
                  title: strings.paywallPremiumColumnTitle,
                  body: strings.paywallPremiumSummary,
                  active: isPremium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          EditorialSectionTitle(label: strings.paywallStoreReadinessTitle),
          const SizedBox(height: 12),
          EditorialNoticeCard(
            title: strings.billingFoundationTitle,
            body: strings.paywallStoreReadinessBody,
          ),
          const SizedBox(height: 12),
          FutureBuilder<_PaywallProviderState>(
            future: _loadProviderState(
              api,
              billingRuntimeService ?? BillingRuntimeService(),
            ),
            builder: (context, providerSnapshot) {
              if (!providerSnapshot.hasData) {
                return const EditorialLoadingCard();
              }

              final state = providerSnapshot.data!;
              return EditorialSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.storeProviderStatusBody(
                        providerLabel: strings.billingProviderLabel(
                          state.billingProvider.provider,
                        ),
                        configured: state.billingProvider.configured,
                        runtimeReady: state.billingRuntime.fullyReady,
                      ),
                      style: TextStyle(
                        color: AppColors.textSecondaryFor(context),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.adProviderStatusBody(
                        providerLabel: strings.adProviderLabel(
                          state.adProvider.provider,
                        ),
                        configured: state.adProvider.configured,
                        bannerConfigured:
                            state.adProvider.bannerUnitConfigured,
                      ),
                      style: TextStyle(
                        color: AppColors.textSecondaryFor(context),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.paywallCheckoutPlaceholder)),
              );
            },
            child: Text(strings.paywallPrimaryCta),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(strings.paywallSecondaryCta),
          ),
        ],
      ),
    );
  }
}

class _PaywallProviderState {
  const _PaywallProviderState({
    required this.billingProvider,
    required this.billingRuntime,
    required this.adProvider,
  });

  final BillingProviderStatusSnapshot billingProvider;
  final BillingRuntimeStatus billingRuntime;
  final AdProviderStatusSnapshot adProvider;
}

Future<_PaywallProviderState> _loadProviderState(
  FightCueApi api,
  BillingRuntimeService billingRuntimeService,
) async {
  final billingProvider = await api.fetchBillingProviderStatus();
  final adProvider = await api.fetchAdProviderStatus();
  final billingRuntime = await billingRuntimeService.getStatus(
    billingProvider.productIds,
  );

  return _PaywallProviderState(
    billingProvider: billingProvider,
    billingRuntime: billingRuntime,
    adProvider: adProvider,
  );
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimaryFor(context),
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.body,
    required this.active,
  });

  final String title;
  final String body;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: active,
      label: title,
      child: EditorialSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditorialActionPill(
              label: title,
              emphasized: active,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(
                color: AppColors.textSecondaryFor(context),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
