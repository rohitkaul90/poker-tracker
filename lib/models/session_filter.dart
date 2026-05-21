import 'session_model.dart';

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

  bool matches(SessionModel s) {
    if (gameType != null) {
      if (gameType == 'tournament') {
        if (s.gameType != 'tournament' && s.gameType != 'sit_and_go') return false;
      } else if (s.gameType != gameType) {
        return false;
      }
    }
    if (stakes != null && s.stakes != stakes) return false;
    if (location != null && s.location != location) return false;
    if (dateFrom != null && s.date.compareTo(dateFrom!) < 0) return false;
    if (dateTo != null && s.date.compareTo(dateTo!) > 0) return false;
    if (result == SessionResult.win && s.profitLoss <= 0) return false;
    if (result == SessionResult.loss && s.profitLoss > 0) return false;
    return true;
  }

  SessionFilter copyWith({
    Object? gameType = _sentinel,
    Object? stakes = _sentinel,
    Object? location = _sentinel,
    Object? dateFrom = _sentinel,
    Object? dateTo = _sentinel,
    Object? result = _sentinel,
  }) {
    return SessionFilter(
      gameType: identical(gameType, _sentinel) ? this.gameType : gameType as String?,
      stakes: identical(stakes, _sentinel) ? this.stakes : stakes as String?,
      location: identical(location, _sentinel) ? this.location : location as String?,
      dateFrom: identical(dateFrom, _sentinel) ? this.dateFrom : dateFrom as String?,
      dateTo: identical(dateTo, _sentinel) ? this.dateTo : dateTo as String?,
      result: identical(result, _sentinel) ? this.result : result as SessionResult?,
    );
  }
}

const _sentinel = Object();
