// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stakesMeta = const VerificationMeta('stakes');
  @override
  late final GeneratedColumn<String> stakes = GeneratedColumn<String>(
    'stakes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameTypeMeta = const VerificationMeta(
    'gameType',
  );
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
    'game_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _buyInMeta = const VerificationMeta('buyIn');
  @override
  late final GeneratedColumn<double> buyIn = GeneratedColumn<double>(
    'buy_in',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashOutMeta = const VerificationMeta(
    'cashOut',
  );
  @override
  late final GeneratedColumn<double> cashOut = GeneratedColumn<double>(
    'cash_out',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profitLossMeta = const VerificationMeta(
    'profitLoss',
  );
  @override
  late final GeneratedColumn<double> profitLoss = GeneratedColumn<double>(
    'profit_loss',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rakePaidMeta = const VerificationMeta(
    'rakePaid',
  );
  @override
  late final GeneratedColumn<double> rakePaid = GeneratedColumn<double>(
    'rake_paid',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishPositionMeta = const VerificationMeta(
    'finishPosition',
  );
  @override
  late final GeneratedColumn<int> finishPosition = GeneratedColumn<int>(
    'finish_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalEntrantsMeta = const VerificationMeta(
    'totalEntrants',
  );
  @override
  late final GeneratedColumn<int> totalEntrants = GeneratedColumn<int>(
    'total_entrants',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prizeWonMeta = const VerificationMeta(
    'prizeWon',
  );
  @override
  late final GeneratedColumn<double> prizeWon = GeneratedColumn<double>(
    'prize_won',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tableQualityMeta = const VerificationMeta(
    'tableQuality',
  );
  @override
  late final GeneratedColumn<int> tableQuality = GeneratedColumn<int>(
    'table_quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CAD'),
  );
  static const VerificationMeta _handsPerHourMeta = const VerificationMeta(
    'handsPerHour',
  );
  @override
  late final GeneratedColumn<int> handsPerHour = GeneratedColumn<int>(
    'hands_per_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    stakes,
    gameType,
    buyIn,
    cashOut,
    profitLoss,
    startTime,
    endTime,
    durationMinutes,
    location,
    notes,
    createdAt,
    rakePaid,
    finishPosition,
    totalEntrants,
    prizeWon,
    tableQuality,
    currency,
    handsPerHour,
    country,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('stakes')) {
      context.handle(
        _stakesMeta,
        stakes.isAcceptableOrUnknown(data['stakes']!, _stakesMeta),
      );
    } else if (isInserting) {
      context.missing(_stakesMeta);
    }
    if (data.containsKey('game_type')) {
      context.handle(
        _gameTypeMeta,
        gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta),
      );
    }
    if (data.containsKey('buy_in')) {
      context.handle(
        _buyInMeta,
        buyIn.isAcceptableOrUnknown(data['buy_in']!, _buyInMeta),
      );
    } else if (isInserting) {
      context.missing(_buyInMeta);
    }
    if (data.containsKey('cash_out')) {
      context.handle(
        _cashOutMeta,
        cashOut.isAcceptableOrUnknown(data['cash_out']!, _cashOutMeta),
      );
    } else if (isInserting) {
      context.missing(_cashOutMeta);
    }
    if (data.containsKey('profit_loss')) {
      context.handle(
        _profitLossMeta,
        profitLoss.isAcceptableOrUnknown(data['profit_loss']!, _profitLossMeta),
      );
    } else if (isInserting) {
      context.missing(_profitLossMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('rake_paid')) {
      context.handle(
        _rakePaidMeta,
        rakePaid.isAcceptableOrUnknown(data['rake_paid']!, _rakePaidMeta),
      );
    }
    if (data.containsKey('finish_position')) {
      context.handle(
        _finishPositionMeta,
        finishPosition.isAcceptableOrUnknown(
          data['finish_position']!,
          _finishPositionMeta,
        ),
      );
    }
    if (data.containsKey('total_entrants')) {
      context.handle(
        _totalEntrantsMeta,
        totalEntrants.isAcceptableOrUnknown(
          data['total_entrants']!,
          _totalEntrantsMeta,
        ),
      );
    }
    if (data.containsKey('prize_won')) {
      context.handle(
        _prizeWonMeta,
        prizeWon.isAcceptableOrUnknown(data['prize_won']!, _prizeWonMeta),
      );
    }
    if (data.containsKey('table_quality')) {
      context.handle(
        _tableQualityMeta,
        tableQuality.isAcceptableOrUnknown(
          data['table_quality']!,
          _tableQualityMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('hands_per_hour')) {
      context.handle(
        _handsPerHourMeta,
        handsPerHour.isAcceptableOrUnknown(
          data['hands_per_hour']!,
          _handsPerHourMeta,
        ),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      stakes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stakes'],
      )!,
      gameType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_type'],
      )!,
      buyIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}buy_in'],
      )!,
      cashOut: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cash_out'],
      )!,
      profitLoss: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}profit_loss'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      rakePaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rake_paid'],
      ),
      finishPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finish_position'],
      ),
      totalEntrants: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_entrants'],
      ),
      prizeWon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prize_won'],
      ),
      tableQuality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}table_quality'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      handsPerHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hands_per_hour'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final String date;
  final String stakes;
  final String gameType;
  final double buyIn;
  final double cashOut;
  final double profitLoss;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String? location;
  final String? notes;
  final String createdAt;
  final double? rakePaid;
  final int? finishPosition;
  final int? totalEntrants;
  final double? prizeWon;
  final int? tableQuality;
  final String currency;
  final int? handsPerHour;
  final String? country;
  const Session({
    required this.id,
    required this.date,
    required this.stakes,
    required this.gameType,
    required this.buyIn,
    required this.cashOut,
    required this.profitLoss,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.location,
    this.notes,
    required this.createdAt,
    this.rakePaid,
    this.finishPosition,
    this.totalEntrants,
    this.prizeWon,
    this.tableQuality,
    required this.currency,
    this.handsPerHour,
    this.country,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['stakes'] = Variable<String>(stakes);
    map['game_type'] = Variable<String>(gameType);
    map['buy_in'] = Variable<double>(buyIn);
    map['cash_out'] = Variable<double>(cashOut);
    map['profit_loss'] = Variable<double>(profitLoss);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || rakePaid != null) {
      map['rake_paid'] = Variable<double>(rakePaid);
    }
    if (!nullToAbsent || finishPosition != null) {
      map['finish_position'] = Variable<int>(finishPosition);
    }
    if (!nullToAbsent || totalEntrants != null) {
      map['total_entrants'] = Variable<int>(totalEntrants);
    }
    if (!nullToAbsent || prizeWon != null) {
      map['prize_won'] = Variable<double>(prizeWon);
    }
    if (!nullToAbsent || tableQuality != null) {
      map['table_quality'] = Variable<int>(tableQuality);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || handsPerHour != null) {
      map['hands_per_hour'] = Variable<int>(handsPerHour);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      date: Value(date),
      stakes: Value(stakes),
      gameType: Value(gameType),
      buyIn: Value(buyIn),
      cashOut: Value(cashOut),
      profitLoss: Value(profitLoss),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationMinutes: Value(durationMinutes),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      rakePaid: rakePaid == null && nullToAbsent
          ? const Value.absent()
          : Value(rakePaid),
      finishPosition: finishPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(finishPosition),
      totalEntrants: totalEntrants == null && nullToAbsent
          ? const Value.absent()
          : Value(totalEntrants),
      prizeWon: prizeWon == null && nullToAbsent
          ? const Value.absent()
          : Value(prizeWon),
      tableQuality: tableQuality == null && nullToAbsent
          ? const Value.absent()
          : Value(tableQuality),
      currency: Value(currency),
      handsPerHour: handsPerHour == null && nullToAbsent
          ? const Value.absent()
          : Value(handsPerHour),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      stakes: serializer.fromJson<String>(json['stakes']),
      gameType: serializer.fromJson<String>(json['gameType']),
      buyIn: serializer.fromJson<double>(json['buyIn']),
      cashOut: serializer.fromJson<double>(json['cashOut']),
      profitLoss: serializer.fromJson<double>(json['profitLoss']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      rakePaid: serializer.fromJson<double?>(json['rakePaid']),
      finishPosition: serializer.fromJson<int?>(json['finishPosition']),
      totalEntrants: serializer.fromJson<int?>(json['totalEntrants']),
      prizeWon: serializer.fromJson<double?>(json['prizeWon']),
      tableQuality: serializer.fromJson<int?>(json['tableQuality']),
      currency: serializer.fromJson<String>(json['currency']),
      handsPerHour: serializer.fromJson<int?>(json['handsPerHour']),
      country: serializer.fromJson<String?>(json['country']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'stakes': serializer.toJson<String>(stakes),
      'gameType': serializer.toJson<String>(gameType),
      'buyIn': serializer.toJson<double>(buyIn),
      'cashOut': serializer.toJson<double>(cashOut),
      'profitLoss': serializer.toJson<double>(profitLoss),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'rakePaid': serializer.toJson<double?>(rakePaid),
      'finishPosition': serializer.toJson<int?>(finishPosition),
      'totalEntrants': serializer.toJson<int?>(totalEntrants),
      'prizeWon': serializer.toJson<double?>(prizeWon),
      'tableQuality': serializer.toJson<int?>(tableQuality),
      'currency': serializer.toJson<String>(currency),
      'handsPerHour': serializer.toJson<int?>(handsPerHour),
      'country': serializer.toJson<String?>(country),
    };
  }

  Session copyWith({
    int? id,
    String? date,
    String? stakes,
    String? gameType,
    double? buyIn,
    double? cashOut,
    double? profitLoss,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    Value<String?> location = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdAt,
    Value<double?> rakePaid = const Value.absent(),
    Value<int?> finishPosition = const Value.absent(),
    Value<int?> totalEntrants = const Value.absent(),
    Value<double?> prizeWon = const Value.absent(),
    Value<int?> tableQuality = const Value.absent(),
    String? currency,
    Value<int?> handsPerHour = const Value.absent(),
    Value<String?> country = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    date: date ?? this.date,
    stakes: stakes ?? this.stakes,
    gameType: gameType ?? this.gameType,
    buyIn: buyIn ?? this.buyIn,
    cashOut: cashOut ?? this.cashOut,
    profitLoss: profitLoss ?? this.profitLoss,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    location: location.present ? location.value : this.location,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    rakePaid: rakePaid.present ? rakePaid.value : this.rakePaid,
    finishPosition: finishPosition.present
        ? finishPosition.value
        : this.finishPosition,
    totalEntrants: totalEntrants.present
        ? totalEntrants.value
        : this.totalEntrants,
    prizeWon: prizeWon.present ? prizeWon.value : this.prizeWon,
    tableQuality: tableQuality.present ? tableQuality.value : this.tableQuality,
    currency: currency ?? this.currency,
    handsPerHour: handsPerHour.present ? handsPerHour.value : this.handsPerHour,
    country: country.present ? country.value : this.country,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      stakes: data.stakes.present ? data.stakes.value : this.stakes,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      buyIn: data.buyIn.present ? data.buyIn.value : this.buyIn,
      cashOut: data.cashOut.present ? data.cashOut.value : this.cashOut,
      profitLoss: data.profitLoss.present
          ? data.profitLoss.value
          : this.profitLoss,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      rakePaid: data.rakePaid.present ? data.rakePaid.value : this.rakePaid,
      finishPosition: data.finishPosition.present
          ? data.finishPosition.value
          : this.finishPosition,
      totalEntrants: data.totalEntrants.present
          ? data.totalEntrants.value
          : this.totalEntrants,
      prizeWon: data.prizeWon.present ? data.prizeWon.value : this.prizeWon,
      tableQuality: data.tableQuality.present
          ? data.tableQuality.value
          : this.tableQuality,
      currency: data.currency.present ? data.currency.value : this.currency,
      handsPerHour: data.handsPerHour.present
          ? data.handsPerHour.value
          : this.handsPerHour,
      country: data.country.present ? data.country.value : this.country,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('stakes: $stakes, ')
          ..write('gameType: $gameType, ')
          ..write('buyIn: $buyIn, ')
          ..write('cashOut: $cashOut, ')
          ..write('profitLoss: $profitLoss, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rakePaid: $rakePaid, ')
          ..write('finishPosition: $finishPosition, ')
          ..write('totalEntrants: $totalEntrants, ')
          ..write('prizeWon: $prizeWon, ')
          ..write('tableQuality: $tableQuality, ')
          ..write('currency: $currency, ')
          ..write('handsPerHour: $handsPerHour, ')
          ..write('country: $country')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    date,
    stakes,
    gameType,
    buyIn,
    cashOut,
    profitLoss,
    startTime,
    endTime,
    durationMinutes,
    location,
    notes,
    createdAt,
    rakePaid,
    finishPosition,
    totalEntrants,
    prizeWon,
    tableQuality,
    currency,
    handsPerHour,
    country,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.date == this.date &&
          other.stakes == this.stakes &&
          other.gameType == this.gameType &&
          other.buyIn == this.buyIn &&
          other.cashOut == this.cashOut &&
          other.profitLoss == this.profitLoss &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationMinutes == this.durationMinutes &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.rakePaid == this.rakePaid &&
          other.finishPosition == this.finishPosition &&
          other.totalEntrants == this.totalEntrants &&
          other.prizeWon == this.prizeWon &&
          other.tableQuality == this.tableQuality &&
          other.currency == this.currency &&
          other.handsPerHour == this.handsPerHour &&
          other.country == this.country);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> stakes;
  final Value<String> gameType;
  final Value<double> buyIn;
  final Value<double> cashOut;
  final Value<double> profitLoss;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<int> durationMinutes;
  final Value<String?> location;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<double?> rakePaid;
  final Value<int?> finishPosition;
  final Value<int?> totalEntrants;
  final Value<double?> prizeWon;
  final Value<int?> tableQuality;
  final Value<String> currency;
  final Value<int?> handsPerHour;
  final Value<String?> country;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.stakes = const Value.absent(),
    this.gameType = const Value.absent(),
    this.buyIn = const Value.absent(),
    this.cashOut = const Value.absent(),
    this.profitLoss = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rakePaid = const Value.absent(),
    this.finishPosition = const Value.absent(),
    this.totalEntrants = const Value.absent(),
    this.prizeWon = const Value.absent(),
    this.tableQuality = const Value.absent(),
    this.currency = const Value.absent(),
    this.handsPerHour = const Value.absent(),
    this.country = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String stakes,
    this.gameType = const Value.absent(),
    required double buyIn,
    required double cashOut,
    required double profitLoss,
    required String startTime,
    required String endTime,
    required int durationMinutes,
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAt,
    this.rakePaid = const Value.absent(),
    this.finishPosition = const Value.absent(),
    this.totalEntrants = const Value.absent(),
    this.prizeWon = const Value.absent(),
    this.tableQuality = const Value.absent(),
    this.currency = const Value.absent(),
    this.handsPerHour = const Value.absent(),
    this.country = const Value.absent(),
  }) : date = Value(date),
       stakes = Value(stakes),
       buyIn = Value(buyIn),
       cashOut = Value(cashOut),
       profitLoss = Value(profitLoss),
       startTime = Value(startTime),
       endTime = Value(endTime),
       durationMinutes = Value(durationMinutes),
       createdAt = Value(createdAt);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? stakes,
    Expression<String>? gameType,
    Expression<double>? buyIn,
    Expression<double>? cashOut,
    Expression<double>? profitLoss,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<int>? durationMinutes,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<double>? rakePaid,
    Expression<int>? finishPosition,
    Expression<int>? totalEntrants,
    Expression<double>? prizeWon,
    Expression<int>? tableQuality,
    Expression<String>? currency,
    Expression<int>? handsPerHour,
    Expression<String>? country,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (stakes != null) 'stakes': stakes,
      if (gameType != null) 'game_type': gameType,
      if (buyIn != null) 'buy_in': buyIn,
      if (cashOut != null) 'cash_out': cashOut,
      if (profitLoss != null) 'profit_loss': profitLoss,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rakePaid != null) 'rake_paid': rakePaid,
      if (finishPosition != null) 'finish_position': finishPosition,
      if (totalEntrants != null) 'total_entrants': totalEntrants,
      if (prizeWon != null) 'prize_won': prizeWon,
      if (tableQuality != null) 'table_quality': tableQuality,
      if (currency != null) 'currency': currency,
      if (handsPerHour != null) 'hands_per_hour': handsPerHour,
      if (country != null) 'country': country,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? stakes,
    Value<String>? gameType,
    Value<double>? buyIn,
    Value<double>? cashOut,
    Value<double>? profitLoss,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<int>? durationMinutes,
    Value<String?>? location,
    Value<String?>? notes,
    Value<String>? createdAt,
    Value<double?>? rakePaid,
    Value<int?>? finishPosition,
    Value<int?>? totalEntrants,
    Value<double?>? prizeWon,
    Value<int?>? tableQuality,
    Value<String>? currency,
    Value<int?>? handsPerHour,
    Value<String?>? country,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      stakes: stakes ?? this.stakes,
      gameType: gameType ?? this.gameType,
      buyIn: buyIn ?? this.buyIn,
      cashOut: cashOut ?? this.cashOut,
      profitLoss: profitLoss ?? this.profitLoss,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rakePaid: rakePaid ?? this.rakePaid,
      finishPosition: finishPosition ?? this.finishPosition,
      totalEntrants: totalEntrants ?? this.totalEntrants,
      prizeWon: prizeWon ?? this.prizeWon,
      tableQuality: tableQuality ?? this.tableQuality,
      currency: currency ?? this.currency,
      handsPerHour: handsPerHour ?? this.handsPerHour,
      country: country ?? this.country,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (stakes.present) {
      map['stakes'] = Variable<String>(stakes.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (buyIn.present) {
      map['buy_in'] = Variable<double>(buyIn.value);
    }
    if (cashOut.present) {
      map['cash_out'] = Variable<double>(cashOut.value);
    }
    if (profitLoss.present) {
      map['profit_loss'] = Variable<double>(profitLoss.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rakePaid.present) {
      map['rake_paid'] = Variable<double>(rakePaid.value);
    }
    if (finishPosition.present) {
      map['finish_position'] = Variable<int>(finishPosition.value);
    }
    if (totalEntrants.present) {
      map['total_entrants'] = Variable<int>(totalEntrants.value);
    }
    if (prizeWon.present) {
      map['prize_won'] = Variable<double>(prizeWon.value);
    }
    if (tableQuality.present) {
      map['table_quality'] = Variable<int>(tableQuality.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (handsPerHour.present) {
      map['hands_per_hour'] = Variable<int>(handsPerHour.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('stakes: $stakes, ')
          ..write('gameType: $gameType, ')
          ..write('buyIn: $buyIn, ')
          ..write('cashOut: $cashOut, ')
          ..write('profitLoss: $profitLoss, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rakePaid: $rakePaid, ')
          ..write('finishPosition: $finishPosition, ')
          ..write('totalEntrants: $totalEntrants, ')
          ..write('prizeWon: $prizeWon, ')
          ..write('tableQuality: $tableQuality, ')
          ..write('currency: $currency, ')
          ..write('handsPerHour: $handsPerHour, ')
          ..write('country: $country')
          ..write(')'))
        .toString();
  }
}

class $RakePresetsTable extends RakePresets
    with TableInfo<$RakePresetsTable, RakePreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RakePresetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameTypeMeta = const VerificationMeta(
    'gameType',
  );
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
    'game_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stakesMeta = const VerificationMeta('stakes');
  @override
  late final GeneratedColumn<String> stakes = GeneratedColumn<String>(
    'stakes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rakeAmountMeta = const VerificationMeta(
    'rakeAmount',
  );
  @override
  late final GeneratedColumn<double> rakeAmount = GeneratedColumn<double>(
    'rake_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    location,
    gameType,
    stakes,
    rakeAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rake_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<RakePreset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('game_type')) {
      context.handle(
        _gameTypeMeta,
        gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_gameTypeMeta);
    }
    if (data.containsKey('stakes')) {
      context.handle(
        _stakesMeta,
        stakes.isAcceptableOrUnknown(data['stakes']!, _stakesMeta),
      );
    } else if (isInserting) {
      context.missing(_stakesMeta);
    }
    if (data.containsKey('rake_amount')) {
      context.handle(
        _rakeAmountMeta,
        rakeAmount.isAcceptableOrUnknown(data['rake_amount']!, _rakeAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_rakeAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RakePreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RakePreset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      gameType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_type'],
      )!,
      stakes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stakes'],
      )!,
      rakeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rake_amount'],
      )!,
    );
  }

  @override
  $RakePresetsTable createAlias(String alias) {
    return $RakePresetsTable(attachedDatabase, alias);
  }
}

class RakePreset extends DataClass implements Insertable<RakePreset> {
  final int id;
  final String location;
  final String gameType;
  final String stakes;
  final double rakeAmount;
  const RakePreset({
    required this.id,
    required this.location,
    required this.gameType,
    required this.stakes,
    required this.rakeAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['location'] = Variable<String>(location);
    map['game_type'] = Variable<String>(gameType);
    map['stakes'] = Variable<String>(stakes);
    map['rake_amount'] = Variable<double>(rakeAmount);
    return map;
  }

  RakePresetsCompanion toCompanion(bool nullToAbsent) {
    return RakePresetsCompanion(
      id: Value(id),
      location: Value(location),
      gameType: Value(gameType),
      stakes: Value(stakes),
      rakeAmount: Value(rakeAmount),
    );
  }

  factory RakePreset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RakePreset(
      id: serializer.fromJson<int>(json['id']),
      location: serializer.fromJson<String>(json['location']),
      gameType: serializer.fromJson<String>(json['gameType']),
      stakes: serializer.fromJson<String>(json['stakes']),
      rakeAmount: serializer.fromJson<double>(json['rakeAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'location': serializer.toJson<String>(location),
      'gameType': serializer.toJson<String>(gameType),
      'stakes': serializer.toJson<String>(stakes),
      'rakeAmount': serializer.toJson<double>(rakeAmount),
    };
  }

  RakePreset copyWith({
    int? id,
    String? location,
    String? gameType,
    String? stakes,
    double? rakeAmount,
  }) => RakePreset(
    id: id ?? this.id,
    location: location ?? this.location,
    gameType: gameType ?? this.gameType,
    stakes: stakes ?? this.stakes,
    rakeAmount: rakeAmount ?? this.rakeAmount,
  );
  RakePreset copyWithCompanion(RakePresetsCompanion data) {
    return RakePreset(
      id: data.id.present ? data.id.value : this.id,
      location: data.location.present ? data.location.value : this.location,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      stakes: data.stakes.present ? data.stakes.value : this.stakes,
      rakeAmount: data.rakeAmount.present
          ? data.rakeAmount.value
          : this.rakeAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RakePreset(')
          ..write('id: $id, ')
          ..write('location: $location, ')
          ..write('gameType: $gameType, ')
          ..write('stakes: $stakes, ')
          ..write('rakeAmount: $rakeAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, location, gameType, stakes, rakeAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RakePreset &&
          other.id == this.id &&
          other.location == this.location &&
          other.gameType == this.gameType &&
          other.stakes == this.stakes &&
          other.rakeAmount == this.rakeAmount);
}

class RakePresetsCompanion extends UpdateCompanion<RakePreset> {
  final Value<int> id;
  final Value<String> location;
  final Value<String> gameType;
  final Value<String> stakes;
  final Value<double> rakeAmount;
  const RakePresetsCompanion({
    this.id = const Value.absent(),
    this.location = const Value.absent(),
    this.gameType = const Value.absent(),
    this.stakes = const Value.absent(),
    this.rakeAmount = const Value.absent(),
  });
  RakePresetsCompanion.insert({
    this.id = const Value.absent(),
    required String location,
    required String gameType,
    required String stakes,
    required double rakeAmount,
  }) : location = Value(location),
       gameType = Value(gameType),
       stakes = Value(stakes),
       rakeAmount = Value(rakeAmount);
  static Insertable<RakePreset> custom({
    Expression<int>? id,
    Expression<String>? location,
    Expression<String>? gameType,
    Expression<String>? stakes,
    Expression<double>? rakeAmount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (location != null) 'location': location,
      if (gameType != null) 'game_type': gameType,
      if (stakes != null) 'stakes': stakes,
      if (rakeAmount != null) 'rake_amount': rakeAmount,
    });
  }

  RakePresetsCompanion copyWith({
    Value<int>? id,
    Value<String>? location,
    Value<String>? gameType,
    Value<String>? stakes,
    Value<double>? rakeAmount,
  }) {
    return RakePresetsCompanion(
      id: id ?? this.id,
      location: location ?? this.location,
      gameType: gameType ?? this.gameType,
      stakes: stakes ?? this.stakes,
      rakeAmount: rakeAmount ?? this.rakeAmount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (stakes.present) {
      map['stakes'] = Variable<String>(stakes.value);
    }
    if (rakeAmount.present) {
      map['rake_amount'] = Variable<double>(rakeAmount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RakePresetsCompanion(')
          ..write('id: $id, ')
          ..write('location: $location, ')
          ..write('gameType: $gameType, ')
          ..write('stakes: $stakes, ')
          ..write('rakeAmount: $rakeAmount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $RakePresetsTable rakePresets = $RakePresetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions, rakePresets];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required String date,
      required String stakes,
      Value<String> gameType,
      required double buyIn,
      required double cashOut,
      required double profitLoss,
      required String startTime,
      required String endTime,
      required int durationMinutes,
      Value<String?> location,
      Value<String?> notes,
      required String createdAt,
      Value<double?> rakePaid,
      Value<int?> finishPosition,
      Value<int?> totalEntrants,
      Value<double?> prizeWon,
      Value<int?> tableQuality,
      Value<String> currency,
      Value<int?> handsPerHour,
      Value<String?> country,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> stakes,
      Value<String> gameType,
      Value<double> buyIn,
      Value<double> cashOut,
      Value<double> profitLoss,
      Value<String> startTime,
      Value<String> endTime,
      Value<int> durationMinutes,
      Value<String?> location,
      Value<String?> notes,
      Value<String> createdAt,
      Value<double?> rakePaid,
      Value<int?> finishPosition,
      Value<int?> totalEntrants,
      Value<double?> prizeWon,
      Value<int?> tableQuality,
      Value<String> currency,
      Value<int?> handsPerHour,
      Value<String?> country,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stakes => $composableBuilder(
    column: $table.stakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get buyIn => $composableBuilder(
    column: $table.buyIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cashOut => $composableBuilder(
    column: $table.cashOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get profitLoss => $composableBuilder(
    column: $table.profitLoss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rakePaid => $composableBuilder(
    column: $table.rakePaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishPosition => $composableBuilder(
    column: $table.finishPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalEntrants => $composableBuilder(
    column: $table.totalEntrants,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prizeWon => $composableBuilder(
    column: $table.prizeWon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tableQuality => $composableBuilder(
    column: $table.tableQuality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handsPerHour => $composableBuilder(
    column: $table.handsPerHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stakes => $composableBuilder(
    column: $table.stakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get buyIn => $composableBuilder(
    column: $table.buyIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cashOut => $composableBuilder(
    column: $table.cashOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get profitLoss => $composableBuilder(
    column: $table.profitLoss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rakePaid => $composableBuilder(
    column: $table.rakePaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishPosition => $composableBuilder(
    column: $table.finishPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalEntrants => $composableBuilder(
    column: $table.totalEntrants,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prizeWon => $composableBuilder(
    column: $table.prizeWon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tableQuality => $composableBuilder(
    column: $table.tableQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handsPerHour => $composableBuilder(
    column: $table.handsPerHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get stakes =>
      $composableBuilder(column: $table.stakes, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<double> get buyIn =>
      $composableBuilder(column: $table.buyIn, builder: (column) => column);

  GeneratedColumn<double> get cashOut =>
      $composableBuilder(column: $table.cashOut, builder: (column) => column);

  GeneratedColumn<double> get profitLoss => $composableBuilder(
    column: $table.profitLoss,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get rakePaid =>
      $composableBuilder(column: $table.rakePaid, builder: (column) => column);

  GeneratedColumn<int> get finishPosition => $composableBuilder(
    column: $table.finishPosition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalEntrants => $composableBuilder(
    column: $table.totalEntrants,
    builder: (column) => column,
  );

  GeneratedColumn<double> get prizeWon =>
      $composableBuilder(column: $table.prizeWon, builder: (column) => column);

  GeneratedColumn<int> get tableQuality => $composableBuilder(
    column: $table.tableQuality,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get handsPerHour => $composableBuilder(
    column: $table.handsPerHour,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> stakes = const Value.absent(),
                Value<String> gameType = const Value.absent(),
                Value<double> buyIn = const Value.absent(),
                Value<double> cashOut = const Value.absent(),
                Value<double> profitLoss = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<double?> rakePaid = const Value.absent(),
                Value<int?> finishPosition = const Value.absent(),
                Value<int?> totalEntrants = const Value.absent(),
                Value<double?> prizeWon = const Value.absent(),
                Value<int?> tableQuality = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> handsPerHour = const Value.absent(),
                Value<String?> country = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                date: date,
                stakes: stakes,
                gameType: gameType,
                buyIn: buyIn,
                cashOut: cashOut,
                profitLoss: profitLoss,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: durationMinutes,
                location: location,
                notes: notes,
                createdAt: createdAt,
                rakePaid: rakePaid,
                finishPosition: finishPosition,
                totalEntrants: totalEntrants,
                prizeWon: prizeWon,
                tableQuality: tableQuality,
                currency: currency,
                handsPerHour: handsPerHour,
                country: country,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String stakes,
                Value<String> gameType = const Value.absent(),
                required double buyIn,
                required double cashOut,
                required double profitLoss,
                required String startTime,
                required String endTime,
                required int durationMinutes,
                Value<String?> location = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAt,
                Value<double?> rakePaid = const Value.absent(),
                Value<int?> finishPosition = const Value.absent(),
                Value<int?> totalEntrants = const Value.absent(),
                Value<double?> prizeWon = const Value.absent(),
                Value<int?> tableQuality = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int?> handsPerHour = const Value.absent(),
                Value<String?> country = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                date: date,
                stakes: stakes,
                gameType: gameType,
                buyIn: buyIn,
                cashOut: cashOut,
                profitLoss: profitLoss,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: durationMinutes,
                location: location,
                notes: notes,
                createdAt: createdAt,
                rakePaid: rakePaid,
                finishPosition: finishPosition,
                totalEntrants: totalEntrants,
                prizeWon: prizeWon,
                tableQuality: tableQuality,
                currency: currency,
                handsPerHour: handsPerHour,
                country: country,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$RakePresetsTableCreateCompanionBuilder =
    RakePresetsCompanion Function({
      Value<int> id,
      required String location,
      required String gameType,
      required String stakes,
      required double rakeAmount,
    });
typedef $$RakePresetsTableUpdateCompanionBuilder =
    RakePresetsCompanion Function({
      Value<int> id,
      Value<String> location,
      Value<String> gameType,
      Value<String> stakes,
      Value<double> rakeAmount,
    });

class $$RakePresetsTableFilterComposer
    extends Composer<_$AppDatabase, $RakePresetsTable> {
  $$RakePresetsTableFilterComposer({
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

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stakes => $composableBuilder(
    column: $table.stakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rakeAmount => $composableBuilder(
    column: $table.rakeAmount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RakePresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $RakePresetsTable> {
  $$RakePresetsTableOrderingComposer({
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

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stakes => $composableBuilder(
    column: $table.stakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rakeAmount => $composableBuilder(
    column: $table.rakeAmount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RakePresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RakePresetsTable> {
  $$RakePresetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<String> get stakes =>
      $composableBuilder(column: $table.stakes, builder: (column) => column);

  GeneratedColumn<double> get rakeAmount => $composableBuilder(
    column: $table.rakeAmount,
    builder: (column) => column,
  );
}

class $$RakePresetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RakePresetsTable,
          RakePreset,
          $$RakePresetsTableFilterComposer,
          $$RakePresetsTableOrderingComposer,
          $$RakePresetsTableAnnotationComposer,
          $$RakePresetsTableCreateCompanionBuilder,
          $$RakePresetsTableUpdateCompanionBuilder,
          (
            RakePreset,
            BaseReferences<_$AppDatabase, $RakePresetsTable, RakePreset>,
          ),
          RakePreset,
          PrefetchHooks Function()
        > {
  $$RakePresetsTableTableManager(_$AppDatabase db, $RakePresetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RakePresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RakePresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RakePresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> gameType = const Value.absent(),
                Value<String> stakes = const Value.absent(),
                Value<double> rakeAmount = const Value.absent(),
              }) => RakePresetsCompanion(
                id: id,
                location: location,
                gameType: gameType,
                stakes: stakes,
                rakeAmount: rakeAmount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String location,
                required String gameType,
                required String stakes,
                required double rakeAmount,
              }) => RakePresetsCompanion.insert(
                id: id,
                location: location,
                gameType: gameType,
                stakes: stakes,
                rakeAmount: rakeAmount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RakePresetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RakePresetsTable,
      RakePreset,
      $$RakePresetsTableFilterComposer,
      $$RakePresetsTableOrderingComposer,
      $$RakePresetsTableAnnotationComposer,
      $$RakePresetsTableCreateCompanionBuilder,
      $$RakePresetsTableUpdateCompanionBuilder,
      (
        RakePreset,
        BaseReferences<_$AppDatabase, $RakePresetsTable, RakePreset>,
      ),
      RakePreset,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$RakePresetsTableTableManager get rakePresets =>
      $$RakePresetsTableTableManager(_db, _db.rakePresets);
}
