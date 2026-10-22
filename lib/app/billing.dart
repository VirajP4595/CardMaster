import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/db/database.dart';
import '../domain/entitlement.dart';
import 'providers.dart';

/// Pro and tips gate. Stays false until `pro_lifetime` and the tip products
/// exist in Play Console; flip it in the release that starts selling Pro.
const proGatingEnabled = false;

/// Google Play Billing (docs/07 §3). Purchases are handled by the Play
/// Store app; this app only learns "purchased" or "not". Play verifies the
/// purchase; there's no server here to double-check it, by design.
class Billing {
  Billing._();
  static final instance = Billing._();

  StreamSubscription<List<PurchaseDetails>>? _sub;

  void listen(AppDatabase db) {
    _sub ??= InAppPurchase.instance.purchaseStream.listen(
      (purchases) async {
        for (final p in purchases) {
          if (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored) {
            if (p.productID == ProductIds.pro) {
              await db.setValue(SettingKeys.proPurchased, 'true');
            } else {
              await db.setValue(SettingKeys.supporter, 'true');
            }
          }
          if (p.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(p);
          }
        }
      },
      onError: (_) {},
    );
  }

  /// Products as set up in Play Console, or empty when billing isn't
  /// available (not installed from Play, or products not created yet).
  Future<Map<String, ProductDetails>> products() async {
    try {
      if (!await InAppPurchase.instance.isAvailable()) return const {};
      final r = await InAppPurchase.instance.queryProductDetails(ProductIds.all);
      return {for (final p in r.productDetails) p.id: p};
    } on MissingPluginException {
      return const {};
    } on PlatformException {
      return const {};
    }
  }

  Future<void> buyPro(ProductDetails p) => InAppPurchase.instance
      .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));

  Future<void> tip(ProductDetails p) => InAppPurchase.instance
      .buyConsumable(purchaseParam: PurchaseParam(productDetails: p));

  Future<void> restore() async {
    try {
      await InAppPurchase.instance.restorePurchases();
    } on MissingPluginException {
      // Not on a device with Play.
    }
  }
}
