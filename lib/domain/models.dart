/// Plain, immutable domain models. No Flutter or database imports here, so
/// everything in `domain/` can be unit-tested in isolation.
library;

enum CardNetwork {
  visa('VISA'),
  mastercard('MASTERCARD'),
  rupay('RUPAY'),
  amex('AMEX'),
  diners('DINERS');

  const CardNetwork(this.code);
  final String code;

  static CardNetwork fromCode(String code) => CardNetwork.values.firstWhere(
        (n) => n.code == code.toUpperCase(),
        orElse: () => CardNetwork.visa,
      );

  /// Only RuPay credit cards can be linked to UPI in India.
  bool get worksOnUpi => this == CardNetwork.rupay;

  String get label => switch (this) {
        CardNetwork.visa => 'VISA',
        CardNetwork.mastercard => 'MASTERCARD',
        CardNetwork.rupay => 'RuPay',
        CardNetwork.amex => 'AMEX',
        CardNetwork.diners => 'Diners Club',
      };
}

/// Spend categories. Codes are shared with the catalog JSON.
enum SpendCategory {
  utilities('UTILITIES', 'Utilities'),
  telecom('TELECOM', 'Phone & internet'),
  foodDelivery('FOOD_DELIVERY', 'Food delivery'),
  dining('DINING', 'Dining'),
  groceries('GROCERIES', 'Groceries'),
  fuel('FUEL', 'Fuel'),
  shopping('SHOPPING', 'Shopping'),
  travel('TRAVEL', 'Travel'),
  foreign('FOREIGN', 'Foreign'),
  rent('RENT', 'Rent'),
  insurance('INSURANCE', 'Insurance'),
  other('OTHER', 'Other');

  const SpendCategory(this.code, this.label);
  final String code;
  final String label;

  static SpendCategory fromCode(String code) => SpendCategory.values
      .firstWhere((c) => c.code == code, orElse: () => SpendCategory.other);
}

enum BenefitKind {
  /// Cashback or reward points expressed as an effective value rate.
  reward('REWARD'),

  /// Forex markup charged on international spends (rateBps = markup).
  forexMarkup('FOREX_MARKUP'),

  /// Informational benefit (lounge, insurance, …) with no rate maths.
  info('INFO');

  const BenefitKind(this.code);
  final String code;

  static BenefitKind fromCode(String code) => BenefitKind.values
      .firstWhere((k) => k.code == code, orElse: () => BenefitKind.info);
}

class Benefit {
  const Benefit({
    required this.id,
    required this.category,
    required this.kind,
    required this.title,
    this.rateBps,
    this.monthlyCapPaise,
    this.minTxnPaise,
    this.channel,
    this.conditions,
    this.lastVerified,
  });

  final String id;
  final SpendCategory category;
  final BenefitKind kind;
  final String title;

  /// Effective return (reward) or markup (forex) in basis points.
  /// 0 means the category is excluded from rewards.
  final int? rateBps;
  final int? monthlyCapPaise;
  final int? minTxnPaise;

  /// e.g. "Airtel Thanks app": the reward only applies via this channel.
  final String? channel;
  final String? conditions;
  final DateTime? lastVerified;

  /// Benefits not verified for 180 days get a "Verify" badge.
  bool isStale(DateTime now) =>
      lastVerified == null || now.difference(lastVerified!).inDays > 180;
}

class UserCard {
  const UserCard({
    required this.id,
    required this.productId,
    required this.bankName,
    required this.name,
    required this.network,
    required this.creditLimitPaise,
    required this.statementDay,
    required this.dueDay,
    this.nickname,
    this.last4,
    this.annualFeePaise = 0,
    this.waiverSpendPaise,
    this.anniversaryMonth,
    this.faceColor = 0xFF6A5AE0,
  });

  final String id;
  final String productId;
  final String bankName;
  final String name;
  final String? nickname;
  final CardNetwork network;

  /// Last 4 digits only. The full card number and CVV are never stored.
  final String? last4;
  final int creditLimitPaise;
  final int statementDay;
  final int dueDay;
  final int annualFeePaise;
  final int? waiverSpendPaise;

  /// 1-12. The fee-waiver year runs from the 1st of this month.
  final int? anniversaryMonth;
  final int faceColor;

  String get displayName => nickname?.isNotEmpty == true ? nickname! : name;
}

enum PaymentKind { card, bankUpi, cash }

enum PayeeType { merchant, person }

class Spend {
  const Spend({
    required this.id,
    required this.amountPaise,
    required this.category,
    required this.paymentKind,
    required this.spentOn,
    this.userCardId,
    this.viaUpi = false,
    this.international = false,
    this.payee = PayeeType.merchant,
    this.note,
  });

  final String id;
  final int amountPaise;
  final SpendCategory category;
  final PaymentKind paymentKind;
  final String? userCardId;
  final bool viaUpi;
  final bool international;
  final PayeeType payee;
  final String? note;
  final DateTime spentOn;
}
