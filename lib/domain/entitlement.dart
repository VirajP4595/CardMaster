/// Pro entitlement (docs/07 §3): a one-time purchase, or the 14-day trial.
class Entitlement {
  const Entitlement({
    required this.purchased,
    required this.trialStart,
    required this.gatingEnabled,
  });

  static const trialDays = 14;

  final bool purchased;
  final DateTime trialStart;

  /// Off until the in-app products exist on Google Play: until then every
  /// feature is unlocked, so nobody hits a paywall they can't pay through.
  final bool gatingEnabled;

  int trialDaysLeft(DateTime now) {
    final left = trialDays - now.difference(trialStart).inDays;
    return left.clamp(0, trialDays);
  }

  bool inTrial(DateTime now) => trialDaysLeft(now) > 0;

  bool hasPro(DateTime now) => !gatingEnabled || purchased || inTrial(now);
}

/// Play product ids (set up in Play Console with these exact ids).
abstract final class ProductIds {
  static const pro = 'pro_lifetime';
  static const coffees = ['coffee_chai', 'coffee_regular', 'coffee_snack'];

  /// "Custom" tip steps: Play products have fixed prices.
  static const tipTiers = [
    'tip_29', 'tip_49', 'tip_99', 'tip_149', 'tip_199', 'tip_299', 'tip_499',
    'tip_999',
  ];

  static Set<String> get all => {pro, ...coffees, ...tipTiers};
}
