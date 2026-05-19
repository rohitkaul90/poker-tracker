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
}

@DriftDatabase(tables: [Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(createDatabaseConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Session>> watchAllSessions() => (select(sessions)
        ..orderBy([
          (s) => OrderingTerm.desc(s.date),
          (s) => OrderingTerm.desc(s.startTime),
        ]))
      .watch();

  Future<Session?> getSession(int id) =>
      (select(sessions)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertSession(SessionsCompanion entry) =>
      into(sessions).insert(entry);

  Future<bool> updateSession(Session session) =>
      update(sessions).replace(session);

  Future<int> deleteSession(int id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();
}
