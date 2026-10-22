// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserCardsTable extends UserCards
    with TableInfo<$UserCardsTable, UserCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _networkMeta = const VerificationMeta(
    'network',
  );
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
    'network',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _last4Meta = const VerificationMeta('last4');
  @override
  late final GeneratedColumn<String> last4 = GeneratedColumn<String>(
    'last4',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 4,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditLimitPaiseMeta = const VerificationMeta(
    'creditLimitPaise',
  );
  @override
  late final GeneratedColumn<int> creditLimitPaise = GeneratedColumn<int>(
    'credit_limit_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statementDayMeta = const VerificationMeta(
    'statementDay',
  );
  @override
  late final GeneratedColumn<int> statementDay = GeneratedColumn<int>(
    'statement_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _annualFeePaiseMeta = const VerificationMeta(
    'annualFeePaise',
  );
  @override
  late final GeneratedColumn<int> annualFeePaise = GeneratedColumn<int>(
    'annual_fee_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _waiverSpendPaiseMeta = const VerificationMeta(
    'waiverSpendPaise',
  );
  @override
  late final GeneratedColumn<int> waiverSpendPaise = GeneratedColumn<int>(
    'waiver_spend_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anniversaryMonthMeta = const VerificationMeta(
    'anniversaryMonth',
  );
  @override
  late final GeneratedColumn<int> anniversaryMonth = GeneratedColumn<int>(
    'anniversary_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _faceColorMeta = const VerificationMeta(
    'faceColor',
  );
  @override
  late final GeneratedColumn<int> faceColor = GeneratedColumn<int>(
    'face_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _faceFinishMeta = const VerificationMeta(
    'faceFinish',
  );
  @override
  late final GeneratedColumn<String> faceFinish = GeneratedColumn<String>(
    'face_finish',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('matte'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _helplineMeta = const VerificationMeta(
    'helpline',
  );
  @override
  late final GeneratedColumn<String> helpline = GeneratedColumn<String>(
    'helpline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    bankName,
    name,
    nickname,
    network,
    last4,
    creditLimitPaise,
    statementDay,
    dueDay,
    annualFeePaise,
    waiverSpendPaise,
    anniversaryMonth,
    faceColor,
    faceFinish,
    sortOrder,
    helpline,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('network')) {
      context.handle(
        _networkMeta,
        network.isAcceptableOrUnknown(data['network']!, _networkMeta),
      );
    } else if (isInserting) {
      context.missing(_networkMeta);
    }
    if (data.containsKey('last4')) {
      context.handle(
        _last4Meta,
        last4.isAcceptableOrUnknown(data['last4']!, _last4Meta),
      );
    }
    if (data.containsKey('credit_limit_paise')) {
      context.handle(
        _creditLimitPaiseMeta,
        creditLimitPaise.isAcceptableOrUnknown(
          data['credit_limit_paise']!,
          _creditLimitPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditLimitPaiseMeta);
    }
    if (data.containsKey('statement_day')) {
      context.handle(
        _statementDayMeta,
        statementDay.isAcceptableOrUnknown(
          data['statement_day']!,
          _statementDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statementDayMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDayMeta);
    }
    if (data.containsKey('annual_fee_paise')) {
      context.handle(
        _annualFeePaiseMeta,
        annualFeePaise.isAcceptableOrUnknown(
          data['annual_fee_paise']!,
          _annualFeePaiseMeta,
        ),
      );
    }
    if (data.containsKey('waiver_spend_paise')) {
      context.handle(
        _waiverSpendPaiseMeta,
        waiverSpendPaise.isAcceptableOrUnknown(
          data['waiver_spend_paise']!,
          _waiverSpendPaiseMeta,
        ),
      );
    }
    if (data.containsKey('anniversary_month')) {
      context.handle(
        _anniversaryMonthMeta,
        anniversaryMonth.isAcceptableOrUnknown(
          data['anniversary_month']!,
          _anniversaryMonthMeta,
        ),
      );
    }
    if (data.containsKey('face_color')) {
      context.handle(
        _faceColorMeta,
        faceColor.isAcceptableOrUnknown(data['face_color']!, _faceColorMeta),
      );
    } else if (isInserting) {
      context.missing(_faceColorMeta);
    }
    if (data.containsKey('face_finish')) {
      context.handle(
        _faceFinishMeta,
        faceFinish.isAcceptableOrUnknown(data['face_finish']!, _faceFinishMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('helpline')) {
      context.handle(
        _helplineMeta,
        helpline.isAcceptableOrUnknown(data['helpline']!, _helplineMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      network: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network'],
      )!,
      last4: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last4'],
      ),
      creditLimitPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_limit_paise'],
      )!,
      statementDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}statement_day'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      )!,
      annualFeePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}annual_fee_paise'],
      )!,
      waiverSpendPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}waiver_spend_paise'],
      ),
      anniversaryMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anniversary_month'],
      ),
      faceColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}face_color'],
      )!,
      faceFinish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}face_finish'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      helpline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}helpline'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserCardsTable createAlias(String alias) {
    return $UserCardsTable(attachedDatabase, alias);
  }
}

class UserCardRow extends DataClass implements Insertable<UserCardRow> {
  final String id;
  final String productId;
  final String bankName;
  final String name;
  final String? nickname;
  final String network;

  /// Last 4 digits only. There is deliberately no column for the full card
  /// number or CVV (rule R3).
  final String? last4;
  final int creditLimitPaise;
  final int statementDay;
  final int dueDay;
  final int annualFeePaise;
  final int? waiverSpendPaise;
  final int? anniversaryMonth;
  final int faceColor;
  final String faceFinish;
  final int sortOrder;

  /// Bank's card-blocking number for the lost-card button (added in v3).
  final String? helpline;
  final DateTime createdAt;
  const UserCardRow({
    required this.id,
    required this.productId,
    required this.bankName,
    required this.name,
    this.nickname,
    required this.network,
    this.last4,
    required this.creditLimitPaise,
    required this.statementDay,
    required this.dueDay,
    required this.annualFeePaise,
    this.waiverSpendPaise,
    this.anniversaryMonth,
    required this.faceColor,
    required this.faceFinish,
    required this.sortOrder,
    this.helpline,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['bank_name'] = Variable<String>(bankName);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    map['network'] = Variable<String>(network);
    if (!nullToAbsent || last4 != null) {
      map['last4'] = Variable<String>(last4);
    }
    map['credit_limit_paise'] = Variable<int>(creditLimitPaise);
    map['statement_day'] = Variable<int>(statementDay);
    map['due_day'] = Variable<int>(dueDay);
    map['annual_fee_paise'] = Variable<int>(annualFeePaise);
    if (!nullToAbsent || waiverSpendPaise != null) {
      map['waiver_spend_paise'] = Variable<int>(waiverSpendPaise);
    }
    if (!nullToAbsent || anniversaryMonth != null) {
      map['anniversary_month'] = Variable<int>(anniversaryMonth);
    }
    map['face_color'] = Variable<int>(faceColor);
    map['face_finish'] = Variable<String>(faceFinish);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || helpline != null) {
      map['helpline'] = Variable<String>(helpline);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserCardsCompanion toCompanion(bool nullToAbsent) {
    return UserCardsCompanion(
      id: Value(id),
      productId: Value(productId),
      bankName: Value(bankName),
      name: Value(name),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      network: Value(network),
      last4: last4 == null && nullToAbsent
          ? const Value.absent()
          : Value(last4),
      creditLimitPaise: Value(creditLimitPaise),
      statementDay: Value(statementDay),
      dueDay: Value(dueDay),
      annualFeePaise: Value(annualFeePaise),
      waiverSpendPaise: waiverSpendPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(waiverSpendPaise),
      anniversaryMonth: anniversaryMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(anniversaryMonth),
      faceColor: Value(faceColor),
      faceFinish: Value(faceFinish),
      sortOrder: Value(sortOrder),
      helpline: helpline == null && nullToAbsent
          ? const Value.absent()
          : Value(helpline),
      createdAt: Value(createdAt),
    );
  }

  factory UserCardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCardRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      bankName: serializer.fromJson<String>(json['bankName']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      network: serializer.fromJson<String>(json['network']),
      last4: serializer.fromJson<String?>(json['last4']),
      creditLimitPaise: serializer.fromJson<int>(json['creditLimitPaise']),
      statementDay: serializer.fromJson<int>(json['statementDay']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      annualFeePaise: serializer.fromJson<int>(json['annualFeePaise']),
      waiverSpendPaise: serializer.fromJson<int?>(json['waiverSpendPaise']),
      anniversaryMonth: serializer.fromJson<int?>(json['anniversaryMonth']),
      faceColor: serializer.fromJson<int>(json['faceColor']),
      faceFinish: serializer.fromJson<String>(json['faceFinish']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      helpline: serializer.fromJson<String?>(json['helpline']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'bankName': serializer.toJson<String>(bankName),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'network': serializer.toJson<String>(network),
      'last4': serializer.toJson<String?>(last4),
      'creditLimitPaise': serializer.toJson<int>(creditLimitPaise),
      'statementDay': serializer.toJson<int>(statementDay),
      'dueDay': serializer.toJson<int>(dueDay),
      'annualFeePaise': serializer.toJson<int>(annualFeePaise),
      'waiverSpendPaise': serializer.toJson<int?>(waiverSpendPaise),
      'anniversaryMonth': serializer.toJson<int?>(anniversaryMonth),
      'faceColor': serializer.toJson<int>(faceColor),
      'faceFinish': serializer.toJson<String>(faceFinish),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'helpline': serializer.toJson<String?>(helpline),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserCardRow copyWith({
    String? id,
    String? productId,
    String? bankName,
    String? name,
    Value<String?> nickname = const Value.absent(),
    String? network,
    Value<String?> last4 = const Value.absent(),
    int? creditLimitPaise,
    int? statementDay,
    int? dueDay,
    int? annualFeePaise,
    Value<int?> waiverSpendPaise = const Value.absent(),
    Value<int?> anniversaryMonth = const Value.absent(),
    int? faceColor,
    String? faceFinish,
    int? sortOrder,
    Value<String?> helpline = const Value.absent(),
    DateTime? createdAt,
  }) => UserCardRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    bankName: bankName ?? this.bankName,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    network: network ?? this.network,
    last4: last4.present ? last4.value : this.last4,
    creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
    statementDay: statementDay ?? this.statementDay,
    dueDay: dueDay ?? this.dueDay,
    annualFeePaise: annualFeePaise ?? this.annualFeePaise,
    waiverSpendPaise: waiverSpendPaise.present
        ? waiverSpendPaise.value
        : this.waiverSpendPaise,
    anniversaryMonth: anniversaryMonth.present
        ? anniversaryMonth.value
        : this.anniversaryMonth,
    faceColor: faceColor ?? this.faceColor,
    faceFinish: faceFinish ?? this.faceFinish,
    sortOrder: sortOrder ?? this.sortOrder,
    helpline: helpline.present ? helpline.value : this.helpline,
    createdAt: createdAt ?? this.createdAt,
  );
  UserCardRow copyWithCompanion(UserCardsCompanion data) {
    return UserCardRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      network: data.network.present ? data.network.value : this.network,
      last4: data.last4.present ? data.last4.value : this.last4,
      creditLimitPaise: data.creditLimitPaise.present
          ? data.creditLimitPaise.value
          : this.creditLimitPaise,
      statementDay: data.statementDay.present
          ? data.statementDay.value
          : this.statementDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      annualFeePaise: data.annualFeePaise.present
          ? data.annualFeePaise.value
          : this.annualFeePaise,
      waiverSpendPaise: data.waiverSpendPaise.present
          ? data.waiverSpendPaise.value
          : this.waiverSpendPaise,
      anniversaryMonth: data.anniversaryMonth.present
          ? data.anniversaryMonth.value
          : this.anniversaryMonth,
      faceColor: data.faceColor.present ? data.faceColor.value : this.faceColor,
      faceFinish: data.faceFinish.present
          ? data.faceFinish.value
          : this.faceFinish,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      helpline: data.helpline.present ? data.helpline.value : this.helpline,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCardRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('bankName: $bankName, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('network: $network, ')
          ..write('last4: $last4, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('statementDay: $statementDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('annualFeePaise: $annualFeePaise, ')
          ..write('waiverSpendPaise: $waiverSpendPaise, ')
          ..write('anniversaryMonth: $anniversaryMonth, ')
          ..write('faceColor: $faceColor, ')
          ..write('faceFinish: $faceFinish, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('helpline: $helpline, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    bankName,
    name,
    nickname,
    network,
    last4,
    creditLimitPaise,
    statementDay,
    dueDay,
    annualFeePaise,
    waiverSpendPaise,
    anniversaryMonth,
    faceColor,
    faceFinish,
    sortOrder,
    helpline,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCardRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.bankName == this.bankName &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.network == this.network &&
          other.last4 == this.last4 &&
          other.creditLimitPaise == this.creditLimitPaise &&
          other.statementDay == this.statementDay &&
          other.dueDay == this.dueDay &&
          other.annualFeePaise == this.annualFeePaise &&
          other.waiverSpendPaise == this.waiverSpendPaise &&
          other.anniversaryMonth == this.anniversaryMonth &&
          other.faceColor == this.faceColor &&
          other.faceFinish == this.faceFinish &&
          other.sortOrder == this.sortOrder &&
          other.helpline == this.helpline &&
          other.createdAt == this.createdAt);
}

class UserCardsCompanion extends UpdateCompanion<UserCardRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> bankName;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<String> network;
  final Value<String?> last4;
  final Value<int> creditLimitPaise;
  final Value<int> statementDay;
  final Value<int> dueDay;
  final Value<int> annualFeePaise;
  final Value<int?> waiverSpendPaise;
  final Value<int?> anniversaryMonth;
  final Value<int> faceColor;
  final Value<String> faceFinish;
  final Value<int> sortOrder;
  final Value<String?> helpline;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserCardsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.bankName = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.network = const Value.absent(),
    this.last4 = const Value.absent(),
    this.creditLimitPaise = const Value.absent(),
    this.statementDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.annualFeePaise = const Value.absent(),
    this.waiverSpendPaise = const Value.absent(),
    this.anniversaryMonth = const Value.absent(),
    this.faceColor = const Value.absent(),
    this.faceFinish = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.helpline = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCardsCompanion.insert({
    required String id,
    required String productId,
    required String bankName,
    required String name,
    this.nickname = const Value.absent(),
    required String network,
    this.last4 = const Value.absent(),
    required int creditLimitPaise,
    required int statementDay,
    required int dueDay,
    this.annualFeePaise = const Value.absent(),
    this.waiverSpendPaise = const Value.absent(),
    this.anniversaryMonth = const Value.absent(),
    required int faceColor,
    this.faceFinish = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.helpline = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       bankName = Value(bankName),
       name = Value(name),
       network = Value(network),
       creditLimitPaise = Value(creditLimitPaise),
       statementDay = Value(statementDay),
       dueDay = Value(dueDay),
       faceColor = Value(faceColor),
       createdAt = Value(createdAt);
  static Insertable<UserCardRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? bankName,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? network,
    Expression<String>? last4,
    Expression<int>? creditLimitPaise,
    Expression<int>? statementDay,
    Expression<int>? dueDay,
    Expression<int>? annualFeePaise,
    Expression<int>? waiverSpendPaise,
    Expression<int>? anniversaryMonth,
    Expression<int>? faceColor,
    Expression<String>? faceFinish,
    Expression<int>? sortOrder,
    Expression<String>? helpline,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (bankName != null) 'bank_name': bankName,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (network != null) 'network': network,
      if (last4 != null) 'last4': last4,
      if (creditLimitPaise != null) 'credit_limit_paise': creditLimitPaise,
      if (statementDay != null) 'statement_day': statementDay,
      if (dueDay != null) 'due_day': dueDay,
      if (annualFeePaise != null) 'annual_fee_paise': annualFeePaise,
      if (waiverSpendPaise != null) 'waiver_spend_paise': waiverSpendPaise,
      if (anniversaryMonth != null) 'anniversary_month': anniversaryMonth,
      if (faceColor != null) 'face_color': faceColor,
      if (faceFinish != null) 'face_finish': faceFinish,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (helpline != null) 'helpline': helpline,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? bankName,
    Value<String>? name,
    Value<String?>? nickname,
    Value<String>? network,
    Value<String?>? last4,
    Value<int>? creditLimitPaise,
    Value<int>? statementDay,
    Value<int>? dueDay,
    Value<int>? annualFeePaise,
    Value<int?>? waiverSpendPaise,
    Value<int?>? anniversaryMonth,
    Value<int>? faceColor,
    Value<String>? faceFinish,
    Value<int>? sortOrder,
    Value<String?>? helpline,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserCardsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      bankName: bankName ?? this.bankName,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      network: network ?? this.network,
      last4: last4 ?? this.last4,
      creditLimitPaise: creditLimitPaise ?? this.creditLimitPaise,
      statementDay: statementDay ?? this.statementDay,
      dueDay: dueDay ?? this.dueDay,
      annualFeePaise: annualFeePaise ?? this.annualFeePaise,
      waiverSpendPaise: waiverSpendPaise ?? this.waiverSpendPaise,
      anniversaryMonth: anniversaryMonth ?? this.anniversaryMonth,
      faceColor: faceColor ?? this.faceColor,
      faceFinish: faceFinish ?? this.faceFinish,
      sortOrder: sortOrder ?? this.sortOrder,
      helpline: helpline ?? this.helpline,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (last4.present) {
      map['last4'] = Variable<String>(last4.value);
    }
    if (creditLimitPaise.present) {
      map['credit_limit_paise'] = Variable<int>(creditLimitPaise.value);
    }
    if (statementDay.present) {
      map['statement_day'] = Variable<int>(statementDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (annualFeePaise.present) {
      map['annual_fee_paise'] = Variable<int>(annualFeePaise.value);
    }
    if (waiverSpendPaise.present) {
      map['waiver_spend_paise'] = Variable<int>(waiverSpendPaise.value);
    }
    if (anniversaryMonth.present) {
      map['anniversary_month'] = Variable<int>(anniversaryMonth.value);
    }
    if (faceColor.present) {
      map['face_color'] = Variable<int>(faceColor.value);
    }
    if (faceFinish.present) {
      map['face_finish'] = Variable<String>(faceFinish.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (helpline.present) {
      map['helpline'] = Variable<String>(helpline.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCardsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('bankName: $bankName, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('network: $network, ')
          ..write('last4: $last4, ')
          ..write('creditLimitPaise: $creditLimitPaise, ')
          ..write('statementDay: $statementDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('annualFeePaise: $annualFeePaise, ')
          ..write('waiverSpendPaise: $waiverSpendPaise, ')
          ..write('anniversaryMonth: $anniversaryMonth, ')
          ..write('faceColor: $faceColor, ')
          ..write('faceFinish: $faceFinish, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('helpline: $helpline, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SpendsTable extends Spends with TableInfo<$SpendsTable, SpendRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentKindMeta = const VerificationMeta(
    'paymentKind',
  );
  @override
  late final GeneratedColumn<String> paymentKind = GeneratedColumn<String>(
    'payment_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userCardIdMeta = const VerificationMeta(
    'userCardId',
  );
  @override
  late final GeneratedColumn<String> userCardId = GeneratedColumn<String>(
    'user_card_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viaUpiMeta = const VerificationMeta('viaUpi');
  @override
  late final GeneratedColumn<bool> viaUpi = GeneratedColumn<bool>(
    'via_upi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("via_upi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _internationalMeta = const VerificationMeta(
    'international',
  );
  @override
  late final GeneratedColumn<bool> international = GeneratedColumn<bool>(
    'international',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("international" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _payeeMeta = const VerificationMeta('payee');
  @override
  late final GeneratedColumn<String> payee = GeneratedColumn<String>(
    'payee',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('merchant'),
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('MANUAL'),
  );
  static const VerificationMeta _spentOnMeta = const VerificationMeta(
    'spentOn',
  );
  @override
  late final GeneratedColumn<DateTime> spentOn = GeneratedColumn<DateTime>(
    'spent_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountPaise,
    category,
    paymentKind,
    userCardId,
    viaUpi,
    international,
    payee,
    merchant,
    note,
    source,
    spentOn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'spends';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpendRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('payment_kind')) {
      context.handle(
        _paymentKindMeta,
        paymentKind.isAcceptableOrUnknown(
          data['payment_kind']!,
          _paymentKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentKindMeta);
    }
    if (data.containsKey('user_card_id')) {
      context.handle(
        _userCardIdMeta,
        userCardId.isAcceptableOrUnknown(
          data['user_card_id']!,
          _userCardIdMeta,
        ),
      );
    }
    if (data.containsKey('via_upi')) {
      context.handle(
        _viaUpiMeta,
        viaUpi.isAcceptableOrUnknown(data['via_upi']!, _viaUpiMeta),
      );
    }
    if (data.containsKey('international')) {
      context.handle(
        _internationalMeta,
        international.isAcceptableOrUnknown(
          data['international']!,
          _internationalMeta,
        ),
      );
    }
    if (data.containsKey('payee')) {
      context.handle(
        _payeeMeta,
        payee.isAcceptableOrUnknown(data['payee']!, _payeeMeta),
      );
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('spent_on')) {
      context.handle(
        _spentOnMeta,
        spentOn.isAcceptableOrUnknown(data['spent_on']!, _spentOnMeta),
      );
    } else if (isInserting) {
      context.missing(_spentOnMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpendRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpendRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      paymentKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_kind'],
      )!,
      userCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_card_id'],
      ),
      viaUpi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}via_upi'],
      )!,
      international: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}international'],
      )!,
      payee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payee'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      spentOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}spent_on'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SpendsTable createAlias(String alias) {
    return $SpendsTable(attachedDatabase, alias);
  }
}

class SpendRow extends DataClass implements Insertable<SpendRow> {
  final String id;
  final int amountPaise;
  final String category;
  final String paymentKind;
  final String? userCardId;
  final bool viaUpi;
  final bool international;
  final String payee;
  final String? merchant;
  final String? note;

  /// MANUAL | SHARE | CLIPBOARD (docs/08 §5).
  final String source;
  final DateTime spentOn;
  final DateTime createdAt;
  const SpendRow({
    required this.id,
    required this.amountPaise,
    required this.category,
    required this.paymentKind,
    this.userCardId,
    required this.viaUpi,
    required this.international,
    required this.payee,
    this.merchant,
    this.note,
    required this.source,
    required this.spentOn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['category'] = Variable<String>(category);
    map['payment_kind'] = Variable<String>(paymentKind);
    if (!nullToAbsent || userCardId != null) {
      map['user_card_id'] = Variable<String>(userCardId);
    }
    map['via_upi'] = Variable<bool>(viaUpi);
    map['international'] = Variable<bool>(international);
    map['payee'] = Variable<String>(payee);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['source'] = Variable<String>(source);
    map['spent_on'] = Variable<DateTime>(spentOn);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SpendsCompanion toCompanion(bool nullToAbsent) {
    return SpendsCompanion(
      id: Value(id),
      amountPaise: Value(amountPaise),
      category: Value(category),
      paymentKind: Value(paymentKind),
      userCardId: userCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(userCardId),
      viaUpi: Value(viaUpi),
      international: Value(international),
      payee: Value(payee),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      source: Value(source),
      spentOn: Value(spentOn),
      createdAt: Value(createdAt),
    );
  }

  factory SpendRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpendRow(
      id: serializer.fromJson<String>(json['id']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      category: serializer.fromJson<String>(json['category']),
      paymentKind: serializer.fromJson<String>(json['paymentKind']),
      userCardId: serializer.fromJson<String?>(json['userCardId']),
      viaUpi: serializer.fromJson<bool>(json['viaUpi']),
      international: serializer.fromJson<bool>(json['international']),
      payee: serializer.fromJson<String>(json['payee']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      note: serializer.fromJson<String?>(json['note']),
      source: serializer.fromJson<String>(json['source']),
      spentOn: serializer.fromJson<DateTime>(json['spentOn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'category': serializer.toJson<String>(category),
      'paymentKind': serializer.toJson<String>(paymentKind),
      'userCardId': serializer.toJson<String?>(userCardId),
      'viaUpi': serializer.toJson<bool>(viaUpi),
      'international': serializer.toJson<bool>(international),
      'payee': serializer.toJson<String>(payee),
      'merchant': serializer.toJson<String?>(merchant),
      'note': serializer.toJson<String?>(note),
      'source': serializer.toJson<String>(source),
      'spentOn': serializer.toJson<DateTime>(spentOn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SpendRow copyWith({
    String? id,
    int? amountPaise,
    String? category,
    String? paymentKind,
    Value<String?> userCardId = const Value.absent(),
    bool? viaUpi,
    bool? international,
    String? payee,
    Value<String?> merchant = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? source,
    DateTime? spentOn,
    DateTime? createdAt,
  }) => SpendRow(
    id: id ?? this.id,
    amountPaise: amountPaise ?? this.amountPaise,
    category: category ?? this.category,
    paymentKind: paymentKind ?? this.paymentKind,
    userCardId: userCardId.present ? userCardId.value : this.userCardId,
    viaUpi: viaUpi ?? this.viaUpi,
    international: international ?? this.international,
    payee: payee ?? this.payee,
    merchant: merchant.present ? merchant.value : this.merchant,
    note: note.present ? note.value : this.note,
    source: source ?? this.source,
    spentOn: spentOn ?? this.spentOn,
    createdAt: createdAt ?? this.createdAt,
  );
  SpendRow copyWithCompanion(SpendsCompanion data) {
    return SpendRow(
      id: data.id.present ? data.id.value : this.id,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      category: data.category.present ? data.category.value : this.category,
      paymentKind: data.paymentKind.present
          ? data.paymentKind.value
          : this.paymentKind,
      userCardId: data.userCardId.present
          ? data.userCardId.value
          : this.userCardId,
      viaUpi: data.viaUpi.present ? data.viaUpi.value : this.viaUpi,
      international: data.international.present
          ? data.international.value
          : this.international,
      payee: data.payee.present ? data.payee.value : this.payee,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      note: data.note.present ? data.note.value : this.note,
      source: data.source.present ? data.source.value : this.source,
      spentOn: data.spentOn.present ? data.spentOn.value : this.spentOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpendRow(')
          ..write('id: $id, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('category: $category, ')
          ..write('paymentKind: $paymentKind, ')
          ..write('userCardId: $userCardId, ')
          ..write('viaUpi: $viaUpi, ')
          ..write('international: $international, ')
          ..write('payee: $payee, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('spentOn: $spentOn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountPaise,
    category,
    paymentKind,
    userCardId,
    viaUpi,
    international,
    payee,
    merchant,
    note,
    source,
    spentOn,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpendRow &&
          other.id == this.id &&
          other.amountPaise == this.amountPaise &&
          other.category == this.category &&
          other.paymentKind == this.paymentKind &&
          other.userCardId == this.userCardId &&
          other.viaUpi == this.viaUpi &&
          other.international == this.international &&
          other.payee == this.payee &&
          other.merchant == this.merchant &&
          other.note == this.note &&
          other.source == this.source &&
          other.spentOn == this.spentOn &&
          other.createdAt == this.createdAt);
}

class SpendsCompanion extends UpdateCompanion<SpendRow> {
  final Value<String> id;
  final Value<int> amountPaise;
  final Value<String> category;
  final Value<String> paymentKind;
  final Value<String?> userCardId;
  final Value<bool> viaUpi;
  final Value<bool> international;
  final Value<String> payee;
  final Value<String?> merchant;
  final Value<String?> note;
  final Value<String> source;
  final Value<DateTime> spentOn;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SpendsCompanion({
    this.id = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.category = const Value.absent(),
    this.paymentKind = const Value.absent(),
    this.userCardId = const Value.absent(),
    this.viaUpi = const Value.absent(),
    this.international = const Value.absent(),
    this.payee = const Value.absent(),
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    this.spentOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpendsCompanion.insert({
    required String id,
    required int amountPaise,
    required String category,
    required String paymentKind,
    this.userCardId = const Value.absent(),
    this.viaUpi = const Value.absent(),
    this.international = const Value.absent(),
    this.payee = const Value.absent(),
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime spentOn,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountPaise = Value(amountPaise),
       category = Value(category),
       paymentKind = Value(paymentKind),
       spentOn = Value(spentOn),
       createdAt = Value(createdAt);
  static Insertable<SpendRow> custom({
    Expression<String>? id,
    Expression<int>? amountPaise,
    Expression<String>? category,
    Expression<String>? paymentKind,
    Expression<String>? userCardId,
    Expression<bool>? viaUpi,
    Expression<bool>? international,
    Expression<String>? payee,
    Expression<String>? merchant,
    Expression<String>? note,
    Expression<String>? source,
    Expression<DateTime>? spentOn,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (category != null) 'category': category,
      if (paymentKind != null) 'payment_kind': paymentKind,
      if (userCardId != null) 'user_card_id': userCardId,
      if (viaUpi != null) 'via_upi': viaUpi,
      if (international != null) 'international': international,
      if (payee != null) 'payee': payee,
      if (merchant != null) 'merchant': merchant,
      if (note != null) 'note': note,
      if (source != null) 'source': source,
      if (spentOn != null) 'spent_on': spentOn,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpendsCompanion copyWith({
    Value<String>? id,
    Value<int>? amountPaise,
    Value<String>? category,
    Value<String>? paymentKind,
    Value<String?>? userCardId,
    Value<bool>? viaUpi,
    Value<bool>? international,
    Value<String>? payee,
    Value<String?>? merchant,
    Value<String?>? note,
    Value<String>? source,
    Value<DateTime>? spentOn,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SpendsCompanion(
      id: id ?? this.id,
      amountPaise: amountPaise ?? this.amountPaise,
      category: category ?? this.category,
      paymentKind: paymentKind ?? this.paymentKind,
      userCardId: userCardId ?? this.userCardId,
      viaUpi: viaUpi ?? this.viaUpi,
      international: international ?? this.international,
      payee: payee ?? this.payee,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      source: source ?? this.source,
      spentOn: spentOn ?? this.spentOn,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (paymentKind.present) {
      map['payment_kind'] = Variable<String>(paymentKind.value);
    }
    if (userCardId.present) {
      map['user_card_id'] = Variable<String>(userCardId.value);
    }
    if (viaUpi.present) {
      map['via_upi'] = Variable<bool>(viaUpi.value);
    }
    if (international.present) {
      map['international'] = Variable<bool>(international.value);
    }
    if (payee.present) {
      map['payee'] = Variable<String>(payee.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (spentOn.present) {
      map['spent_on'] = Variable<DateTime>(spentOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpendsCompanion(')
          ..write('id: $id, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('category: $category, ')
          ..write('paymentKind: $paymentKind, ')
          ..write('userCardId: $userCardId, ')
          ..write('viaUpi: $viaUpi, ')
          ..write('international: $international, ')
          ..write('payee: $payee, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('source: $source, ')
          ..write('spentOn: $spentOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BenefitOverridesTable extends BenefitOverrides
    with TableInfo<$BenefitOverridesTable, BenefitOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BenefitOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userCardIdMeta = const VerificationMeta(
    'userCardId',
  );
  @override
  late final GeneratedColumn<String> userCardId = GeneratedColumn<String>(
    'user_card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _benefitIdMeta = const VerificationMeta(
    'benefitId',
  );
  @override
  late final GeneratedColumn<String> benefitId = GeneratedColumn<String>(
    'benefit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateBpsMeta = const VerificationMeta(
    'rateBps',
  );
  @override
  late final GeneratedColumn<int> rateBps = GeneratedColumn<int>(
    'rate_bps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyCapPaiseMeta = const VerificationMeta(
    'monthlyCapPaise',
  );
  @override
  late final GeneratedColumn<int> monthlyCapPaise = GeneratedColumn<int>(
    'monthly_cap_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedOnMeta = const VerificationMeta(
    'verifiedOn',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedOn = GeneratedColumn<DateTime>(
    'verified_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userCardId,
    benefitId,
    rateBps,
    monthlyCapPaise,
    verifiedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'benefit_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<BenefitOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_card_id')) {
      context.handle(
        _userCardIdMeta,
        userCardId.isAcceptableOrUnknown(
          data['user_card_id']!,
          _userCardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userCardIdMeta);
    }
    if (data.containsKey('benefit_id')) {
      context.handle(
        _benefitIdMeta,
        benefitId.isAcceptableOrUnknown(data['benefit_id']!, _benefitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_benefitIdMeta);
    }
    if (data.containsKey('rate_bps')) {
      context.handle(
        _rateBpsMeta,
        rateBps.isAcceptableOrUnknown(data['rate_bps']!, _rateBpsMeta),
      );
    }
    if (data.containsKey('monthly_cap_paise')) {
      context.handle(
        _monthlyCapPaiseMeta,
        monthlyCapPaise.isAcceptableOrUnknown(
          data['monthly_cap_paise']!,
          _monthlyCapPaiseMeta,
        ),
      );
    }
    if (data.containsKey('verified_on')) {
      context.handle(
        _verifiedOnMeta,
        verifiedOn.isAcceptableOrUnknown(data['verified_on']!, _verifiedOnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userCardId, benefitId};
  @override
  BenefitOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BenefitOverride(
      userCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_card_id'],
      )!,
      benefitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}benefit_id'],
      )!,
      rateBps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_bps'],
      ),
      monthlyCapPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_cap_paise'],
      ),
      verifiedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_on'],
      ),
    );
  }

  @override
  $BenefitOverridesTable createAlias(String alias) {
    return $BenefitOverridesTable(attachedDatabase, alias);
  }
}

class BenefitOverride extends DataClass implements Insertable<BenefitOverride> {
  final String userCardId;
  final String benefitId;
  final int? rateBps;
  final int? monthlyCapPaise;
  final DateTime? verifiedOn;
  const BenefitOverride({
    required this.userCardId,
    required this.benefitId,
    this.rateBps,
    this.monthlyCapPaise,
    this.verifiedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_card_id'] = Variable<String>(userCardId);
    map['benefit_id'] = Variable<String>(benefitId);
    if (!nullToAbsent || rateBps != null) {
      map['rate_bps'] = Variable<int>(rateBps);
    }
    if (!nullToAbsent || monthlyCapPaise != null) {
      map['monthly_cap_paise'] = Variable<int>(monthlyCapPaise);
    }
    if (!nullToAbsent || verifiedOn != null) {
      map['verified_on'] = Variable<DateTime>(verifiedOn);
    }
    return map;
  }

  BenefitOverridesCompanion toCompanion(bool nullToAbsent) {
    return BenefitOverridesCompanion(
      userCardId: Value(userCardId),
      benefitId: Value(benefitId),
      rateBps: rateBps == null && nullToAbsent
          ? const Value.absent()
          : Value(rateBps),
      monthlyCapPaise: monthlyCapPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyCapPaise),
      verifiedOn: verifiedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedOn),
    );
  }

  factory BenefitOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BenefitOverride(
      userCardId: serializer.fromJson<String>(json['userCardId']),
      benefitId: serializer.fromJson<String>(json['benefitId']),
      rateBps: serializer.fromJson<int?>(json['rateBps']),
      monthlyCapPaise: serializer.fromJson<int?>(json['monthlyCapPaise']),
      verifiedOn: serializer.fromJson<DateTime?>(json['verifiedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userCardId': serializer.toJson<String>(userCardId),
      'benefitId': serializer.toJson<String>(benefitId),
      'rateBps': serializer.toJson<int?>(rateBps),
      'monthlyCapPaise': serializer.toJson<int?>(monthlyCapPaise),
      'verifiedOn': serializer.toJson<DateTime?>(verifiedOn),
    };
  }

  BenefitOverride copyWith({
    String? userCardId,
    String? benefitId,
    Value<int?> rateBps = const Value.absent(),
    Value<int?> monthlyCapPaise = const Value.absent(),
    Value<DateTime?> verifiedOn = const Value.absent(),
  }) => BenefitOverride(
    userCardId: userCardId ?? this.userCardId,
    benefitId: benefitId ?? this.benefitId,
    rateBps: rateBps.present ? rateBps.value : this.rateBps,
    monthlyCapPaise: monthlyCapPaise.present
        ? monthlyCapPaise.value
        : this.monthlyCapPaise,
    verifiedOn: verifiedOn.present ? verifiedOn.value : this.verifiedOn,
  );
  BenefitOverride copyWithCompanion(BenefitOverridesCompanion data) {
    return BenefitOverride(
      userCardId: data.userCardId.present
          ? data.userCardId.value
          : this.userCardId,
      benefitId: data.benefitId.present ? data.benefitId.value : this.benefitId,
      rateBps: data.rateBps.present ? data.rateBps.value : this.rateBps,
      monthlyCapPaise: data.monthlyCapPaise.present
          ? data.monthlyCapPaise.value
          : this.monthlyCapPaise,
      verifiedOn: data.verifiedOn.present
          ? data.verifiedOn.value
          : this.verifiedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BenefitOverride(')
          ..write('userCardId: $userCardId, ')
          ..write('benefitId: $benefitId, ')
          ..write('rateBps: $rateBps, ')
          ..write('monthlyCapPaise: $monthlyCapPaise, ')
          ..write('verifiedOn: $verifiedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userCardId, benefitId, rateBps, monthlyCapPaise, verifiedOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BenefitOverride &&
          other.userCardId == this.userCardId &&
          other.benefitId == this.benefitId &&
          other.rateBps == this.rateBps &&
          other.monthlyCapPaise == this.monthlyCapPaise &&
          other.verifiedOn == this.verifiedOn);
}

class BenefitOverridesCompanion extends UpdateCompanion<BenefitOverride> {
  final Value<String> userCardId;
  final Value<String> benefitId;
  final Value<int?> rateBps;
  final Value<int?> monthlyCapPaise;
  final Value<DateTime?> verifiedOn;
  final Value<int> rowid;
  const BenefitOverridesCompanion({
    this.userCardId = const Value.absent(),
    this.benefitId = const Value.absent(),
    this.rateBps = const Value.absent(),
    this.monthlyCapPaise = const Value.absent(),
    this.verifiedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BenefitOverridesCompanion.insert({
    required String userCardId,
    required String benefitId,
    this.rateBps = const Value.absent(),
    this.monthlyCapPaise = const Value.absent(),
    this.verifiedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userCardId = Value(userCardId),
       benefitId = Value(benefitId);
  static Insertable<BenefitOverride> custom({
    Expression<String>? userCardId,
    Expression<String>? benefitId,
    Expression<int>? rateBps,
    Expression<int>? monthlyCapPaise,
    Expression<DateTime>? verifiedOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userCardId != null) 'user_card_id': userCardId,
      if (benefitId != null) 'benefit_id': benefitId,
      if (rateBps != null) 'rate_bps': rateBps,
      if (monthlyCapPaise != null) 'monthly_cap_paise': monthlyCapPaise,
      if (verifiedOn != null) 'verified_on': verifiedOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BenefitOverridesCompanion copyWith({
    Value<String>? userCardId,
    Value<String>? benefitId,
    Value<int?>? rateBps,
    Value<int?>? monthlyCapPaise,
    Value<DateTime?>? verifiedOn,
    Value<int>? rowid,
  }) {
    return BenefitOverridesCompanion(
      userCardId: userCardId ?? this.userCardId,
      benefitId: benefitId ?? this.benefitId,
      rateBps: rateBps ?? this.rateBps,
      monthlyCapPaise: monthlyCapPaise ?? this.monthlyCapPaise,
      verifiedOn: verifiedOn ?? this.verifiedOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userCardId.present) {
      map['user_card_id'] = Variable<String>(userCardId.value);
    }
    if (benefitId.present) {
      map['benefit_id'] = Variable<String>(benefitId.value);
    }
    if (rateBps.present) {
      map['rate_bps'] = Variable<int>(rateBps.value);
    }
    if (monthlyCapPaise.present) {
      map['monthly_cap_paise'] = Variable<int>(monthlyCapPaise.value);
    }
    if (verifiedOn.present) {
      map['verified_on'] = Variable<DateTime>(verifiedOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BenefitOverridesCompanion(')
          ..write('userCardId: $userCardId, ')
          ..write('benefitId: $benefitId, ')
          ..write('rateBps: $rateBps, ')
          ..write('monthlyCapPaise: $monthlyCapPaise, ')
          ..write('verifiedOn: $verifiedOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomBenefitsTable extends CustomBenefits
    with TableInfo<$CustomBenefitsTable, CustomBenefit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomBenefitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userCardIdMeta = const VerificationMeta(
    'userCardId',
  );
  @override
  late final GeneratedColumn<String> userCardId = GeneratedColumn<String>(
    'user_card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('REWARD'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateBpsMeta = const VerificationMeta(
    'rateBps',
  );
  @override
  late final GeneratedColumn<int> rateBps = GeneratedColumn<int>(
    'rate_bps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyCapPaiseMeta = const VerificationMeta(
    'monthlyCapPaise',
  );
  @override
  late final GeneratedColumn<int> monthlyCapPaise = GeneratedColumn<int>(
    'monthly_cap_paise',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userCardId,
    category,
    kind,
    title,
    rateBps,
    monthlyCapPaise,
    channel,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_benefits';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomBenefit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_card_id')) {
      context.handle(
        _userCardIdMeta,
        userCardId.isAcceptableOrUnknown(
          data['user_card_id']!,
          _userCardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userCardIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('rate_bps')) {
      context.handle(
        _rateBpsMeta,
        rateBps.isAcceptableOrUnknown(data['rate_bps']!, _rateBpsMeta),
      );
    }
    if (data.containsKey('monthly_cap_paise')) {
      context.handle(
        _monthlyCapPaiseMeta,
        monthlyCapPaise.isAcceptableOrUnknown(
          data['monthly_cap_paise']!,
          _monthlyCapPaiseMeta,
        ),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomBenefit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomBenefit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userCardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_card_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      rateBps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_bps'],
      ),
      monthlyCapPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_cap_paise'],
      ),
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomBenefitsTable createAlias(String alias) {
    return $CustomBenefitsTable(attachedDatabase, alias);
  }
}

class CustomBenefit extends DataClass implements Insertable<CustomBenefit> {
  final String id;
  final String userCardId;
  final String category;
  final String kind;
  final String title;
  final int? rateBps;
  final int? monthlyCapPaise;
  final String? channel;
  final DateTime createdAt;
  const CustomBenefit({
    required this.id,
    required this.userCardId,
    required this.category,
    required this.kind,
    required this.title,
    this.rateBps,
    this.monthlyCapPaise,
    this.channel,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_card_id'] = Variable<String>(userCardId);
    map['category'] = Variable<String>(category);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || rateBps != null) {
      map['rate_bps'] = Variable<int>(rateBps);
    }
    if (!nullToAbsent || monthlyCapPaise != null) {
      map['monthly_cap_paise'] = Variable<int>(monthlyCapPaise);
    }
    if (!nullToAbsent || channel != null) {
      map['channel'] = Variable<String>(channel);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomBenefitsCompanion toCompanion(bool nullToAbsent) {
    return CustomBenefitsCompanion(
      id: Value(id),
      userCardId: Value(userCardId),
      category: Value(category),
      kind: Value(kind),
      title: Value(title),
      rateBps: rateBps == null && nullToAbsent
          ? const Value.absent()
          : Value(rateBps),
      monthlyCapPaise: monthlyCapPaise == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyCapPaise),
      channel: channel == null && nullToAbsent
          ? const Value.absent()
          : Value(channel),
      createdAt: Value(createdAt),
    );
  }

  factory CustomBenefit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomBenefit(
      id: serializer.fromJson<String>(json['id']),
      userCardId: serializer.fromJson<String>(json['userCardId']),
      category: serializer.fromJson<String>(json['category']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      rateBps: serializer.fromJson<int?>(json['rateBps']),
      monthlyCapPaise: serializer.fromJson<int?>(json['monthlyCapPaise']),
      channel: serializer.fromJson<String?>(json['channel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userCardId': serializer.toJson<String>(userCardId),
      'category': serializer.toJson<String>(category),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'rateBps': serializer.toJson<int?>(rateBps),
      'monthlyCapPaise': serializer.toJson<int?>(monthlyCapPaise),
      'channel': serializer.toJson<String?>(channel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomBenefit copyWith({
    String? id,
    String? userCardId,
    String? category,
    String? kind,
    String? title,
    Value<int?> rateBps = const Value.absent(),
    Value<int?> monthlyCapPaise = const Value.absent(),
    Value<String?> channel = const Value.absent(),
    DateTime? createdAt,
  }) => CustomBenefit(
    id: id ?? this.id,
    userCardId: userCardId ?? this.userCardId,
    category: category ?? this.category,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    rateBps: rateBps.present ? rateBps.value : this.rateBps,
    monthlyCapPaise: monthlyCapPaise.present
        ? monthlyCapPaise.value
        : this.monthlyCapPaise,
    channel: channel.present ? channel.value : this.channel,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomBenefit copyWithCompanion(CustomBenefitsCompanion data) {
    return CustomBenefit(
      id: data.id.present ? data.id.value : this.id,
      userCardId: data.userCardId.present
          ? data.userCardId.value
          : this.userCardId,
      category: data.category.present ? data.category.value : this.category,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      rateBps: data.rateBps.present ? data.rateBps.value : this.rateBps,
      monthlyCapPaise: data.monthlyCapPaise.present
          ? data.monthlyCapPaise.value
          : this.monthlyCapPaise,
      channel: data.channel.present ? data.channel.value : this.channel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomBenefit(')
          ..write('id: $id, ')
          ..write('userCardId: $userCardId, ')
          ..write('category: $category, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('rateBps: $rateBps, ')
          ..write('monthlyCapPaise: $monthlyCapPaise, ')
          ..write('channel: $channel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userCardId,
    category,
    kind,
    title,
    rateBps,
    monthlyCapPaise,
    channel,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomBenefit &&
          other.id == this.id &&
          other.userCardId == this.userCardId &&
          other.category == this.category &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.rateBps == this.rateBps &&
          other.monthlyCapPaise == this.monthlyCapPaise &&
          other.channel == this.channel &&
          other.createdAt == this.createdAt);
}

class CustomBenefitsCompanion extends UpdateCompanion<CustomBenefit> {
  final Value<String> id;
  final Value<String> userCardId;
  final Value<String> category;
  final Value<String> kind;
  final Value<String> title;
  final Value<int?> rateBps;
  final Value<int?> monthlyCapPaise;
  final Value<String?> channel;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomBenefitsCompanion({
    this.id = const Value.absent(),
    this.userCardId = const Value.absent(),
    this.category = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.rateBps = const Value.absent(),
    this.monthlyCapPaise = const Value.absent(),
    this.channel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomBenefitsCompanion.insert({
    required String id,
    required String userCardId,
    required String category,
    this.kind = const Value.absent(),
    required String title,
    this.rateBps = const Value.absent(),
    this.monthlyCapPaise = const Value.absent(),
    this.channel = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userCardId = Value(userCardId),
       category = Value(category),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<CustomBenefit> custom({
    Expression<String>? id,
    Expression<String>? userCardId,
    Expression<String>? category,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<int>? rateBps,
    Expression<int>? monthlyCapPaise,
    Expression<String>? channel,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userCardId != null) 'user_card_id': userCardId,
      if (category != null) 'category': category,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (rateBps != null) 'rate_bps': rateBps,
      if (monthlyCapPaise != null) 'monthly_cap_paise': monthlyCapPaise,
      if (channel != null) 'channel': channel,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomBenefitsCompanion copyWith({
    Value<String>? id,
    Value<String>? userCardId,
    Value<String>? category,
    Value<String>? kind,
    Value<String>? title,
    Value<int?>? rateBps,
    Value<int?>? monthlyCapPaise,
    Value<String?>? channel,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomBenefitsCompanion(
      id: id ?? this.id,
      userCardId: userCardId ?? this.userCardId,
      category: category ?? this.category,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      rateBps: rateBps ?? this.rateBps,
      monthlyCapPaise: monthlyCapPaise ?? this.monthlyCapPaise,
      channel: channel ?? this.channel,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userCardId.present) {
      map['user_card_id'] = Variable<String>(userCardId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rateBps.present) {
      map['rate_bps'] = Variable<int>(rateBps.value);
    }
    if (monthlyCapPaise.present) {
      map['monthly_cap_paise'] = Variable<int>(monthlyCapPaise.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomBenefitsCompanion(')
          ..write('id: $id, ')
          ..write('userCardId: $userCardId, ')
          ..write('category: $category, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('rateBps: $rateBps, ')
          ..write('monthlyCapPaise: $monthlyCapPaise, ')
          ..write('channel: $channel, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [category, amountPaise];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {category};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final String category;
  final int amountPaise;
  const Budget({required this.category, required this.amountPaise});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category'] = Variable<String>(category);
    map['amount_paise'] = Variable<int>(amountPaise);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      category: Value(category),
      amountPaise: Value(amountPaise),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      category: serializer.fromJson<String>(json['category']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'category': serializer.toJson<String>(category),
      'amountPaise': serializer.toJson<int>(amountPaise),
    };
  }

  Budget copyWith({String? category, int? amountPaise}) => Budget(
    category: category ?? this.category,
    amountPaise: amountPaise ?? this.amountPaise,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      category: data.category.present ? data.category.value : this.category,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('category: $category, ')
          ..write('amountPaise: $amountPaise')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(category, amountPaise);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.category == this.category &&
          other.amountPaise == this.amountPaise);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> category;
  final Value<int> amountPaise;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.category = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String category,
    required int amountPaise,
    this.rowid = const Value.absent(),
  }) : category = Value(category),
       amountPaise = Value(amountPaise);
  static Insertable<Budget> custom({
    Expression<String>? category,
    Expression<int>? amountPaise,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (category != null) 'category': category,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? category,
    Value<int>? amountPaise,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      category: category ?? this.category,
      amountPaise: amountPaise ?? this.amountPaise,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('category: $category, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MerchantRulesTable extends MerchantRules
    with TableInfo<$MerchantRulesTable, MerchantRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitsMeta = const VerificationMeta('hits');
  @override
  late final GeneratedColumn<int> hits = GeneratedColumn<int>(
    'hits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [merchant, category, hits];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    } else if (isInserting) {
      context.missing(_merchantMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('hits')) {
      context.handle(
        _hitsMeta,
        hits.isAcceptableOrUnknown(data['hits']!, _hitsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {merchant};
  @override
  MerchantRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantRule(
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      hits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hits'],
      )!,
    );
  }

  @override
  $MerchantRulesTable createAlias(String alias) {
    return $MerchantRulesTable(attachedDatabase, alias);
  }
}

class MerchantRule extends DataClass implements Insertable<MerchantRule> {
  final String merchant;
  final String category;
  final int hits;
  const MerchantRule({
    required this.merchant,
    required this.category,
    required this.hits,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['merchant'] = Variable<String>(merchant);
    map['category'] = Variable<String>(category);
    map['hits'] = Variable<int>(hits);
    return map;
  }

  MerchantRulesCompanion toCompanion(bool nullToAbsent) {
    return MerchantRulesCompanion(
      merchant: Value(merchant),
      category: Value(category),
      hits: Value(hits),
    );
  }

  factory MerchantRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantRule(
      merchant: serializer.fromJson<String>(json['merchant']),
      category: serializer.fromJson<String>(json['category']),
      hits: serializer.fromJson<int>(json['hits']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'merchant': serializer.toJson<String>(merchant),
      'category': serializer.toJson<String>(category),
      'hits': serializer.toJson<int>(hits),
    };
  }

  MerchantRule copyWith({String? merchant, String? category, int? hits}) =>
      MerchantRule(
        merchant: merchant ?? this.merchant,
        category: category ?? this.category,
        hits: hits ?? this.hits,
      );
  MerchantRule copyWithCompanion(MerchantRulesCompanion data) {
    return MerchantRule(
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      category: data.category.present ? data.category.value : this.category,
      hits: data.hits.present ? data.hits.value : this.hits,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantRule(')
          ..write('merchant: $merchant, ')
          ..write('category: $category, ')
          ..write('hits: $hits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(merchant, category, hits);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantRule &&
          other.merchant == this.merchant &&
          other.category == this.category &&
          other.hits == this.hits);
}

class MerchantRulesCompanion extends UpdateCompanion<MerchantRule> {
  final Value<String> merchant;
  final Value<String> category;
  final Value<int> hits;
  final Value<int> rowid;
  const MerchantRulesCompanion({
    this.merchant = const Value.absent(),
    this.category = const Value.absent(),
    this.hits = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MerchantRulesCompanion.insert({
    required String merchant,
    required String category,
    this.hits = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : merchant = Value(merchant),
       category = Value(category);
  static Insertable<MerchantRule> custom({
    Expression<String>? merchant,
    Expression<String>? category,
    Expression<int>? hits,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (merchant != null) 'merchant': merchant,
      if (category != null) 'category': category,
      if (hits != null) 'hits': hits,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MerchantRulesCompanion copyWith({
    Value<String>? merchant,
    Value<String>? category,
    Value<int>? hits,
    Value<int>? rowid,
  }) {
    return MerchantRulesCompanion(
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      hits: hits ?? this.hits,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (hits.present) {
      map['hits'] = Variable<int>(hits.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantRulesCompanion(')
          ..write('merchant: $merchant, ')
          ..write('category: $category, ')
          ..write('hits: $hits, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NetworkLogsTable extends NetworkLogs
    with TableInfo<$NetworkLogsTable, NetworkLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetworkLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, at, method, url, bytes, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'network_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetworkLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetworkLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetworkLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $NetworkLogsTable createAlias(String alias) {
    return $NetworkLogsTable(attachedDatabase, alias);
  }
}

class NetworkLog extends DataClass implements Insertable<NetworkLog> {
  final int id;
  final DateTime at;
  final String method;
  final String url;
  final int bytes;
  final int status;
  const NetworkLog({
    required this.id,
    required this.at,
    required this.method,
    required this.url,
    required this.bytes,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['at'] = Variable<DateTime>(at);
    map['method'] = Variable<String>(method);
    map['url'] = Variable<String>(url);
    map['bytes'] = Variable<int>(bytes);
    map['status'] = Variable<int>(status);
    return map;
  }

  NetworkLogsCompanion toCompanion(bool nullToAbsent) {
    return NetworkLogsCompanion(
      id: Value(id),
      at: Value(at),
      method: Value(method),
      url: Value(url),
      bytes: Value(bytes),
      status: Value(status),
    );
  }

  factory NetworkLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetworkLog(
      id: serializer.fromJson<int>(json['id']),
      at: serializer.fromJson<DateTime>(json['at']),
      method: serializer.fromJson<String>(json['method']),
      url: serializer.fromJson<String>(json['url']),
      bytes: serializer.fromJson<int>(json['bytes']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'at': serializer.toJson<DateTime>(at),
      'method': serializer.toJson<String>(method),
      'url': serializer.toJson<String>(url),
      'bytes': serializer.toJson<int>(bytes),
      'status': serializer.toJson<int>(status),
    };
  }

  NetworkLog copyWith({
    int? id,
    DateTime? at,
    String? method,
    String? url,
    int? bytes,
    int? status,
  }) => NetworkLog(
    id: id ?? this.id,
    at: at ?? this.at,
    method: method ?? this.method,
    url: url ?? this.url,
    bytes: bytes ?? this.bytes,
    status: status ?? this.status,
  );
  NetworkLog copyWithCompanion(NetworkLogsCompanion data) {
    return NetworkLog(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      method: data.method.present ? data.method.value : this.method,
      url: data.url.present ? data.url.value : this.url,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetworkLog(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('bytes: $bytes, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, at, method, url, bytes, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetworkLog &&
          other.id == this.id &&
          other.at == this.at &&
          other.method == this.method &&
          other.url == this.url &&
          other.bytes == this.bytes &&
          other.status == this.status);
}

class NetworkLogsCompanion extends UpdateCompanion<NetworkLog> {
  final Value<int> id;
  final Value<DateTime> at;
  final Value<String> method;
  final Value<String> url;
  final Value<int> bytes;
  final Value<int> status;
  const NetworkLogsCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.method = const Value.absent(),
    this.url = const Value.absent(),
    this.bytes = const Value.absent(),
    this.status = const Value.absent(),
  });
  NetworkLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime at,
    required String method,
    required String url,
    required int bytes,
    required int status,
  }) : at = Value(at),
       method = Value(method),
       url = Value(url),
       bytes = Value(bytes),
       status = Value(status);
  static Insertable<NetworkLog> custom({
    Expression<int>? id,
    Expression<DateTime>? at,
    Expression<String>? method,
    Expression<String>? url,
    Expression<int>? bytes,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (bytes != null) 'bytes': bytes,
      if (status != null) 'status': status,
    });
  }

  NetworkLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? at,
    Value<String>? method,
    Value<String>? url,
    Value<int>? bytes,
    Value<int>? status,
  }) {
    return NetworkLogsCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      method: method ?? this.method,
      url: url ?? this.url,
      bytes: bytes ?? this.bytes,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetworkLogsCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('method: $method, ')
          ..write('url: $url, ')
          ..write('bytes: $bytes, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $KeyValuesTable extends KeyValues
    with TableInfo<$KeyValuesTable, KeyValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValue(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KeyValuesTable createAlias(String alias) {
    return $KeyValuesTable(attachedDatabase, alias);
  }
}

class KeyValue extends DataClass implements Insertable<KeyValue> {
  final String key;
  final String value;
  const KeyValue({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValuesCompanion toCompanion(bool nullToAbsent) {
    return KeyValuesCompanion(key: Value(key), value: Value(value));
  }

  factory KeyValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValue(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KeyValue copyWith({String? key, String? value}) =>
      KeyValue(key: key ?? this.key, value: value ?? this.value);
  KeyValue copyWithCompanion(KeyValuesCompanion data) {
    return KeyValue(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValue(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValue && other.key == this.key && other.value == this.value);
}

class KeyValuesCompanion extends UpdateCompanion<KeyValue> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KeyValue> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KeyValuesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserCardsTable userCards = $UserCardsTable(this);
  late final $SpendsTable spends = $SpendsTable(this);
  late final $BenefitOverridesTable benefitOverrides = $BenefitOverridesTable(
    this,
  );
  late final $CustomBenefitsTable customBenefits = $CustomBenefitsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $MerchantRulesTable merchantRules = $MerchantRulesTable(this);
  late final $NetworkLogsTable networkLogs = $NetworkLogsTable(this);
  late final $KeyValuesTable keyValues = $KeyValuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userCards,
    spends,
    benefitOverrides,
    customBenefits,
    budgets,
    merchantRules,
    networkLogs,
    keyValues,
  ];
}

typedef $$UserCardsTableCreateCompanionBuilder = UserCardsCompanion Function({
  required String id,
  required String productId,
  required String bankName,
  required String name,
  Value<String?> nickname,
  required String network,
  Value<String?> last4,
  required int creditLimitPaise,
  required int statementDay,
  required int dueDay,
  Value<int> annualFeePaise,
  Value<int?> waiverSpendPaise,
  Value<int?> anniversaryMonth,
  required int faceColor,
  Value<String> faceFinish,
  Value<int> sortOrder,
  Value<String?> helpline,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UserCardsTableUpdateCompanionBuilder = UserCardsCompanion Function({
  Value<String> id,
  Value<String> productId,
  Value<String> bankName,
  Value<String> name,
  Value<String?> nickname,
  Value<String> network,
  Value<String?> last4,
  Value<int> creditLimitPaise,
  Value<int> statementDay,
  Value<int> dueDay,
  Value<int> annualFeePaise,
  Value<int?> waiverSpendPaise,
  Value<int?> anniversaryMonth,
  Value<int> faceColor,
  Value<String> faceFinish,
  Value<int> sortOrder,
  Value<String?> helpline,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UserCardsTableFilterComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get last4 => $composableBuilder(
    column: $table.last4,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get annualFeePaise => $composableBuilder(
    column: $table.annualFeePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waiverSpendPaise => $composableBuilder(
    column: $table.waiverSpendPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anniversaryMonth => $composableBuilder(
    column: $table.anniversaryMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get faceColor => $composableBuilder(
    column: $table.faceColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faceFinish => $composableBuilder(
    column: $table.faceFinish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get helpline => $composableBuilder(
    column: $table.helpline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get last4 => $composableBuilder(
    column: $table.last4,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get annualFeePaise => $composableBuilder(
    column: $table.annualFeePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waiverSpendPaise => $composableBuilder(
    column: $table.waiverSpendPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anniversaryMonth => $composableBuilder(
    column: $table.anniversaryMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get faceColor => $composableBuilder(
    column: $table.faceColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faceFinish => $composableBuilder(
    column: $table.faceFinish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get helpline => $composableBuilder(
    column: $table.helpline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<String> get last4 =>
      $composableBuilder(column: $table.last4, builder: (column) => column);

  GeneratedColumn<int> get creditLimitPaise => $composableBuilder(
    column: $table.creditLimitPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<int> get annualFeePaise => $composableBuilder(
    column: $table.annualFeePaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get waiverSpendPaise => $composableBuilder(
    column: $table.waiverSpendPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anniversaryMonth => $composableBuilder(
    column: $table.anniversaryMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get faceColor =>
      $composableBuilder(column: $table.faceColor, builder: (column) => column);

  GeneratedColumn<String> get faceFinish => $composableBuilder(
    column: $table.faceFinish,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get helpline =>
      $composableBuilder(column: $table.helpline, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserCardsTable,
          UserCardRow,
          $$UserCardsTableFilterComposer,
          $$UserCardsTableOrderingComposer,
          $$UserCardsTableAnnotationComposer,
          $$UserCardsTableCreateCompanionBuilder,
          $$UserCardsTableUpdateCompanionBuilder,
          (
            UserCardRow,
            BaseReferences<_$AppDatabase, $UserCardsTable, UserCardRow>,
          ),
          UserCardRow,
          PrefetchHooks Function()
        > {
  $$UserCardsTableTableManager(_$AppDatabase db, $UserCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> bankName = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String> network = const Value.absent(),
                Value<String?> last4 = const Value.absent(),
                Value<int> creditLimitPaise = const Value.absent(),
                Value<int> statementDay = const Value.absent(),
                Value<int> dueDay = const Value.absent(),
                Value<int> annualFeePaise = const Value.absent(),
                Value<int?> waiverSpendPaise = const Value.absent(),
                Value<int?> anniversaryMonth = const Value.absent(),
                Value<int> faceColor = const Value.absent(),
                Value<String> faceFinish = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> helpline = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserCardsCompanion(
                id: id,
                productId: productId,
                bankName: bankName,
                name: name,
                nickname: nickname,
                network: network,
                last4: last4,
                creditLimitPaise: creditLimitPaise,
                statementDay: statementDay,
                dueDay: dueDay,
                annualFeePaise: annualFeePaise,
                waiverSpendPaise: waiverSpendPaise,
                anniversaryMonth: anniversaryMonth,
                faceColor: faceColor,
                faceFinish: faceFinish,
                sortOrder: sortOrder,
                helpline: helpline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String bankName,
                required String name,
                Value<String?> nickname = const Value.absent(),
                required String network,
                Value<String?> last4 = const Value.absent(),
                required int creditLimitPaise,
                required int statementDay,
                required int dueDay,
                Value<int> annualFeePaise = const Value.absent(),
                Value<int?> waiverSpendPaise = const Value.absent(),
                Value<int?> anniversaryMonth = const Value.absent(),
                required int faceColor,
                Value<String> faceFinish = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> helpline = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserCardsCompanion.insert(
                id: id,
                productId: productId,
                bankName: bankName,
                name: name,
                nickname: nickname,
                network: network,
                last4: last4,
                creditLimitPaise: creditLimitPaise,
                statementDay: statementDay,
                dueDay: dueDay,
                annualFeePaise: annualFeePaise,
                waiverSpendPaise: waiverSpendPaise,
                anniversaryMonth: anniversaryMonth,
                faceColor: faceColor,
                faceFinish: faceFinish,
                sortOrder: sortOrder,
                helpline: helpline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserCardsTable, UserCardRow>(table),
                  BaseReferences<_$AppDatabase, $UserCardsTable, UserCardRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserCardsTable,
      UserCardRow,
      $$UserCardsTableFilterComposer,
      $$UserCardsTableOrderingComposer,
      $$UserCardsTableAnnotationComposer,
      $$UserCardsTableCreateCompanionBuilder,
      $$UserCardsTableUpdateCompanionBuilder,
      (
        UserCardRow,
        BaseReferences<_$AppDatabase, $UserCardsTable, UserCardRow>,
      ),
      UserCardRow,
      PrefetchHooks Function()
    >;
typedef $$SpendsTableCreateCompanionBuilder = SpendsCompanion Function({
  required String id,
  required int amountPaise,
  required String category,
  required String paymentKind,
  Value<String?> userCardId,
  Value<bool> viaUpi,
  Value<bool> international,
  Value<String> payee,
  Value<String?> merchant,
  Value<String?> note,
  Value<String> source,
  required DateTime spentOn,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SpendsTableUpdateCompanionBuilder = SpendsCompanion Function({
  Value<String> id,
  Value<int> amountPaise,
  Value<String> category,
  Value<String> paymentKind,
  Value<String?> userCardId,
  Value<bool> viaUpi,
  Value<bool> international,
  Value<String> payee,
  Value<String?> merchant,
  Value<String?> note,
  Value<String> source,
  Value<DateTime> spentOn,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SpendsTableFilterComposer
    extends Composer<_$AppDatabase, $SpendsTable> {
  $$SpendsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentKind => $composableBuilder(
    column: $table.paymentKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get viaUpi => $composableBuilder(
    column: $table.viaUpi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get international => $composableBuilder(
    column: $table.international,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payee => $composableBuilder(
    column: $table.payee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get spentOn => $composableBuilder(
    column: $table.spentOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SpendsTableOrderingComposer
    extends Composer<_$AppDatabase, $SpendsTable> {
  $$SpendsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentKind => $composableBuilder(
    column: $table.paymentKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get viaUpi => $composableBuilder(
    column: $table.viaUpi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get international => $composableBuilder(
    column: $table.international,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payee => $composableBuilder(
    column: $table.payee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get spentOn => $composableBuilder(
    column: $table.spentOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SpendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SpendsTable> {
  $$SpendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get paymentKind => $composableBuilder(
    column: $table.paymentKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get viaUpi =>
      $composableBuilder(column: $table.viaUpi, builder: (column) => column);

  GeneratedColumn<bool> get international => $composableBuilder(
    column: $table.international,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payee =>
      $composableBuilder(column: $table.payee, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get spentOn =>
      $composableBuilder(column: $table.spentOn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SpendsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SpendsTable,
          SpendRow,
          $$SpendsTableFilterComposer,
          $$SpendsTableOrderingComposer,
          $$SpendsTableAnnotationComposer,
          $$SpendsTableCreateCompanionBuilder,
          $$SpendsTableUpdateCompanionBuilder,
          (SpendRow, BaseReferences<_$AppDatabase, $SpendsTable, SpendRow>),
          SpendRow,
          PrefetchHooks Function()
        > {
  $$SpendsTableTableManager(_$AppDatabase db, $SpendsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> paymentKind = const Value.absent(),
                Value<String?> userCardId = const Value.absent(),
                Value<bool> viaUpi = const Value.absent(),
                Value<bool> international = const Value.absent(),
                Value<String> payee = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> spentOn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SpendsCompanion(
                id: id,
                amountPaise: amountPaise,
                category: category,
                paymentKind: paymentKind,
                userCardId: userCardId,
                viaUpi: viaUpi,
                international: international,
                payee: payee,
                merchant: merchant,
                note: note,
                source: source,
                spentOn: spentOn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountPaise,
                required String category,
                required String paymentKind,
                Value<String?> userCardId = const Value.absent(),
                Value<bool> viaUpi = const Value.absent(),
                Value<bool> international = const Value.absent(),
                Value<String> payee = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> source = const Value.absent(),
                required DateTime spentOn,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SpendsCompanion.insert(
                id: id,
                amountPaise: amountPaise,
                category: category,
                paymentKind: paymentKind,
                userCardId: userCardId,
                viaUpi: viaUpi,
                international: international,
                payee: payee,
                merchant: merchant,
                note: note,
                source: source,
                spentOn: spentOn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SpendsTable, SpendRow>(table),
                  BaseReferences<_$AppDatabase, $SpendsTable, SpendRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpendsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SpendsTable,
      SpendRow,
      $$SpendsTableFilterComposer,
      $$SpendsTableOrderingComposer,
      $$SpendsTableAnnotationComposer,
      $$SpendsTableCreateCompanionBuilder,
      $$SpendsTableUpdateCompanionBuilder,
      (SpendRow, BaseReferences<_$AppDatabase, $SpendsTable, SpendRow>),
      SpendRow,
      PrefetchHooks Function()
    >;
typedef $$BenefitOverridesTableCreateCompanionBuilder =
    BenefitOverridesCompanion Function({
      required String userCardId,
      required String benefitId,
      Value<int?> rateBps,
      Value<int?> monthlyCapPaise,
      Value<DateTime?> verifiedOn,
      Value<int> rowid,
    });
typedef $$BenefitOverridesTableUpdateCompanionBuilder =
    BenefitOverridesCompanion Function({
      Value<String> userCardId,
      Value<String> benefitId,
      Value<int?> rateBps,
      Value<int?> monthlyCapPaise,
      Value<DateTime?> verifiedOn,
      Value<int> rowid,
    });

class $$BenefitOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $BenefitOverridesTable> {
  $$BenefitOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get benefitId => $composableBuilder(
    column: $table.benefitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateBps => $composableBuilder(
    column: $table.rateBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyCapPaise => $composableBuilder(
    column: $table.monthlyCapPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedOn => $composableBuilder(
    column: $table.verifiedOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BenefitOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $BenefitOverridesTable> {
  $$BenefitOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get benefitId => $composableBuilder(
    column: $table.benefitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateBps => $composableBuilder(
    column: $table.rateBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyCapPaise => $composableBuilder(
    column: $table.monthlyCapPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedOn => $composableBuilder(
    column: $table.verifiedOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BenefitOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BenefitOverridesTable> {
  $$BenefitOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get benefitId =>
      $composableBuilder(column: $table.benefitId, builder: (column) => column);

  GeneratedColumn<int> get rateBps =>
      $composableBuilder(column: $table.rateBps, builder: (column) => column);

  GeneratedColumn<int> get monthlyCapPaise => $composableBuilder(
    column: $table.monthlyCapPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get verifiedOn => $composableBuilder(
    column: $table.verifiedOn,
    builder: (column) => column,
  );
}

class $$BenefitOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BenefitOverridesTable,
          BenefitOverride,
          $$BenefitOverridesTableFilterComposer,
          $$BenefitOverridesTableOrderingComposer,
          $$BenefitOverridesTableAnnotationComposer,
          $$BenefitOverridesTableCreateCompanionBuilder,
          $$BenefitOverridesTableUpdateCompanionBuilder,
          (
            BenefitOverride,
            BaseReferences<
              _$AppDatabase,
              $BenefitOverridesTable,
              BenefitOverride
            >,
          ),
          BenefitOverride,
          PrefetchHooks Function()
        > {
  $$BenefitOverridesTableTableManager(
    _$AppDatabase db,
    $BenefitOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BenefitOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BenefitOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BenefitOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userCardId = const Value.absent(),
                Value<String> benefitId = const Value.absent(),
                Value<int?> rateBps = const Value.absent(),
                Value<int?> monthlyCapPaise = const Value.absent(),
                Value<DateTime?> verifiedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BenefitOverridesCompanion(
                userCardId: userCardId,
                benefitId: benefitId,
                rateBps: rateBps,
                monthlyCapPaise: monthlyCapPaise,
                verifiedOn: verifiedOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userCardId,
                required String benefitId,
                Value<int?> rateBps = const Value.absent(),
                Value<int?> monthlyCapPaise = const Value.absent(),
                Value<DateTime?> verifiedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BenefitOverridesCompanion.insert(
                userCardId: userCardId,
                benefitId: benefitId,
                rateBps: rateBps,
                monthlyCapPaise: monthlyCapPaise,
                verifiedOn: verifiedOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BenefitOverridesTable, BenefitOverride>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BenefitOverridesTable,
                    BenefitOverride
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BenefitOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BenefitOverridesTable,
      BenefitOverride,
      $$BenefitOverridesTableFilterComposer,
      $$BenefitOverridesTableOrderingComposer,
      $$BenefitOverridesTableAnnotationComposer,
      $$BenefitOverridesTableCreateCompanionBuilder,
      $$BenefitOverridesTableUpdateCompanionBuilder,
      (
        BenefitOverride,
        BaseReferences<_$AppDatabase, $BenefitOverridesTable, BenefitOverride>,
      ),
      BenefitOverride,
      PrefetchHooks Function()
    >;
typedef $$CustomBenefitsTableCreateCompanionBuilder =
    CustomBenefitsCompanion Function({
      required String id,
      required String userCardId,
      required String category,
      Value<String> kind,
      required String title,
      Value<int?> rateBps,
      Value<int?> monthlyCapPaise,
      Value<String?> channel,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CustomBenefitsTableUpdateCompanionBuilder =
    CustomBenefitsCompanion Function({
      Value<String> id,
      Value<String> userCardId,
      Value<String> category,
      Value<String> kind,
      Value<String> title,
      Value<int?> rateBps,
      Value<int?> monthlyCapPaise,
      Value<String?> channel,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CustomBenefitsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomBenefitsTable> {
  $$CustomBenefitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rateBps => $composableBuilder(
    column: $table.rateBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyCapPaise => $composableBuilder(
    column: $table.monthlyCapPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomBenefitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomBenefitsTable> {
  $$CustomBenefitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateBps => $composableBuilder(
    column: $table.rateBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyCapPaise => $composableBuilder(
    column: $table.monthlyCapPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomBenefitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomBenefitsTable> {
  $$CustomBenefitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userCardId => $composableBuilder(
    column: $table.userCardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get rateBps =>
      $composableBuilder(column: $table.rateBps, builder: (column) => column);

  GeneratedColumn<int> get monthlyCapPaise => $composableBuilder(
    column: $table.monthlyCapPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomBenefitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomBenefitsTable,
          CustomBenefit,
          $$CustomBenefitsTableFilterComposer,
          $$CustomBenefitsTableOrderingComposer,
          $$CustomBenefitsTableAnnotationComposer,
          $$CustomBenefitsTableCreateCompanionBuilder,
          $$CustomBenefitsTableUpdateCompanionBuilder,
          (
            CustomBenefit,
            BaseReferences<_$AppDatabase, $CustomBenefitsTable, CustomBenefit>,
          ),
          CustomBenefit,
          PrefetchHooks Function()
        > {
  $$CustomBenefitsTableTableManager(
    _$AppDatabase db,
    $CustomBenefitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomBenefitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomBenefitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomBenefitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userCardId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> rateBps = const Value.absent(),
                Value<int?> monthlyCapPaise = const Value.absent(),
                Value<String?> channel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomBenefitsCompanion(
                id: id,
                userCardId: userCardId,
                category: category,
                kind: kind,
                title: title,
                rateBps: rateBps,
                monthlyCapPaise: monthlyCapPaise,
                channel: channel,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userCardId,
                required String category,
                Value<String> kind = const Value.absent(),
                required String title,
                Value<int?> rateBps = const Value.absent(),
                Value<int?> monthlyCapPaise = const Value.absent(),
                Value<String?> channel = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomBenefitsCompanion.insert(
                id: id,
                userCardId: userCardId,
                category: category,
                kind: kind,
                title: title,
                rateBps: rateBps,
                monthlyCapPaise: monthlyCapPaise,
                channel: channel,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomBenefitsTable, CustomBenefit>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CustomBenefitsTable,
                    CustomBenefit
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomBenefitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomBenefitsTable,
      CustomBenefit,
      $$CustomBenefitsTableFilterComposer,
      $$CustomBenefitsTableOrderingComposer,
      $$CustomBenefitsTableAnnotationComposer,
      $$CustomBenefitsTableCreateCompanionBuilder,
      $$CustomBenefitsTableUpdateCompanionBuilder,
      (
        CustomBenefit,
        BaseReferences<_$AppDatabase, $CustomBenefitsTable, CustomBenefit>,
      ),
      CustomBenefit,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String category,
  required int amountPaise,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> category,
  Value<int> amountPaise,
  Value<int> rowid,
});

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> category = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                category: category,
                amountPaise: amountPaise,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String category,
                required int amountPaise,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                category: category,
                amountPaise: amountPaise,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BudgetsTable, Budget>(table),
                  BaseReferences<_$AppDatabase, $BudgetsTable, Budget>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$MerchantRulesTableCreateCompanionBuilder =
    MerchantRulesCompanion Function({
      required String merchant,
      required String category,
      Value<int> hits,
      Value<int> rowid,
    });
typedef $$MerchantRulesTableUpdateCompanionBuilder =
    MerchantRulesCompanion Function({
      Value<String> merchant,
      Value<String> category,
      Value<int> hits,
      Value<int> rowid,
    });

class $$MerchantRulesTableFilterComposer
    extends Composer<_$AppDatabase, $MerchantRulesTable> {
  $$MerchantRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchantRulesTable> {
  $$MerchantRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hits => $composableBuilder(
    column: $table.hits,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchantRulesTable> {
  $$MerchantRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get hits =>
      $composableBuilder(column: $table.hits, builder: (column) => column);
}

class $$MerchantRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MerchantRulesTable,
          MerchantRule,
          $$MerchantRulesTableFilterComposer,
          $$MerchantRulesTableOrderingComposer,
          $$MerchantRulesTableAnnotationComposer,
          $$MerchantRulesTableCreateCompanionBuilder,
          $$MerchantRulesTableUpdateCompanionBuilder,
          (
            MerchantRule,
            BaseReferences<_$AppDatabase, $MerchantRulesTable, MerchantRule>,
          ),
          MerchantRule,
          PrefetchHooks Function()
        > {
  $$MerchantRulesTableTableManager(_$AppDatabase db, $MerchantRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> merchant = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> hits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantRulesCompanion(
                merchant: merchant,
                category: category,
                hits: hits,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String merchant,
                required String category,
                Value<int> hits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MerchantRulesCompanion.insert(
                merchant: merchant,
                category: category,
                hits: hits,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MerchantRulesTable, MerchantRule>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MerchantRulesTable,
                    MerchantRule
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MerchantRulesTable,
      MerchantRule,
      $$MerchantRulesTableFilterComposer,
      $$MerchantRulesTableOrderingComposer,
      $$MerchantRulesTableAnnotationComposer,
      $$MerchantRulesTableCreateCompanionBuilder,
      $$MerchantRulesTableUpdateCompanionBuilder,
      (
        MerchantRule,
        BaseReferences<_$AppDatabase, $MerchantRulesTable, MerchantRule>,
      ),
      MerchantRule,
      PrefetchHooks Function()
    >;
typedef $$NetworkLogsTableCreateCompanionBuilder =
    NetworkLogsCompanion Function({
      Value<int> id,
      required DateTime at,
      required String method,
      required String url,
      required int bytes,
      required int status,
    });
typedef $$NetworkLogsTableUpdateCompanionBuilder =
    NetworkLogsCompanion Function({
      Value<int> id,
      Value<DateTime> at,
      Value<String> method,
      Value<String> url,
      Value<int> bytes,
      Value<int> status,
    });

class $$NetworkLogsTableFilterComposer
    extends Composer<_$AppDatabase, $NetworkLogsTable> {
  $$NetworkLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NetworkLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $NetworkLogsTable> {
  $$NetworkLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NetworkLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetworkLogsTable> {
  $$NetworkLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$NetworkLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NetworkLogsTable,
          NetworkLog,
          $$NetworkLogsTableFilterComposer,
          $$NetworkLogsTableOrderingComposer,
          $$NetworkLogsTableAnnotationComposer,
          $$NetworkLogsTableCreateCompanionBuilder,
          $$NetworkLogsTableUpdateCompanionBuilder,
          (
            NetworkLog,
            BaseReferences<_$AppDatabase, $NetworkLogsTable, NetworkLog>,
          ),
          NetworkLog,
          PrefetchHooks Function()
        > {
  $$NetworkLogsTableTableManager(_$AppDatabase db, $NetworkLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetworkLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetworkLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetworkLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<int> status = const Value.absent(),
              }) => NetworkLogsCompanion(
                id: id,
                at: at,
                method: method,
                url: url,
                bytes: bytes,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime at,
                required String method,
                required String url,
                required int bytes,
                required int status,
              }) => NetworkLogsCompanion.insert(
                id: id,
                at: at,
                method: method,
                url: url,
                bytes: bytes,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NetworkLogsTable, NetworkLog>(table),
                  BaseReferences<_$AppDatabase, $NetworkLogsTable, NetworkLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NetworkLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NetworkLogsTable,
      NetworkLog,
      $$NetworkLogsTableFilterComposer,
      $$NetworkLogsTableOrderingComposer,
      $$NetworkLogsTableAnnotationComposer,
      $$NetworkLogsTableCreateCompanionBuilder,
      $$NetworkLogsTableUpdateCompanionBuilder,
      (
        NetworkLog,
        BaseReferences<_$AppDatabase, $NetworkLogsTable, NetworkLog>,
      ),
      NetworkLog,
      PrefetchHooks Function()
    >;
typedef $$KeyValuesTableCreateCompanionBuilder = KeyValuesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$KeyValuesTableUpdateCompanionBuilder = KeyValuesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$KeyValuesTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KeyValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KeyValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValuesTable> {
  $$KeyValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KeyValuesTable,
          KeyValue,
          $$KeyValuesTableFilterComposer,
          $$KeyValuesTableOrderingComposer,
          $$KeyValuesTableAnnotationComposer,
          $$KeyValuesTableCreateCompanionBuilder,
          $$KeyValuesTableUpdateCompanionBuilder,
          (KeyValue, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>),
          KeyValue,
          PrefetchHooks Function()
        > {
  $$KeyValuesTableTableManager(_$AppDatabase db, $KeyValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => KeyValuesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => KeyValuesCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KeyValuesTable, KeyValue>(table),
                  BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KeyValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KeyValuesTable,
      KeyValue,
      $$KeyValuesTableFilterComposer,
      $$KeyValuesTableOrderingComposer,
      $$KeyValuesTableAnnotationComposer,
      $$KeyValuesTableCreateCompanionBuilder,
      $$KeyValuesTableUpdateCompanionBuilder,
      (KeyValue, BaseReferences<_$AppDatabase, $KeyValuesTable, KeyValue>),
      KeyValue,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserCardsTableTableManager get userCards =>
      $$UserCardsTableTableManager(_db, _db.userCards);
  $$SpendsTableTableManager get spends =>
      $$SpendsTableTableManager(_db, _db.spends);
  $$BenefitOverridesTableTableManager get benefitOverrides =>
      $$BenefitOverridesTableTableManager(_db, _db.benefitOverrides);
  $$CustomBenefitsTableTableManager get customBenefits =>
      $$CustomBenefitsTableTableManager(_db, _db.customBenefits);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$MerchantRulesTableTableManager get merchantRules =>
      $$MerchantRulesTableTableManager(_db, _db.merchantRules);
  $$NetworkLogsTableTableManager get networkLogs =>
      $$NetworkLogsTableTableManager(_db, _db.networkLogs);
  $$KeyValuesTableTableManager get keyValues =>
      $$KeyValuesTableTableManager(_db, _db.keyValues);
}
