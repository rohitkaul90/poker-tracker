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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
  );
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
          other.createdAt == this.createdAt);
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
