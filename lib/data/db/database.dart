import 'package:drift/drift.dart';

import '../../domain/models.dart' as m;
import '../../domain/recurring.dart' as m2;

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

  /// Bank's card-blocking number for the lost-card button (added in v3).
  TextColumn get helpline => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Monthly budget per spend category (added in v3).
class Budgets extends Table {
  TextColumn get category => text()();
  IntColumn get amountPaise => integer()();

  @override
  Set<Column> get primaryKey => {category};
}

/// Recurring expenses: rent, subscriptions, EMIs (added in v4).
@DataClassName('RecurringRow')
class Recurrings extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get category => text()();
  TextColumn get paymentKind => text()();
  TextColumn get userCardId => text().nullable()();
  IntColumn get dayOfMonth => integer()();
  BoolColumn get autoAdd => boolean().withDefault(const Constant(true))();
  IntColumn get lastAddedMonth => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Reward points per card (added in v5).
@DataClassName('PointsRow')
class PointsBalances extends Table {
  TextColumn get cardId => text()();
  IntColumn get points => integer()();
  IntColumn get paisePerPoint => integer()();
  DateTimeColumn get expiresOn => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cardId};
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

/// Benefits the user added themselves (custom cards, or anything missing
/// from the catalog). They take precedence over catalog benefits.
class CustomBenefits extends Table {
  TextColumn get id => text()();
  TextColumn get userCardId => text()();
  TextColumn get category => text()();
  TextColumn get kind => text().withDefault(const Constant('REWARD'))();
  TextColumn get title => text()();
  IntColumn get rateBps => integer().nullable()();
  IntColumn get monthlyCapPaise => integer().nullable()();
  TextColumn get channel => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
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
  CustomBenefits,
  Budgets,
  Recurrings,
  PointsBalances,
  MerchantRules,
  NetworkLogs,
  KeyValues,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(customBenefits);
          if (from < 3) {
            await m.addColumn(userCards, userCards.helpline);
            await m.createTable(budgets);
          }
          if (from < 4) await m.createTable(recurrings);
          if (from < 5) await m.createTable(pointsBalances);
        },
      );

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
        await (delete(customBenefits)..where((t) => t.userCardId.equals(id)))
            .go();
        await (delete(pointsBalances)..where((t) => t.cardId.equals(id))).go();
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

  // ---- Helpline & budgets ----

  Stream<String?> watchHelpline(String cardId) =>
      (select(userCards)..where((t) => t.id.equals(cardId)))
          .watchSingleOrNull()
          .map((r) => r?.helpline);

  Future<void> setHelpline(String cardId, String? number) =>
      (update(userCards)..where((t) => t.id.equals(cardId)))
          .write(UserCardsCompanion(helpline: Value(number)));

  Stream<Map<m.SpendCategory, int>> watchBudgets() =>
      select(budgets).watch().map((rows) => {
            for (final r in rows)
              m.SpendCategory.fromCode(r.category): r.amountPaise,
          });

  Future<void> setBudget(m.SpendCategory c, int? amountPaise) =>
      amountPaise == null || amountPaise <= 0
          ? (delete(budgets)..where((t) => t.category.equals(c.code))).go()
          : into(budgets).insertOnConflictUpdate(BudgetsCompanion.insert(
              category: c.code, amountPaise: amountPaise));

  // ---- Reward points ----

  Stream<List<m.PointsBalance>> watchPoints() =>
      select(pointsBalances).watch().map((rows) => [
            for (final r in rows)
              m.PointsBalance(
                cardId: r.cardId,
                points: r.points,
                paisePerPoint: r.paisePerPoint,
                expiresOn: r.expiresOn,
                updatedAt: r.updatedAt,
              ),
          ]);

  Future<void> savePoints(m.PointsBalance p) =>
      into(pointsBalances).insertOnConflictUpdate(PointsBalancesCompanion.insert(
        cardId: p.cardId,
        points: p.points,
        paisePerPoint: p.paisePerPoint,
        expiresOn: Value(p.expiresOn),
        updatedAt: DateTime.now(),
      ));

  Future<void> deletePoints(String cardId) =>
      (delete(pointsBalances)..where((t) => t.cardId.equals(cardId))).go();

  // ---- Recurring ----

  Stream<List<m2.RecurringRule>> watchRecurring() =>
      select(recurrings).watch().map((rows) => rows.map(_toRule).toList());

  Future<List<m2.RecurringRule>> allRecurring() async =>
      (await select(recurrings).get()).map(_toRule).toList();

  Future<void> saveRecurring(m2.RecurringRule r) =>
      into(recurrings).insertOnConflictUpdate(RecurringsCompanion.insert(
        id: r.id,
        title: r.title,
        amountPaise: r.amountPaise,
        category: r.category.code,
        paymentKind: r.paymentKind.name,
        userCardId: Value(r.userCardId),
        dayOfMonth: r.dayOfMonth,
        autoAdd: Value(r.autoAdd),
        lastAddedMonth: Value(r.lastAddedMonth),
      ));

  Future<void> deleteRecurring(String id) =>
      (delete(recurrings)..where((t) => t.id.equals(id))).go();

  /// Records an occurrence as an expense and marks the month as done.
  Future<void> addOccurrence(m2.RecurringRule r, DateTime date) =>
      transaction(() async {
        await addSpend(
          m.Spend(
            id: '${r.id}-${m2.monthKey(date)}',
            amountPaise: r.amountPaise,
            category: r.category,
            paymentKind: r.paymentKind,
            userCardId: r.userCardId,
            viaUpi: r.paymentKind == m.PaymentKind.bankUpi,
            payee: r.category == m.SpendCategory.rent
                ? m.PayeeType.person
                : m.PayeeType.merchant,
            note: r.title,
            spentOn: date,
          ),
          merchant: r.title.toUpperCase(),
          source: 'RECURRING',
        );
        await (update(recurrings)..where((t) => t.id.equals(r.id))).write(
            RecurringsCompanion(lastAddedMonth: Value(m2.monthKey(date))));
      });

  /// Marks a month as handled without adding an expense ("Skip").
  Future<void> skipOccurrence(m2.RecurringRule r, DateTime date) =>
      (update(recurrings)..where((t) => t.id.equals(r.id))).write(
          RecurringsCompanion(lastAddedMonth: Value(m2.monthKey(date))));

  m2.RecurringRule _toRule(RecurringRow r) => m2.RecurringRule(
        id: r.id,
        title: r.title,
        amountPaise: r.amountPaise,
        category: m.SpendCategory.fromCode(r.category),
        paymentKind: m.PaymentKind.values.byName(r.paymentKind),
        userCardId: r.userCardId,
        dayOfMonth: r.dayOfMonth,
        autoAdd: r.autoAdd,
        lastAddedMonth: r.lastAddedMonth,
      );

  // ---- Custom benefits ----

  Stream<List<CustomBenefit>> watchCustomBenefits() =>
      select(customBenefits).watch();

  Future<void> saveCustomBenefit(CustomBenefitsCompanion b) =>
      into(customBenefits).insertOnConflictUpdate(b);

  Future<void> deleteCustomBenefit(String id) =>
      (delete(customBenefits)..where((t) => t.id.equals(id))).go();

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
