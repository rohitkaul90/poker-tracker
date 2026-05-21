import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/poker_rooms.dart';
import '../providers/providers.dart';
import '../utils/helpers.dart';

// ─── Field definitions ────────────────────────────────────────────────────────

class _AppField {
  final String key;
  final String label;
  final bool required;
  final String? hint;

  const _AppField(this.key, this.label, {this.required = false, this.hint});
}

const _appFields = [
  _AppField('date',             'Date',                   required: true),
  _AppField('buy_in',           'Buy-in',                 required: true),
  _AppField('game_type',        'Game Type',              hint: 'cash / tournament'),
  _AppField('stakes',           'Stakes',                 hint: 'e.g. 1/2, 2/5'),
  _AppField('cash_out',         'Cash-out'),
  _AppField('prize_won',        'Prize Won'),
  _AppField('duration_minutes', 'Duration (minutes)'),
  _AppField('duration_hours',   'Duration (hours)',       hint: 'auto-converted to minutes'),
  _AppField('start_time',       'Start Time'),
  _AppField('end_time',         'End Time'),
  _AppField('location',         'Location / Venue'),
  _AppField('currency',         'Currency',               hint: 'CAD, USD, GBP…'),
  _AppField('country',          'Country',                hint: 'Canada, USA, UK…'),
  _AppField('hands_per_hour',   'Hands per Hour'),
  _AppField('notes',            'Notes'),
  _AppField('rake_paid',        'Rake / Fees'),
  _AppField('finish_position',  'Finish Position'),
  _AppField('total_entrants',   'Total Entrants'),
  _AppField('table_quality',    'Table Quality (1–5)'),
];

const _notMapped = '-- Not in file --';

// ─── Preview model ────────────────────────────────────────────────────────────

class _RowIssue {
  final int rowNum;
  final String message;
  const _RowIssue(this.rowNum, this.message);
}

class _ImportPreview {
  final int valid;
  final int total;
  final String? dateMin;
  final String? dateMax;
  final List<_RowIssue> issues;

  const _ImportPreview({
    required this.valid,
    required this.total,
    this.dateMin,
    this.dateMax,
    this.issues = const [],
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class ImportMappingScreen extends ConsumerStatefulWidget {
  final List<String> fileHeaders;
  final List<List<dynamic>> rows;

  const ImportMappingScreen({
    super.key,
    required this.fileHeaders,
    required this.rows,
  });

  @override
  ConsumerState<ImportMappingScreen> createState() =>
      _ImportMappingScreenState();
}

class _ImportMappingScreenState extends ConsumerState<ImportMappingScreen> {
  late Map<String, String?> _mapping;
  bool _overwrite = false;
  bool _skipDuplicates = true;
  bool _importing = false;
  String? _error;
  late _ImportPreview _preview;

  @override
  void initState() {
    super.initState();
    _mapping = {for (final f in _appFields) f.key: _autoMap(f.key)};
    _preview = _computePreview();
  }

  // ─── Auto-mapping ────────────────────────────────────────────────────────

  String? _autoMap(String key) {
    final candidates = _candidates(key);
    for (final h in widget.fileHeaders) {
      final norm =
          h.toLowerCase().replaceAll(RegExp(r'[\s_\-\(\)\$£€#]'), '');
      for (final c in candidates) {
        final cn = c.replaceAll(RegExp(r'[\s_\-]'), '');
        // Exact match, or prefix match when the candidate is specific enough (≥8 chars)
        if (norm == cn || (cn.length >= 8 && norm.startsWith(cn))) return h;
      }
    }
    return null;
  }

  List<String> _candidates(String key) {
    switch (key) {
      case 'date':
        return [
          'date', 'sessiondate', 'session_date', 'day', 'playdate',
          'gamedate', 'game_date', 'played', 'eventdate',
        ];
      case 'buy_in':
        return [
          'buyin', 'buy_in', 'cashin', 'cash_in', 'investment', 'entry',
          'entryamount', 'buyin\$', 'buyinfee', 'buyinamount',
          'totalbuyin', 'totalinvestment',
        ];
      case 'game_type':
        return [
          'gametype', 'game_type', 'type', 'format', 'sessiontype',
          'variant', 'gameformat', 'pokertype',
        ];
      case 'stakes':
        return [
          'stakes', 'level', 'blinds', 'limit', 'gamestakes', 'game',
          'gamelevel', 'tablesize', 'smallblind', 'structure',
        ];
      case 'cash_out':
        return [
          'cashout', 'cash_out', 'cashedout', 'walkaway', 'endup',
          'ending', 'endamount', 'finalchips', 'total', 'out',
          'endstack', 'finishstack', 'chipcount',
        ];
      case 'prize_won':
        return [
          'prizewon', 'prize_won', 'prize', 'winnings', 'payout',
          'winning', 'award', 'earnings', 'cashed',
        ];
      case 'profit_loss':
        return [
          // Specific long-form first so prefix-match picks home-currency columns
          // over CAD-converted ones when both exist in the same file
          'netprofitlossinhomecurrency', 'netprofitlosslocalcurrency',
          'profitlossinhomecurrency', 'netprofitlosshomecurrency',
          'profitloss', 'profit_loss', 'pl', 'profit', 'loss',
          'result', 'net', 'netsession', 'netresult', 'gain',
          'netgain', 'delta', '+/-', 'netscore', 'netprofit',
          'sessionpl', 'sessionresult', 'sessionprofit',
        ];
      case 'duration_minutes':
        return [
          'durationminutes', 'duration_minutes', 'minutes',
          'sessionminutes', 'lengthminutes', 'playtimeminutes',
        ];
      case 'duration_hours':
        return [
          'durationhours', 'duration_hours', 'hours', 'sessionhours',
          'lengthhours', 'timeplayed', 'sessionlength', 'length',
          'hoursplayed', 'hrsplayed', 'hrplayed', 'duration', 'playtime',
        ];
      case 'start_time':
        return [
          'starttime', 'start_time', 'start', 'startsat', 'timestart',
          'began', 'begin', 'startedsat',
        ];
      case 'end_time':
        return [
          'endtime', 'end_time', 'end', 'endsat', 'timeend',
          'finished', 'finish', 'endedat',
        ];
      case 'location':
        return [
          'location', 'venue', 'casino', 'room', 'place',
          'cardroom', 'pokerroom', 'where', 'site', 'club',
        ];
      case 'currency':
        return ['currency', 'curr', 'ccy', 'moneytype', 'currencycode'];
      case 'country':
        return ['country', 'nation', 'locationcountry', 'country_played', 'jurisdiction'];
      case 'hands_per_hour':
        return [
          'handsperhour', 'hands_per_hour', 'hph', 'handshr', 'handrate',
        ];
      case 'notes':
        return [
          'notes', 'note', 'comments', 'memo', 'comment',
          'remarks', 'description', 'tags',
        ];
      case 'rake_paid':
        return [
          'rake', 'rake_paid', 'fee', 'fees', 'juice', 'commission',
          'house', 'rakefee',
        ];
      case 'finish_position':
        return [
          'finish', 'finish_position', 'position', 'place',
          'finishplace', 'finishpos', 'rank', 'placed', 'finishedpos',
        ];
      case 'total_entrants':
        return [
          'entrants', 'total_entrants', 'field', 'players',
          'fieldsize', 'totalplayers', 'entries', 'startingfield',
        ];
      case 'table_quality':
        return [
          'tablequality', 'table_quality', 'quality', 'tablerating',
          'softness', 'gamerating', 'fishrating',
        ];
      default:
        return [key];
    }
  }

  // ─── Live preview ─────────────────────────────────────────────────────────

  _ImportPreview _computePreview() {
    int valid = 0;
    String? dateMin, dateMax;
    final issues = <_RowIssue>[];

    final headers = widget.fileHeaders;
    int colIdx(String? col) => col == null ? -1 : headers.indexOf(col);

    final dateIdx    = colIdx(_mapping['date']);
    final buyInIdx   = colIdx(_mapping['buy_in']);
    final cashOutIdx = colIdx(_mapping['cash_out']);
    final prizeWonIdx2 = colIdx(_mapping['prize_won']);

    for (int i = 0; i < widget.rows.length; i++) {
      final row = widget.rows[i];
      String cell(int idx) =>
          idx >= 0 && idx < row.length ? row[idx].toString().trim() : '';

      final dateRaw = cell(dateIdx);
      if (dateRaw.isEmpty) {
        if (issues.length < 5) issues.add(_RowIssue(i + 2, 'Missing date'));
        continue;
      }
      final dateStr = _parseDate(dateRaw);
      if (dateStr == null) {
        if (issues.length < 5) {
          issues.add(_RowIssue(i + 2, 'Unrecognised date: "$dateRaw"'));
        }
        continue;
      }

      final buyInStr =
          cell(buyInIdx).replaceAll(RegExp(r'[\$,£€₹]'), '').trim();
      if (buyInStr.isEmpty || double.tryParse(buyInStr) == null) {
        if (issues.length < 5) {
          issues.add(_RowIssue(
              i + 2, 'Invalid buy-in: "${cell(buyInIdx)}"'));
        }
        continue;
      }

      final hasResult = (cashOutIdx >= 0 && cell(cashOutIdx).isNotEmpty) ||
          (prizeWonIdx2 >= 0 && cell(prizeWonIdx2).isNotEmpty);
      if (!hasResult && issues.length < 5) {
        issues.add(_RowIssue(i + 2, 'No cash-out or prize — will record \$0'));
      }

      if (dateMin == null || dateStr.compareTo(dateMin) < 0) dateMin = dateStr;
      if (dateMax == null || dateStr.compareTo(dateMax) > 0) dateMax = dateStr;
      valid++;
    }

    return _ImportPreview(
      valid: valid,
      total: widget.rows.length,
      dateMin: dateMin,
      dateMax: dateMax,
      issues: issues,
    );
  }

  // ─── Import ───────────────────────────────────────────────────────────────

  Future<void> _import() async {
    // Warn if no result field is mapped
    final hasResult = _mapping['cash_out'] != null ||
        _mapping['prize_won'] != null;

    if (!hasResult) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No result column mapped'),
          content: const Text(
            'You haven\'t mapped Cash-out or Prize Won.\n\n'
            'All imported sessions will show \$0 P&L. '
            'P&L is always calculated as Cash-out minus Buy-in.\n\n'
            'Import anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Go back'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import anyway'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() {
      _importing = true;
      _error = null;
    });

    try {
      final service = ref.read(supabaseServiceProvider);
      final headers = widget.fileHeaders;
      int colIdx(String? col) => col == null ? -1 : headers.indexOf(col);

      final dateIdx      = colIdx(_mapping['date']);
      final buyInIdx     = colIdx(_mapping['buy_in']);
      final gameTypeIdx  = colIdx(_mapping['game_type']);
      final stakesIdx    = colIdx(_mapping['stakes']);
      final cashOutIdx   = colIdx(_mapping['cash_out']);
      final prizeWonIdx  = colIdx(_mapping['prize_won']);
      final durMIdx      = colIdx(_mapping['duration_minutes']);
      final durHIdx      = colIdx(_mapping['duration_hours']);
      final startIdx     = colIdx(_mapping['start_time']);
      final endIdx       = colIdx(_mapping['end_time']);
      final locationIdx  = colIdx(_mapping['location']);
      final currencyIdx  = colIdx(_mapping['currency']);
      final countryIdx   = colIdx(_mapping['country']);
      final hphIdx       = colIdx(_mapping['hands_per_hour']);
      final notesIdx     = colIdx(_mapping['notes']);
      final rakeIdx      = colIdx(_mapping['rake_paid']);
      final fpIdx        = colIdx(_mapping['finish_position']);
      final teIdx        = colIdx(_mapping['total_entrants']);
      final tqIdx        = colIdx(_mapping['table_quality']);

      // Load existing sessions for duplicate detection
      Set<String>? existingKeys;
      if (_skipDuplicates && !_overwrite) {
        final existing = await service.watchAllSessions().first;
        existingKeys = existing
            .map((s) => '${s.date}_${s.buyIn.toStringAsFixed(2)}')
            .toSet();
      }

      final sessions = <Map<String, dynamic>>[];

      for (final row in widget.rows) {
        if (row.isEmpty) continue;
        String cell(int idx) =>
            idx >= 0 && idx < row.length ? row[idx].toString().trim() : '';

        final dateRaw = cell(dateIdx);
        if (dateRaw.isEmpty) continue;
        final dateStr = _parseDate(dateRaw);
        if (dateStr == null) continue;

        final buyInStr =
            cell(buyInIdx).replaceAll(RegExp(r'[\$,£€₹]'), '').trim();
        final buyIn = double.tryParse(buyInStr) ?? 0;

        // Duplicate check
        if (existingKeys != null) {
          final key = '${dateStr}_${buyIn.toStringAsFixed(2)}';
          if (existingKeys.contains(key)) continue;
        }

        // Game type
        final gameTypeRaw = cell(gameTypeIdx).toLowerCase().trim();
        String gameType = 'cash';
        if (gameTypeRaw.contains('tournament') ||
            gameTypeRaw == 'mtt' ||
            gameTypeRaw == 'tourney' ||
            gameTypeRaw == 'plo tournament') {
          gameType = 'tournament';
        } else if (gameTypeRaw.contains('sit') ||
            gameTypeRaw.contains('sng') ||
            gameTypeRaw.contains('s&g')) {
          gameType = 'sit_and_go';
        }

        // Stakes — defaults gracefully
        final stakesRaw = cell(stakesIdx).trim();
        final stakes = stakesRaw.isNotEmpty
            ? stakesRaw
            : isTournamentType(gameType) ? 'N/A' : 'Cash';

        // Location — must come before currency so country inference works
        final location =
            locationIdx >= 0 && cell(locationIdx).isNotEmpty
                ? cell(locationIdx)
                : null;

        // Country: explicit column → infer from location room lookup
        String? country;
        if (countryIdx >= 0 && cell(countryIdx).isNotEmpty) {
          country = cell(countryIdx);
        } else if (location != null) {
          country = countryFromLocation(location);
          // Also try matching by room name (for plain site names like "PokerBaazi")
          if (country == null) {
            final locLower = location.toLowerCase();
            final match = kPokerRooms.where(
              (r) => r.name.toLowerCase() == locLower,
            ).firstOrNull;
            country = match?.country;
          }
        }

        // Currency priority: explicit column → country inference → room lookup → online default → CAD
        const validCurrencies = ['CAD', 'USD', 'GBP', 'EUR', 'AUD', 'NZD', 'INR'];
        String currency;
        final currencyRaw =
            cell(currencyIdx).toUpperCase().replaceAll(RegExp(r'\s'), '');
        if (validCurrencies.contains(currencyRaw)) {
          currency = currencyRaw;
        } else {
          final fromCountry = currencyFromCountry(country);
          if (fromCountry != null) {
            currency = fromCountry;
          } else if (location != null) {
            // Try room-specific currency from the location/room name
            final locLower = location.toLowerCase();
            final roomCurrency = kPokerRooms
                .where((r) =>
                    r.storageKey == location ||
                    r.name.toLowerCase() == locLower)
                .firstOrNull
                ?.currency;
            if (roomCurrency != null) {
              currency = roomCurrency;
            } else if (isOnlineSession(location)) {
              currency = 'USD';
            } else {
              currency = 'CAD';
            }
          } else {
            currency = 'CAD';
          }
        }

        // Prize won
        final prizeWonRaw = prizeWonIdx >= 0
            ? double.tryParse(
                cell(prizeWonIdx).replaceAll(RegExp(r'[\$,£€₹]'), ''))
            : null;

        // Cash out
        final cashOutRaw = cashOutIdx >= 0
            ? double.tryParse(
                cell(cashOutIdx).replaceAll(RegExp(r'[\$,£€₹]'), ''))
            : null;

        // For tournaments: prize_won column first, then cash_out column
        // (many tracking files use a single "Cash Out" column for both).
        // P&L is always calculated as cashOut - buyIn; never read from file.
        double cashOut = isTournamentType(gameType)
            ? (prizeWonRaw ?? cashOutRaw ?? 0)
            : (cashOutRaw ?? 0);

        final double pl = cashOut - buyIn;

        // Duration
        int durationMinutes = 0;
        if (durMIdx >= 0 && cell(durMIdx).isNotEmpty) {
          durationMinutes = int.tryParse(
                  cell(durMIdx).replaceAll(RegExp(r'[^\d]'), '')) ??
              0;
        } else if (durHIdx >= 0 && cell(durHIdx).isNotEmpty) {
          final hoursStr =
              cell(durHIdx).replaceAll(RegExp(r'[hH\s]'), '').trim();
          final hours = double.tryParse(hoursStr) ?? 0;
          durationMinutes = (hours * 60).round();
        } else if (startIdx >= 0 && endIdx >= 0) {
          durationMinutes = calcDurationMinutes(
            _normalizeTime(cell(startIdx)),
            _normalizeTime(cell(endIdx)),
          );
        }

        final startTime = startIdx >= 0 && cell(startIdx).isNotEmpty
            ? _normalizeTime(cell(startIdx))
            : '00:00';
        final endTime = endIdx >= 0 && cell(endIdx).isNotEmpty
            ? _normalizeTime(cell(endIdx))
            : '00:00';
        final notes =
            notesIdx >= 0 && cell(notesIdx).isNotEmpty ? cell(notesIdx) : null;
        final rake = rakeIdx >= 0 && cell(rakeIdx).isNotEmpty
            ? double.tryParse(
                cell(rakeIdx).replaceAll(RegExp(r'[\$,£€₹]'), ''))
            : null;
        final fp = fpIdx >= 0 && cell(fpIdx).isNotEmpty
            ? int.tryParse(cell(fpIdx))
            : null;
        final te = teIdx >= 0 && cell(teIdx).isNotEmpty
            ? int.tryParse(cell(teIdx))
            : null;
        final tq = tqIdx >= 0 && cell(tqIdx).isNotEmpty
            ? int.tryParse(cell(tqIdx))
            : null;
        final hph = hphIdx >= 0 && cell(hphIdx).isNotEmpty
            ? int.tryParse(cell(hphIdx))
            : null;

        sessions.add({
          'date': dateStr,
          'stakes': stakes,
          'game_type': gameType,
          'buy_in': buyIn,
          'cash_out': cashOut,
          'profit_loss': pl,
          'start_time': startTime,
          'end_time': endTime,
          'duration_minutes': durationMinutes,
          'currency': currency,
          'location': location,
          'notes': notes,
          'created_at': DateTime.now().toIso8601String(),
          'rake_paid': rake,
          'finish_position': fp,
          'total_entrants': te,
          'prize_won': prizeWonIdx >= 0
              ? prizeWonRaw
              : (isTournamentType(gameType) ? cashOutRaw : null),
          'table_quality': tq,
          'hands_per_hour': hph,
          'country': country,
        });
      }

      if (sessions.isEmpty) {
        throw Exception('No valid rows found to import.');
      }

      if (_overwrite) await service.clearAllSessions();
      await service.bulkInsertSessions(sessions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Imported ${sessions.length} session${sessions.length == 1 ? '' : 's'}.'),
        ));
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  // ─── Parsing helpers ──────────────────────────────────────────────────────

  String? _parseDate(String raw) {
    // Strip leading day names: "Mon, ", "Monday "
    final cleaned = raw
        .replaceAll(
            RegExp(
                r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)[a-z]*(,\s*|\s+)',
                caseSensitive: false),
            '')
        .trim();

    // Excel serial date numbers (e.g. "45365" or "45365.0").
    // These appear when the excel package loses the date numFmt after patching.
    // Valid range: ~36526 (Jan 1, 2000) to ~73050 (Jan 1, 2100).
    final asNum = double.tryParse(cleaned);
    if (asNum != null && asNum >= 36526 && asNum <= 73050) {
      final serial = asNum.truncate();
      // Excel counts 1900 as a leap year (it isn't). For serials > 59, subtract
      // 1 to skip the phantom Feb 29, 1900 that Excel incorrectly includes.
      final effectiveDays = serial > 59 ? serial - 1 : serial;
      final dt = DateTime.utc(1899, 12, 30).add(Duration(days: effectiveDays));
      return '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';
    }

    const formats = [
      'yyyy-MM-dd', 'MM/dd/yyyy', 'dd/MM/yyyy', 'M/d/yyyy',
      'd/M/yyyy', 'MMM d, yyyy', 'MMMM d, yyyy', 'dd-MM-yyyy',
      'MM-dd-yyyy', 'd MMM yyyy', 'MMM dd yyyy', 'yyyy/MM/dd',
      'dd.MM.yyyy', 'M/d/yy', 'd/M/yy', 'MMM-dd-yyyy',
    ];
    for (final fmt in formats) {
      try {
        return DateFormat('yyyy-MM-dd')
            .format(DateFormat(fmt).parseStrict(cleaned));
      } catch (_) {}
    }
    // ISO 8601 (e.g. "2024-03-14T00:00:00.000Z" from DateCellValue.toString()).
    // Always extract the UTC calendar date to avoid midnight UTC → previous day
    // in local timezone.
    try {
      final dt = DateTime.parse(cleaned).toUtc();
      return '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {}
    return null;
  }

  String _normalizeTime(String raw) {
    if (raw.isEmpty) return '00:00';
    try {
      if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(raw)) {
        final parts = raw.split(':');
        return '${parts[0].padLeft(2, '0')}:${parts[1]}';
      }
      return DateFormat('HH:mm').format(DateFormat('h:mm a').parseLoose(raw));
    } catch (_) {
      return '00:00';
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dropdownItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: null,
        child: Text(_notMapped, style: TextStyle(color: Colors.white38)),
      ),
      ...widget.fileHeaders.map(
        (h) => DropdownMenuItem(
          value: h,
          child: Text(h, overflow: TextOverflow.ellipsis),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Map Columns')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Import preview ───────────────────────────────────────────
                _PreviewCard(preview: _preview),
                const SizedBox(height: 12),
                Text(
                  'Match your file\'s columns to app fields. '
                  'Only Date and Buy-in are required — everything else is inferred or optional.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 12),

                // ── Data preview ─────────────────────────────────────────────
                if (widget.rows.isNotEmpty) ...[
                  Text('First row preview',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      headingRowHeight: 32,
                      dataRowMinHeight: 28,
                      dataRowMaxHeight: 28,
                      columns: widget.fileHeaders
                          .map((h) => DataColumn(
                                label: Text(h,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      rows: [
                        DataRow(
                          cells: List.generate(
                            widget.fileHeaders.length,
                            (i) => DataCell(Text(
                              i < widget.rows[0].length
                                  ? widget.rows[0][i].toString()
                                  : '',
                              style: const TextStyle(fontSize: 11),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                ],

                // ── Mapping rows ─────────────────────────────────────────────
                for (final field in _appFields) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              field.required
                                  ? '${field.label} *'
                                  : field.label,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: field.required
                                            ? FontWeight.bold
                                            : null,
                                      ),
                            ),
                            if (field.hint != null)
                              Text(
                                field.hint!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _mapping[field.key],
                          items: dropdownItems,
                          onChanged: (v) => setState(() {
                            _mapping[field.key] = v;
                            _preview = _computePreview();
                          }),
                          hint: const Text(_notMapped,
                              style: TextStyle(color: Colors.white38)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 8),
                ],

                const SizedBox(height: 8),

                // ── Options ──────────────────────────────────────────────────
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Skip duplicate sessions'),
                  subtitle: const Text(
                      'Skip rows whose date + buy-in match an existing session.'),
                  value: _skipDuplicates,
                  onChanged: _overwrite
                      ? null
                      : (v) => setState(() => _skipDuplicates = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Overwrite existing sessions'),
                  subtitle: const Text(
                      'Delete all current sessions before importing.'),
                  value: _overwrite,
                  onChanged: (v) => setState(() {
                    _overwrite = v;
                    if (v) _skipDuplicates = false;
                  }),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withAlpha(80)),
                    ),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ],
            ),
          ),

          // ── Import button ────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed:
                      (_importing || _preview.valid == 0) ? null : _import,
                  child: _importing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_overwrite
                          ? 'Import & overwrite  (${_preview.valid} rows)'
                          : 'Import ${_preview.valid} rows'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Preview Card ─────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final _ImportPreview preview;

  const _PreviewCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    final pct = preview.total > 0
        ? (preview.valid / preview.total * 100).round()
        : 0;
    final color =
        pct >= 90 ? Colors.green : pct >= 50 ? Colors.amber : Colors.red;

    String dateRange = '';
    if (preview.dateMin != null && preview.dateMax != null) {
      final fmt = DateFormat('MMM d, yyyy');
      final min = fmt.format(DateTime.parse(preview.dateMin!));
      final max = fmt.format(DateTime.parse(preview.dateMax!));
      dateRange = preview.dateMin == preview.dateMax ? min : '$min – $max';
    }

    final extraIssues =
        preview.total - preview.valid - preview.issues.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  preview.valid > 0
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  '${preview.valid} of ${preview.total} rows ready to import',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            if (dateRange.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Sessions: $dateRange',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
            if (preview.issues.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final issue in preview.issues)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Row ${issue.rowNum}: ${issue.message}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                  ),
                ),
              if (extraIssues > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '… and $extraIssues more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
