import 'package:drift/drift.dart';

import '../../domain/models.dart' as m;

part 'database.g.dart';

@DataClassName('UserCardRow')
class UserCards extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get bankName => text()();
  TextColumn get name => text()();
  TextColumn get nickname => text().nullable()();
  TextColumn get network => text()();

  /// Last 4 digits only. There is deliberately no column for the full card
  /// number or CVV (rule R3).
  TextColumn get last4 => text().withLength(min: 4, max: 4).nullable()();
  IntColumn get creditLimitPaise => integer()();
  IntColumn get statementDay => integer()();
  IntColumn get dueDay => integer()();
  IntColumn get annualFeePaise => integer().withDefault(const Constant(0))();
  IntColumn get waiverSpendPaise => integer().nullable()();
  IntColumn get anniversaryMonth => integer().nullable()();
  IntColumn get faceColor => integer()();
  TextColumn get faceFinish => text().withDefault(const Constant('matte'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SpendRow')
class Spends extends Table {
  TextColumn get id => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get category => text()();
  TextColumn get paymentKind => text()(); // card | bankUpi | cash
  TextColumn get userCardId => text().nullable()();
  BoolColumn get viaUpi => boolean().withDefault(const Constant(false))();
  BoolColumn get international =>
      boolean().withDefault(const Constant(false))();
  TextColumn get payee => text().withDefault(const Constant('merchant'))();
  TextColumn get merchant => text().nullable()();
  TextColumn get note => text().nullable()();

  /// MANUAL | SHARE | CLIPBOARD (docs/08 §5).
  TextColumn get source => text().withDefault(const Constant('MANUAL'))();
  DateTimeColumn get spentOn => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The user's corrections to catalog benefits for one of their cards.
/// Catalog updates never overwrite these.
class BenefitOverrides extends Table {
  TextColumn get userCardId => text()();
  TextColumn get benefitId => text()();
  IntColumn get rateBps => integer().nullable()();
  IntColumn get monthlyCapPaise => integer().nullable()();
  DateTimeColumn get verifiedOn => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userCardId, benefitId};
}

/// Merchant memory: "BESCOM" -> Utilities.
class MerchantRules extends Table {
  TextColumn get merchant => text()();
  TextColumn get category => text()();
  IntColumn get hits => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {merchant};
}

/// Every network request the app made, shown in the Trust Center.
class NetworkLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get at => dateTime()();
  TextColumn get method => text()();
  TextColumn get url => text()();
  IntColumn get bytes => integer()();
  IntColumn get status => integer()();
}

/// Small settings and state (catalog version, onboarding done, …).
class KeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  UserCards,
  Spends,
  BenefitOverrides,
  MerchantRules,
  NetworkLogs,
  KeyValues,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  // ---- Cards ----

  Stream<List<m.UserCard>> watchCards() =>
      (select(userCards)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch()
          .map((rows) => rows.map(_toCard).toList());

  Future<List<m.UserCard>> allCards() async =>
      (await select(userCards).get()).map(_toCard).toList();

  Future<void> upsertCard(m.UserCard c, {String finish = 'matte'}) =>
      into(userCards).insertOnConflictUpdate(UserCardsCompanion.insert(
        id: c.id,
        productId: c.productId,
        bankName: c.bankName,
        name: c.name,
        nickname: Value(c.nickname),
        network: c.network.code,
        last4: Value(c.last4),
        creditLimitPaise: c.creditLimitPaise,
        statementDay: c.statementDay,
        dueDay: c.dueDay,
        annualFeePaise: Value(c.annualFeePaise),
        waiverSpendPaise: Value(c.waiverSpendPaise),
        anniversaryMonth: Value(c.anniversaryMonth),
        faceColor: c.faceColor,
        faceFinish: Value(finish),
        createdAt: DateTime.now(),
      ));

  Future<void> deleteCard(String id) => transaction(() async {
        await (delete(userCards)..where((t) => t.id.equals(id))).go();
        await (delete(benefitOverrides)..where((t) => t.userCardId.equals(id)))
            .go();
        // Keep the spends but detach them, so history and budgets survive.
        await (update(spends)..where((t) => t.userCardId.equals(id))).write(
            const SpendsCompanion(
                userCardId: Value(null), paymentKind: Value('bankUpi')));
      });

  Future<String?> faceFinish(String cardId) async =>
      (await (select(userCards)..where((t) => t.id.equals(cardId)))
              .getSingleOrNull())
          ?.faceFinish;

  m.UserCard _toCard(UserCardRow r) => m.UserCard(
        id: r.id,
        productId: r.productId,
        bankName: r.bankName,
        name: r.name,
        nickname: r.nickname,
        network: m.CardNetwork.fromCode(r.network),
        last4: r.last4,
        creditLimitPaise: r.creditLimitPaise,
        statementDay: r.statementDay,
        dueDay: r.dueDay,
        annualFeePaise: r.annualFeePaise,
        waiverSpendPaise: r.waiverSpendPaise,
        anniversaryMonth: r.anniversaryMonth,
        faceColor: r.faceColor,
      );

  // ---- Spends ----

  Stream<List<m.Spend>> watchSpends() =>
      (select(spends)..orderBy([(t) => OrderingTerm.desc(t.spentOn)]))
          .watch()
          .map((rows) => rows.map(_toSpend).toList());

  Future<List<m.Spend>> allSpends() async =>
      (await select(spends).get()).map(_toSpend).toList();

  Future<void> addSpend(m.Spend s,
          {String? merchant, String source = 'MANUAL'}) =>
      into(spends).insert(SpendsCompanion.insert(
        id: s.id,
        amountPaise: s.amountPaise,
        category: s.category.code,
        paymentKind: s.paymentKind.name,
        userCardId: Value(s.userCardId),
        viaUpi: Value(s.viaUpi),
        international: Value(s.international),
        payee: Value(s.payee.name),
        merchant: Value(merchant),
        note: Value(s.note),
        source: Value(source),
        spentOn: s.spentOn,
        createdAt: DateTime.now(),
      ));

  Future<void> deleteSpend(String id) =>
      (delete(spends)..where((t) => t.id.equals(id))).go();

  m.Spend _toSpend(SpendRow r) => m.Spend(
        id: r.id,
        amountPaise: r.amountPaise,
        category: m.SpendCategory.fromCode(r.category),
        paymentKind: m.PaymentKind.values.byName(r.paymentKind),
        userCardId: r.userCardId,
        viaUpi: r.viaUpi,
        international: r.international,
        payee: m.PayeeType.values.byName(r.payee),
        note: r.note ?? r.merchant,
        spentOn: r.spentOn,
      );

  // ---- Benefit overrides ----

  Future<Map<String, BenefitOverride>> overridesFor(String cardId) async {
    final rows = await (select(benefitOverrides)
          ..where((t) => t.userCardId.equals(cardId)))
        .get();
    return {for (final r in rows) r.benefitId: r};
  }

  Stream<List<BenefitOverride>> watchOverrides() =>
      select(benefitOverrides).watch();

  Future<void> saveOverride(BenefitOverridesCompanion o) =>
      into(benefitOverrides).insertOnConflictUpdate(o);

  // ---- Merchant memory ----

  Future<m.SpendCategory?> categoryFor(String merchant) async {
    final r = await (select(merchantRules)
          ..where((t) => t.merchant.equals(merchant.toUpperCase())))
        .getSingleOrNull();
    return r == null ? null : m.SpendCategory.fromCode(r.category);
  }

  Future<void> remember(String merchant, m.SpendCategory category) async {
    final key = merchant.toUpperCase().trim();
    if (key.isEmpty) return;
    final existing = await (select(merchantRules)
          ..where((t) => t.merchant.equals(key)))
        .getSingleOrNull();
    await into(merchantRules).insertOnConflictUpdate(MerchantRulesCompanion(
      merchant: Value(key),
      category: Value(category.code),
      hits: Value((existing?.hits ?? 0) + 1),
    ));
  }

  // ---- Network log ----

  Future<void> logRequest(DateTime at, String method, String url, int bytes,
          int status) =>
      into(networkLogs).insert(NetworkLogsCompanion.insert(
          at: at, method: method, url: url, bytes: bytes, status: status));

  Stream<List<NetworkLog>> watchNetworkLog() => (select(networkLogs)
        ..where((t) => t.at.isBiggerThanValue(
            DateTime.now().subtract(const Duration(days: 90))))
        ..orderBy([(t) => OrderingTerm.desc(t.at)]))
      .watch();

  // ---- Key/values ----

  Future<String?> getValue(String key) async =>
      (await (select(keyValues)..where((t) => t.key.equals(key)))
              .getSingleOrNull())
          ?.value;

  Stream<String?> watchValue(String key) =>
      (select(keyValues)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((r) => r?.value);

  Future<void> setValue(String key, String value) => into(keyValues)
      .insertOnConflictUpdate(KeyValuesCompanion.insert(key: key, value: value));
}
