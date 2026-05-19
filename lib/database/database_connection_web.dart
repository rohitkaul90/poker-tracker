// ignore_for_file: deprecated_member_use
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

DatabaseConnection createDatabaseConnection() {
  return DatabaseConnection(WebDatabase('poker_tracker'));
}
