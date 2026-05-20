import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../providers/providers.dart';
import 'import_mapping_screen.dart';

class ImportExportScreen extends ConsumerStatefulWidget {
  const ImportExportScreen({super.key});

  @override
  ConsumerState<ImportExportScreen> createState() =>
      _ImportExportScreenState();
}

class _ImportExportScreenState extends ConsumerState<ImportExportScreen> {
  bool _busy = false;

  // ─── Export ───────────────────────────────────────────────────────────────

  List<String> get _csvHeaders => [
        'date',
        'game_type',
        'stakes',
        'buy_in',
        'cash_out',
        'prize_won',
        'profit_loss',
        'start_time',
        'end_time',
        'duration_minutes',
        'location',
        'notes',
        'rake_paid',
        'finish_position',
        'total_entrants',
        'table_quality',
      ];

  List<dynamic> _sessionToRow(Session s) => [
        s.date,
        s.gameType,
        s.stakes,
        s.buyIn,
        s.cashOut,
        s.prizeWon ?? '',
        s.profitLoss,
        s.startTime,
        s.endTime,
        s.durationMinutes,
        s.location ?? '',
        s.notes ?? '',
        s.rakePaid ?? '',
        s.finishPosition ?? '',
        s.totalEntrants ?? '',
        s.tableQuality ?? '',
      ];

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    try {
      final sessions = await ref.read(databaseProvider).watchAllSessions().first;
      if (sessions.isEmpty) {
        _showSnack('No sessions to export.');
        return;
      }

      final rows = [_csvHeaders, ...sessions.map(_sessionToRow)];
      final csv = const ListToCsvConverter().convert(rows);

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export sessions as CSV',
        fileName:
            'poker_sessions_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (path != null) {
        await File(path).writeAsString(csv);
        _showSnack('Exported ${sessions.length} sessions to CSV.');
      }
    } catch (e) {
      _showSnack('Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportExcel() async {
    setState(() => _busy = true);
    try {
      final sessions = await ref.read(databaseProvider).watchAllSessions().first;
      if (sessions.isEmpty) {
        _showSnack('No sessions to export.');
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel['Sessions'];
      excel.setDefaultSheet('Sessions');

      // Header row
      for (int i = 0; i < _csvHeaders.length; i++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
            .value = TextCellValue(_csvHeaders[i]);
      }

      // Data rows
      for (int r = 0; r < sessions.length; r++) {
        final row = _sessionToRow(sessions[r]);
        for (int c = 0; c < row.length; c++) {
          final cell = sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
          final val = row[c];
          if (val is double) {
            cell.value = DoubleCellValue(val);
          } else if (val is int) {
            cell.value = IntCellValue(val);
          } else {
            cell.value = TextCellValue(val.toString());
          }
        }
      }

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export sessions as Excel',
        fileName:
            'poker_sessions_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (path != null) {
        final bytes = excel.encode();
        if (bytes != null) {
          await File(path).writeAsBytes(bytes);
          _showSnack('Exported ${sessions.length} sessions to Excel.');
        }
      }
    } catch (e) {
      _showSnack('Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ─── Import ───────────────────────────────────────────────────────────────

  Future<void> _pickAndImport() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final ext = (file.extension ?? '').toLowerCase();

      List<String> headers;
      List<List<dynamic>> rows;

      if (ext == 'csv') {
        final content = String.fromCharCodes(file.bytes!);
        final all = const CsvToListConverter(eol: '\n').convert(content);
        if (all.isEmpty) throw Exception('File is empty.');
        headers = all.first.map((e) => e.toString().trim()).toList();
        rows = all.skip(1).where((r) => r.isNotEmpty).toList();
      } else if (ext == 'xlsx' || ext == 'xls') {
        final excel = Excel.decodeBytes(file.bytes!);
        final sheetName = excel.getDefaultSheet() ?? excel.tables.keys.first;
        final sheet = excel.tables[sheetName]!;
        final allRows = sheet.rows;
        if (allRows.isEmpty) throw Exception('Sheet is empty.');
        headers = allRows.first
            .map((c) => c?.value?.toString().trim() ?? '')
            .toList();
        rows = allRows
            .skip(1)
            .map((r) => r.map((c) => c?.value?.toString() ?? '').toList())
            .where((r) => r.any((c) => c.isNotEmpty))
            .toList();
      } else {
        throw Exception('Unsupported file type: $ext');
      }

      if (headers.isEmpty) throw Exception('No headers found.');
      if (rows.isEmpty) throw Exception('No data rows found.');

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImportMappingScreen(
              fileHeaders: headers,
              rows: rows,
            ),
          ),
        );
      }
    } catch (e) {
      _showSnack('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import / Export')),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(title: 'Export'),
                const SizedBox(height: 8),
                _ActionCard(
                  icon: Icons.table_chart_outlined,
                  title: 'Export to CSV',
                  subtitle:
                      'Save all sessions as a .csv file. Can be opened in Excel, Google Sheets, etc.',
                  onTap: _exportCsv,
                ),
                const SizedBox(height: 8),
                _ActionCard(
                  icon: Icons.grid_on_outlined,
                  title: 'Export to Excel',
                  subtitle: 'Save all sessions as a .xlsx file.',
                  onTap: _exportExcel,
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Import'),
                const SizedBox(height: 8),
                _ActionCard(
                  icon: Icons.upload_file_outlined,
                  title: 'Import from CSV or Excel',
                  subtitle:
                      'Pick any .csv or .xlsx file. You\'ll map your columns to app fields before importing.',
                  onTap: _pickAndImport,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 8),
                          Text('Import Tips',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Required columns: Date, Stakes, Buy-in\n'
                        '• Date formats accepted: YYYY-MM-DD, MM/DD/YYYY, DD/MM/YYYY, and others\n'
                        '• Game type: "cash", "tournament", or "sit_and_go"\n'
                        '• Choose Append to add rows on top of existing data, or Overwrite to replace everything',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ));
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
