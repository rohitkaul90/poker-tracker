import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
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

  List<dynamic> _sessionToRow(SessionModel s) => [
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
      final sessions = await ref.read(supabaseServiceProvider).watchAllSessions().first;
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
      final sessions = await ref.read(supabaseServiceProvider).watchAllSessions().first;
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
        // Strip UTF-8 BOM if present
        var content = String.fromCharCodes(file.bytes!);
        if (content.startsWith('﻿')) content = content.substring(1);
        final delimiter = _detectDelimiter(content);
        final all = CsvToListConverter(
          fieldDelimiter: delimiter,
          eol: '\n',
        ).convert(content);
        if (all.isEmpty) throw Exception('File is empty.');
        headers = all.first.map((e) => e.toString().trim()).toList();
        rows = all.skip(1).where((r) => r.isNotEmpty).toList();
      } else if (ext == 'xlsx' || ext == 'xls') {
        Excel excel;
        try {
          excel = Excel.decodeBytes(file.bytes!);
        } catch (e) {
          if (e.toString().contains('numFmtId') ||
              e.toString().contains('numfmt')) {
            // Patch out built-in numFmt definitions that confuse the parser
            final patched = _patchExcelNumFmt(file.bytes!);
            excel = Excel.decodeBytes(patched);
          } else {
            rethrow;
          }
        }
        final sheetNames = excel.tables.keys.toList();
        if (sheetNames.isEmpty) throw Exception('No sheets found.');

        String sheetName;
        if (sheetNames.length == 1) {
          sheetName = sheetNames.first;
        } else {
          if (!mounted) return;
          final picked = await _pickSheet(sheetNames);
          if (picked == null) return;
          sheetName = picked;
        }

        final sheet = excel.tables[sheetName]!;
        final allRows = sheet.rows;
        if (allRows.isEmpty) throw Exception('Sheet is empty.');
        headers = allRows.first
            .map((c) => _cellValueToString(c?.value).trim())
            .toList();
        rows = allRows
            .skip(1)
            .map((r) => r.map((c) => _cellValueToString(c?.value)).toList())
            .where((r) => r.any((c) => c.isNotEmpty))
            .toList();
      } else {
        throw Exception('Unsupported file type: $ext');
      }

      // Remove completely empty header columns, keeping row data in sync.
      // If we only filter headers and leave rows unchanged, column indices
      // would be misaligned for any file that has blank header columns.
      final nonEmptyIdx = <int>[];
      for (int i = 0; i < headers.length; i++) {
        if (headers[i].isNotEmpty) nonEmptyIdx.add(i);
      }
      headers = [for (final i in nonEmptyIdx) headers[i]];
      rows = rows
          .map((r) => [for (final i in nonEmptyIdx) i < r.length ? r[i] : ''])
          .where((r) => r.any((c) => c.isNotEmpty))
          .toList();
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

  // The excel package's TextCellValue wraps its own TextSpan type (not
  // Flutter's). Its toString() already returns plain text, but formula cells
  // (FormulaCellValue) return the formula string and ignore the <v> cached
  // result. For data we care about (numbers, dates, text) the correct value
  // is in the non-formula branches, so plain toString() is fine here.
  String _cellValueToString(CellValue? value) {
    if (value == null) return '';
    return value.toString();
  }

  String _detectDelimiter(String content) {
    final sample = content.split('\n').take(5).join('\n');
    final commas = ','.allMatches(sample).length;
    final semicolons = ';'.allMatches(sample).length;
    final tabs = '\t'.allMatches(sample).length;
    if (semicolons > commas && semicolons > tabs) return ';';
    if (tabs > commas && tabs > semicolons) return '\t';
    return ',';
  }

  Future<String?> _pickSheet(List<String> sheetNames) {
    return showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select sheet'),
        children: sheetNames
            .map((name) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, name),
                  child: Text(name),
                ))
            .toList(),
      ),
    );
  }

  /// Removes `numFmt` elements with id &lt; 164 from xl/styles.xml inside the
  /// xlsx ZIP. These are built-in Excel formats that the excel package
  /// incorrectly rejects when apps embed them explicitly.
  Uint8List _patchExcelNumFmt(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final stylesFile = archive.findFile('xl/styles.xml');
      if (stylesFile == null) return bytes;

      var xml = utf8.decode(stylesFile.content as List<int>);

      // Remove any <numFmt .../> or <numFmt ...></numFmt> with id < 164
      xml = xml.replaceAllMapped(
        RegExp(
            r'<numFmt\s[^>]*numFmtId="(\d+)"[^>]*/?>(?:</numFmt>)?',
            caseSensitive: false),
        (m) {
          final id = int.tryParse(m.group(1) ?? '999') ?? 999;
          return id < 164 ? '' : m.group(0)!;
        },
      );

      final patchedBytes = utf8.encode(xml);
      final newArchive = Archive();
      for (final file in archive) {
        if (file.name == 'xl/styles.xml') {
          newArchive.addFile(ArchiveFile(
              'xl/styles.xml', patchedBytes.length, patchedBytes));
        } else {
          newArchive.addFile(file);
        }
      }
      final encoded = ZipEncoder().encode(newArchive);
      return encoded != null ? Uint8List.fromList(encoded) : bytes;
    } catch (_) {
      return bytes;
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
                      'Auto-detects: Poker Income, BankrollMob, Simply Poker, Poker Analytics, Poker Journal, PokerBase, Splendid Poker, My Poker Log, Poker Sessions, PokerTracker 4, Hold\'em Manager 3, Hand2Note, DriveHUD, Poker Copilot, Sharkscope, PokerStars History — or any custom CSV / Excel.',
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
                        '• Known app formats are auto-detected — or pick your app manually\n'
                        '• Only Date and Buy-in are required — everything else is optional\n'
                        '• If your file has only a P&L column (no Cash-out), cash-out is derived automatically\n'
                        '• Duration accepts minutes, decimal hours, "1h 30m", "1:30", and more\n'
                        '• CSV files with comma, semicolon, or tab delimiters are auto-detected\n'
                        '• Excel files with multiple sheets: you\'ll be asked which sheet to use\n'
                        '• Duplicate sessions (same date + buy-in) are skipped by default',
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
