import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../providers/providers.dart';
import '../utils/helpers.dart';

class _AppField {
  final String key;
  final String label;
  final bool required;

  const _AppField(this.key, this.label, {this.required = false});
}

const _appFields = [
  _AppField('date', 'Date', required: true),
  _AppField('stakes', 'Stakes', required: true),
  _AppField('buy_in', 'Buy-in', required: true),
  _AppField('game_type', 'Game Type'),
  _AppField('cash_out', 'Cash-out'),
  _AppField('prize_won', 'Prize Won (tournament)'),
  _AppField('profit_loss', 'Profit / Loss'),
  _AppField('start_time', 'Start Time'),
  _AppField('end_time', 'End Time'),
  _AppField('duration_minutes', 'Duration (minutes)'),
  _AppField('location', 'Location'),
  _AppField('notes', 'Notes'),
  _AppField('rake_paid', 'Rake / Fees'),
  _AppField('finish_position', 'Finish Position'),
  _AppField('total_entrants', 'Total Entrants'),
  _AppField('table_quality', 'Table Quality (1–5)'),
];

const _notMapped = '-- Not in file --';

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
  bool _importing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mapping = {for (final f in _appFields) f.key: _autoMap(f.key)};
  }

  String? _autoMap(String key) {
    final candidates = _normalizedCandidates(key);
    for (final c in candidates) {
      for (final h in widget.fileHeaders) {
        if (h.toLowerCase().replaceAll(RegExp(r'[\s_]'), '') ==
            c.replaceAll(RegExp(r'[\s_]'), '')) {
          return h;
        }
      }
    }
    return null;
  }

  List<String> _normalizedCandidates(String key) {
    switch (key) {
      case 'date':
        return ['date', 'session_date', 'sessiondate', 'day'];
      case 'stakes':
        return ['stakes', 'game', 'level'];
      case 'buy_in':
        return ['buyin', 'buy_in', 'buyin\$', 'investment'];
      case 'game_type':
        return ['gametype', 'game_type', 'type'];
      case 'cash_out':
        return ['cashout', 'cash_out', 'cashedout'];
      case 'prize_won':
        return ['prizewon', 'prize_won', 'prize', 'winnings'];
      case 'profit_loss':
        return ['profitloss', 'profit_loss', 'pl', 'profit', 'result', 'net'];
      case 'start_time':
        return ['starttime', 'start_time', 'start'];
      case 'end_time':
        return ['endtime', 'end_time', 'end'];
      case 'duration_minutes':
        return ['duration', 'duration_minutes', 'minutes', 'durationminutes'];
      case 'location':
        return ['location', 'venue', 'casino', 'room'];
      case 'notes':
        return ['notes', 'note', 'comments', 'memo'];
      case 'rake_paid':
        return ['rake', 'rake_paid', 'fee', 'fees', 'juice'];
      case 'finish_position':
        return ['finish', 'finish_position', 'position', 'place'];
      case 'total_entrants':
        return ['entrants', 'total_entrants', 'field', 'players'];
      case 'table_quality':
        return ['tablequality', 'table_quality', 'quality', 'tablerating'];
      default:
        return [key];
    }
  }

  Future<void> _import() async {
    setState(() {
      _importing = true;
      _error = null;
    });

    try {
      final sessions = <SessionsCompanion>[];
      final dateCol = _mapping['date'];
      final stakesCol = _mapping['stakes'];
      final buyInCol = _mapping['buy_in'];

      if (dateCol == null || stakesCol == null || buyInCol == null) {
        throw Exception('Date, Stakes, and Buy-in must be mapped.');
      }

      final headers = widget.fileHeaders;

      int colIdx(String? col) {
        if (col == null) return -1;
        return headers.indexOf(col);
      }

      final dateIdx = colIdx(dateCol);
      final stakesIdx = colIdx(stakesCol);
      final buyInIdx = colIdx(buyInCol);
      final gameTypeIdx = colIdx(_mapping['game_type']);
      final cashOutIdx = colIdx(_mapping['cash_out']);
      final prizeWonIdx = colIdx(_mapping['prize_won']);
      final plIdx = colIdx(_mapping['profit_loss']);
      final startIdx = colIdx(_mapping['start_time']);
      final endIdx = colIdx(_mapping['end_time']);
      final durationIdx = colIdx(_mapping['duration_minutes']);
      final locationIdx = colIdx(_mapping['location']);
      final notesIdx = colIdx(_mapping['notes']);
      final rakeIdx = colIdx(_mapping['rake_paid']);
      final fpIdx = colIdx(_mapping['finish_position']);
      final teIdx = colIdx(_mapping['total_entrants']);
      final tqIdx = colIdx(_mapping['table_quality']);

      for (final row in widget.rows) {
        if (row.isEmpty) continue;
        String cell(int idx) =>
            idx >= 0 && idx < row.length ? row[idx].toString().trim() : '';

        final dateRaw = cell(dateIdx);
        if (dateRaw.isEmpty) continue;
        final dateStr = _parseDate(dateRaw);
        if (dateStr == null) continue;

        final stakes = cell(stakesIdx);
        if (stakes.isEmpty) continue;

        final buyIn = double.tryParse(
                cell(buyInIdx).replaceAll(RegExp(r'[\$,]'), '')) ??
            0;

        final gameTypeRaw = cell(gameTypeIdx).toLowerCase();
        String gameType = 'cash';
        if (gameTypeRaw.contains('tournament')) {
          gameType = 'tournament';
        } else if (gameTypeRaw.contains('sit') ||
            gameTypeRaw.contains('sng') ||
            gameTypeRaw.contains('s&g')) {
          gameType = 'sit_and_go';
        }

        final isTournament = isTournamentType(gameType);
        final prizeWonRaw = prizeWonIdx >= 0
            ? double.tryParse(
                cell(prizeWonIdx).replaceAll(RegExp(r'[\$,]'), ''))
            : null;
        final cashOutRaw = cashOutIdx >= 0
            ? double.tryParse(
                cell(cashOutIdx).replaceAll(RegExp(r'[\$,]'), ''))
            : null;
        final cashOut = isTournament ? (prizeWonRaw ?? 0) : (cashOutRaw ?? 0);

        double pl;
        if (plIdx >= 0 && cell(plIdx).isNotEmpty) {
          pl = double.tryParse(
                  cell(plIdx).replaceAll(RegExp(r'[\$,]'), '')) ??
              (cashOut - buyIn);
        } else {
          pl = cashOut - buyIn;
        }

        final startTime = startIdx >= 0 && cell(startIdx).isNotEmpty
            ? _normalizeTime(cell(startIdx))
            : '00:00';
        final endTime = endIdx >= 0 && cell(endIdx).isNotEmpty
            ? _normalizeTime(cell(endIdx))
            : '00:00';

        int durationMinutes;
        if (durationIdx >= 0 && cell(durationIdx).isNotEmpty) {
          durationMinutes = int.tryParse(cell(durationIdx)) ?? 0;
        } else {
          durationMinutes = calcDurationMinutes(startTime, endTime);
        }

        final location = locationIdx >= 0 && cell(locationIdx).isNotEmpty
            ? cell(locationIdx)
            : null;
        final notes =
            notesIdx >= 0 && cell(notesIdx).isNotEmpty ? cell(notesIdx) : null;
        final rake = rakeIdx >= 0 && cell(rakeIdx).isNotEmpty
            ? double.tryParse(
                cell(rakeIdx).replaceAll(RegExp(r'[\$,]'), ''))
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

        sessions.add(SessionsCompanion.insert(
          date: dateStr,
          stakes: stakes,
          gameType: Value(gameType),
          buyIn: buyIn,
          cashOut: cashOut,
          profitLoss: pl,
          startTime: startTime,
          endTime: endTime,
          durationMinutes: durationMinutes,
          location: Value(location),
          notes: Value(notes),
          createdAt: DateTime.now().toIso8601String(),
          rakePaid: Value(rake),
          finishPosition: Value(fp),
          totalEntrants: Value(te),
          prizeWon: prizeWonIdx >= 0 ? Value(prizeWonRaw) : const Value(null),
          tableQuality: Value(tq),
        ));
      }

      if (sessions.isEmpty) throw Exception('No valid rows found to import.');

      final db = ref.read(databaseProvider);
      if (_overwrite) await db.clearAllSessions();

      for (final s in sessions) {
        await db.insertSession(s);
      }

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

  String? _parseDate(String raw) {
    final formats = [
      'yyyy-MM-dd',
      'MM/dd/yyyy',
      'dd/MM/yyyy',
      'M/d/yyyy',
      'd/M/yyyy',
      'MMM d, yyyy',
      'MMMM d, yyyy',
      'dd-MM-yyyy',
      'MM-dd-yyyy',
    ];
    for (final fmt in formats) {
      try {
        final dt = DateFormat(fmt).parseStrict(raw);
        return DateFormat('yyyy-MM-dd').format(dt);
      } catch (_) {}
    }
    // Try DateTime.parse as fallback
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(raw));
    } catch (_) {}
    return null;
  }

  String _normalizeTime(String raw) {
    try {
      // Handle HH:mm or H:mm
      if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(raw)) {
        final parts = raw.split(':');
        return '${parts[0].padLeft(2, '0')}:${parts[1]}';
      }
      // Handle 12h format
      final dt = DateFormat('h:mm a').parseLoose(raw);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '00:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropdownItems = [
      const DropdownMenuItem<String>(
          value: null, child: Text(_notMapped, style: TextStyle(color: Colors.white38))),
      ...widget.fileHeaders.map((h) => DropdownMenuItem(value: h, child: Text(h))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Map Columns')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Match your file\'s columns to app fields. Required fields are marked *.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 16),

                // Preview
                if (widget.rows.isNotEmpty) ...[
                  Text('Preview (first row)',
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

                // Mapping rows
                for (final field in _appFields) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          field.required ? '${field.label} *' : field.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: field.required
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _mapping[field.key],
                          items: dropdownItems,
                          onChanged: (v) =>
                              setState(() => _mapping[field.key] = v),
                          hint: const Text(_notMapped,
                              style: TextStyle(color: Colors.white38)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 8),
                ],

                const SizedBox(height: 16),

                // Overwrite toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Overwrite existing sessions'),
                  subtitle: const Text(
                      'If on, all current sessions will be deleted before import.'),
                  value: _overwrite,
                  onChanged: (v) => setState(() => _overwrite = v),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _importing ? null : _import,
                  child: _importing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_overwrite
                          ? 'Import (overwrite ${widget.rows.length} rows)'
                          : 'Import (append ${widget.rows.length} rows)'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
