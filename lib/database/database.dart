import 'package:drift/drift.dart';
import 'database_connection_native.dart'
    if (dart.library.html) 'database_connection_web.dart';

part 'database.g.dart';

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get stakes => text()();
  TextColumn get gameType => text().withDefault(const Constant('cash'))();
  RealColumn get buyIn => real()();
  RealColumn get cashOut => real()();
  RealColumn get profitLoss => real()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  IntColumn get durationMinutes => integer()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  // v2 columns
  RealColumn get rakePaid => real().nullable()();
  IntColumn get finishPosition => integer().nullable()();
  IntColumn get totalEntrants => integer().nullable()();
  RealColumn get prizeWon => real().nullable()();
  IntColumn get tableQuality => integer().nullable()();
  // v3 columns
  TextColumn get currency => text().withDefault(const Constant('CAD'))();
  IntColumn get handsPerHour => integer().nullable()();
  // v4 columns
  TextColumn get country => text().nullable()();
}

class RakePresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get location => text()();
  TextColumn get gameType => text()();
  TextColumn get stakes => text()();
  RealColumn get rakeAmount => real()();
}

enum SessionResult { win, loss }

class SessionFilter {
  final String? gameType;
  final String? stakes;
  final String? location;
  final String? dateFrom;
  final String? dateTo;
  final SessionResult? result;

  const SessionFilter({
    this.gameType,
    this.stakes,
    this.location,
    this.dateFrom,
    this.dateTo,
    this.result,
  });

  bool get isEmpty =>
      gameType == null &&
      stakes == null &&
      location == null &&
      dateFrom == null &&
      dateTo == null &&
      result == null;

  SessionFilter copyWith({
    Object? gameType = _sentinel,
    Object? stakes = _sentinel,
    Object? location = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    Object? result = _sentinel,
  }) {
    return SessionFilter(
      gameType:
          identical(gameType, _sentinel) ? this.gameType : gameType as String?,
      stakes:
          identical(stakes, _sentinel) ? this.stakes : stakes as String?,
      location:
          identical(location, _sentinel) ? this.location : location as String?,
      dateFrom:
          identical(dateFrom, _sentinel) ? this.dateFrom : dateFrom as String?,
      dateTo:
          identical(dateTo, _sentinel) ? this.dateTo : dateTo as String?,
      result: identical(result, _sentinel)
          ? this.result
          : result as SessionResult?,
    );
  }
}

const _sentinel = Object();

@DriftDatabase(tables: [Sessions, RakePresets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(createDatabaseConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(sessions, sessions.rakePaid);
            await m.addColumn(sessions, sessions.finishPosition);
            await m.addColumn(sessions, sessions.totalEntrants);
            await m.addColumn(sessions, sessions.prizeWon);
            await m.addColumn(sessions, sessions.tableQuality);
          }
          if (from < 3) {
            await m.addColumn(sessions, sessions.currency);
            await m.addColumn(sessions, sessions.handsPerHour);
            await m.createTable(rakePresets);
          }
          if (from < 4) {
            await m.addColumn(sessions, sessions.country);
          }
        },
      );

  Stream<List<Session>> watchAllSessions() => (select(sessions)
        ..orderBy([
          (s) => OrderingTerm.desc(s.date),
          (s) => OrderingTerm.desc(s.startTime),
        ]))
      .watch();

  Stream<List<Session>> watchFilteredSessions(SessionFilter filter) {
    final query = select(sessions)
      ..orderBy([
        (s) => OrderingTerm.desc(s.date),
        (s) => OrderingTerm.desc(s.startTime),
      ]);
    query.where((s) {
      Expression<bool> expr = const Constant(true);
      if (filter.gameType != null) {
        if (filter.gameType == 'tournament') {
          expr = expr &
              (s.gameType.equals('tournament') |
                  s.gameType.equals('sit_and_go'));
        } else {
          expr = expr & s.gameType.equals(filter.gameType!);
        }
      }
      if (filter.stakes != null) {
        expr = expr & s.stakes.equals(filter.stakes!);
      }
      if (filter.location != null) {
        expr = expr & s.location.equals(filter.location!);
      }
      if (filter.dateFrom != null) {
        expr = expr & s.date.isBiggerOrEqualValue(filter.dateFrom!);
      }
      if (filter.dateTo != null) {
        expr = expr & s.date.isSmallerOrEqualValue(filter.dateTo!);
      }
      if (filter.result == SessionResult.win) {
        expr = expr & s.profitLoss.isBiggerThanValue(0);
      } else if (filter.result == SessionResult.loss) {
        expr = expr & s.profitLoss.isSmallerOrEqualValue(0);
      }
      return expr;
    });
    return query.watch();
  }

  Future<Session?> getSession(int id) =>
      (select(sessions)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertSession(SessionsCompanion entry) =>
      into(sessions).insert(entry);

  Future<bool> updateSession(Session session) =>
      update(sessions).replace(session);

  Future<int> deleteSession(int id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();

  Future<int> clearAllSessions() => delete(sessions).go();

  Future<List<String>> getDistinctStakes() async {
    final query = selectOnly(sessions, distinct: true)
      ..addColumns([sessions.stakes])
      ..where(sessions.stakes.isNotValue('N/A'))
      ..orderBy([OrderingTerm.asc(sessions.stakes)]);
    final results = await query.get();
    return results.map((r) => r.read(sessions.stakes)!).toList();
  }

  Future<List<String>> getDistinctLocations() async {
    final query = selectOnly(sessions, distinct: true)
      ..addColumns([sessions.location])
      ..where(sessions.location.isNotNull())
      ..orderBy([OrderingTerm.asc(sessions.location)]);
    final results = await query.get();
    return results
        .map((r) => r.read(sessions.location))
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<RakePreset?> getRakePreset(
      String location, String gameType, String stakes) async {
    return (select(rakePresets)
          ..where((r) =>
              r.location.equals(location) &
              r.gameType.equals(gameType) &
              r.stakes.equals(stakes)))
        .getSingleOrNull();
  }

  Future<void> upsertRakePreset(
      String location, String gameType, String stakes, double amount) async {
    final existing = await getRakePreset(location, gameType, stakes);
    if (existing == null) {
      await into(rakePresets).insert(RakePresetsCompanion(
        location: Value(location),
        gameType: Value(gameType),
        stakes: Value(stakes),
        rakeAmount: Value(amount),
      ));
    } else {
      await (update(rakePresets)..where((r) => r.id.equals(existing.id)))
          .write(RakePresetsCompanion(rakeAmount: Value(amount)));
    }
  }
}
