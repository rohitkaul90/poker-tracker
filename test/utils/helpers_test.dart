import 'package:flutter_test/flutter_test.dart';
import 'package:tablelab/utils/helpers.dart';
import 'package:tablelab/models/session_model.dart';

void main() {
  // ── parseBBFromStakes ────────────────────────────────────────────────────────

  group('parseBBFromStakes', () {
    test('parses standard NL stakes', () {
      expect(parseBBFromStakes('1/2'), equals(2.0));
      expect(parseBBFromStakes('2/5'), equals(5.0));
      expect(parseBBFromStakes('5/10'), equals(10.0));
      expect(parseBBFromStakes('25/50'), equals(50.0));
    });

    test('strips dollar signs', () {
      expect(parseBBFromStakes(r'$1/$2'), equals(2.0));
      expect(parseBBFromStakes(r'$2/$5'), equals(5.0));
    });

    test('handles spaces around slash', () {
      expect(parseBBFromStakes('1 / 2'), equals(2.0));
      expect(parseBBFromStakes('2 / 5'), equals(5.0));
    });

    test('returns null for unrecognisable format', () {
      expect(parseBBFromStakes(''), isNull);
      expect(parseBBFromStakes('N/A'), isNull);
      expect(parseBBFromStakes('100'), isNull);
    });

    test('handles decimal stakes', () {
      expect(parseBBFromStakes('0.5/1'), equals(1.0));
      expect(parseBBFromStakes('0.25/0.5'), equals(0.5));
    });
  });

  // ── calcBB100 ────────────────────────────────────────────────────────────────

  group('calcBB100', () {
    SessionModel makeSession({
      required double profitLoss,
      required String stakes,
      required int durationMinutes,
      int? handsPerHour,
      String gameType = 'cash',
    }) {
      return SessionModel(
        id: 'test',
        date: '2026-01-01',
        stakes: stakes,
        gameType: gameType,
        buyIn: 200,
        cashOut: 200 + profitLoss,
        profitLoss: profitLoss,
        startTime: '18:00',
        endTime: '22:00',
        durationMinutes: durationMinutes,
        createdAt: '2026-01-01T18:00:00Z',
        currency: 'USD',
        handsPerHour: handsPerHour,
      );
    }

    test('returns null for empty session list', () {
      expect(calcBB100([]), isNull);
    });

    test('returns null when no cash sessions', () {
      final sessions = [
        makeSession(profitLoss: 100, stakes: '1/2', durationMinutes: 240, gameType: 'tournament'),
      ];
      expect(calcBB100(sessions), isNull);
    });

    test('returns null when BB cannot be parsed', () {
      final sessions = [
        makeSession(profitLoss: 100, stakes: 'N/A', durationMinutes: 240),
      ];
      expect(calcBB100(sessions), isNull);
    });

    test('calculates correct BB/100 for single session', () {
      // 4h session at 25 hands/hr → 100 hands; +$100 at 1/2 → +50BB → +50 BB/100
      final sessions = [
        makeSession(
          profitLoss: 100,
          stakes: '1/2',
          durationMinutes: 240,
          handsPerHour: 25,
        ),
      ];
      final result = calcBB100(sessions);
      expect(result, isNotNull);
      expect(result!, closeTo(50.0, 0.01));
    });

    test('uses default 25 hands/hr when handsPerHour is null', () {
      // Same scenario, handsPerHour not recorded
      final sessions = [
        makeSession(profitLoss: 100, stakes: '1/2', durationMinutes: 240),
      ];
      final result = calcBB100(sessions);
      expect(result, isNotNull);
      expect(result!, closeTo(50.0, 0.01));
    });

    test('aggregates across multiple sessions', () {
      // Session 1: +$100 in 4h at 1/2 → +50BB in 100 hands
      // Session 2: -$50  in 4h at 1/2 → -25BB in 100 hands
      // Net: +25BB in 200 hands → +12.5 BB/100
      final sessions = [
        makeSession(profitLoss: 100, stakes: '1/2', durationMinutes: 240, handsPerHour: 25),
        makeSession(profitLoss: -50, stakes: '1/2', durationMinutes: 240, handsPerHour: 25),
      ];
      final result = calcBB100(sessions);
      expect(result, isNotNull);
      expect(result!, closeTo(12.5, 0.01));
    });

    test('excludes tournament sessions from BB/100', () {
      final sessions = [
        makeSession(profitLoss: 100, stakes: '1/2', durationMinutes: 240, handsPerHour: 25),
        makeSession(profitLoss: 1000, stakes: '1/2', durationMinutes: 240, gameType: 'tournament'),
      ];
      // Only the cash session counts
      final result = calcBB100(sessions);
      expect(result, isNotNull);
      expect(result!, closeTo(50.0, 0.01));
    });
  });

  // ── formatPL ─────────────────────────────────────────────────────────────────

  group('formatPL', () {
    test('formats positive amount with + sign', () {
      expect(formatPL(100), equals(r'+$100'));
      expect(formatPL(1500), equals(r'+$1,500'));
    });

    test('formats negative amount with - sign', () {
      expect(formatPL(-100), equals(r'-$100'));
      expect(formatPL(-1500), equals(r'-$1,500'));
    });

    test('formats zero as positive', () {
      expect(formatPL(0), equals(r'+$0'));
    });

    test('uses provided currency symbol', () {
      expect(formatPL(100, '£'), equals('+£100'));
      expect(formatPL(-50, '€'), equals('-€50'));
    });

    test('rounds to nearest dollar', () {
      expect(formatPL(99.6), equals(r'+$100'));
      expect(formatPL(-99.4), equals(r'-$99'));
    });
  });

  // ── currencySymbol ───────────────────────────────────────────────────────────

  group('currencySymbol', () {
    test('returns correct symbols for known currencies', () {
      expect(currencySymbol('USD'), equals(r'$'));
      expect(currencySymbol('CAD'), equals(r'CA$'));
      expect(currencySymbol('GBP'), equals('£'));
      expect(currencySymbol('EUR'), equals('€'));
      expect(currencySymbol('AUD'), equals(r'A$'));
      expect(currencySymbol('INR'), equals('₹'));
    });

    test('defaults to dollar sign for unknown currency', () {
      expect(currencySymbol('XYZ'), equals(r'$'));
    });
  });

  // ── convertCurrency ──────────────────────────────────────────────────────────

  group('convertCurrency', () {
    test('returns same amount for same currency', () {
      expect(convertCurrency(100, 'USD', 'USD'), equals(100.0));
    });

    test('converts USD to CAD approximately correctly', () {
      final result = convertCurrency(100, 'USD', 'CAD');
      expect(result, closeTo(138.0, 1.0));
    });

    test('converts CAD to USD approximately correctly', () {
      final result = convertCurrency(138, 'CAD', 'USD');
      expect(result, closeTo(100.0, 1.0));
    });

    test('round-trips within rounding tolerance', () {
      final cad = convertCurrency(100, 'USD', 'CAD');
      final usd = convertCurrency(cad, 'CAD', 'USD');
      expect(usd, closeTo(100.0, 0.01));
    });
  });

  // ── formatDuration ───────────────────────────────────────────────────────────

  group('formatDuration', () {
    test('shows only minutes when under an hour', () {
      expect(formatDuration(45), equals('45m'));
    });

    test('shows only hours when no remainder', () {
      expect(formatDuration(120), equals('2h'));
    });

    test('shows hours and minutes', () {
      expect(formatDuration(150), equals('2h 30m'));
      expect(formatDuration(95), equals('1h 35m'));
    });
  });

  // ── calcDurationMinutes ──────────────────────────────────────────────────────

  group('calcDurationMinutes', () {
    test('calculates same-day duration', () {
      expect(calcDurationMinutes('18:00', '22:30'), equals(270));
    });

    test('handles overnight sessions', () {
      expect(calcDurationMinutes('22:00', '02:00'), equals(240));
    });

    test('returns zero for invalid time strings', () {
      expect(calcDurationMinutes('bad', '22:00'), equals(0));
    });
  });

  // ── isTournamentType ─────────────────────────────────────────────────────────

  group('isTournamentType', () {
    test('identifies tournament and sit_and_go', () {
      expect(isTournamentType('tournament'), isTrue);
      expect(isTournamentType('sit_and_go'), isTrue);
    });

    test('returns false for cash games', () {
      expect(isTournamentType('cash'), isFalse);
    });
  });

  // ── fieldSizeBucket ──────────────────────────────────────────────────────────

  group('fieldSizeBucket', () {
    test('returns empty string for null or zero', () {
      expect(fieldSizeBucket(null), equals(''));
      expect(fieldSizeBucket(0), equals(''));
    });

    test('buckets correctly', () {
      expect(fieldSizeBucket(20), equals('Small (<50)'));
      expect(fieldSizeBucket(100), equals('Medium (50–200)'));
      expect(fieldSizeBucket(300), equals('Large (200–500)'));
      expect(fieldSizeBucket(1000), equals('Massive (500+)'));
    });
  });
}
