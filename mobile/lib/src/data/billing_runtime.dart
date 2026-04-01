import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../core/runtime/app_diagnostics.dart';

class BillingRuntimeStatus {
  const BillingRuntimeStatus({
    required this.storeAvailable,
    required this.foundProductIds,
    required this.missingProductIds,
  });

  final bool storeAvailable;
  final List<String> foundProductIds;
  final List<String> missingProductIds;

  bool get fullyReady => storeAvailable && missingProductIds.isEmpty;
}

class BillingRuntimeService {
  Future<BillingRuntimeStatus> getStatus(List<String> productIds) async {
    if (kIsWeb) {
      return BillingRuntimeStatus(
        storeAvailable: false,
        foundProductIds: const [],
        missingProductIds: productIds,
      );
    }

    try {
      final storeAvailable = await InAppPurchase.instance.isAvailable();
      if (!storeAvailable || productIds.isEmpty) {
        return BillingRuntimeStatus(
          storeAvailable: storeAvailable,
          foundProductIds: const [],
          missingProductIds: productIds,
        );
      }

      final response = await InAppPurchase.instance.queryProductDetails(
        productIds.toSet(),
      );
      return BillingRuntimeStatus(
        storeAvailable: storeAvailable,
        foundProductIds: response.productDetails.map((item) => item.id).toList(),
        missingProductIds: response.notFoundIDs.toList(),
      );
    } catch (error, stackTrace) {
      logUiError(error, stackTrace, context: 'billing_runtime.status');
      return BillingRuntimeStatus(
        storeAvailable: false,
        foundProductIds: const [],
        missingProductIds: productIds,
      );
    }
  }
}
