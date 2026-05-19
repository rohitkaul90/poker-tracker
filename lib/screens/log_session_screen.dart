import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../providers/providers.dart';
import '../utils/helpers.dart';

const _stakeOptions = ['1/2', '1/3', '2/5', '5/10', '10/20', '25/50', 'Other'];

class LogSessionScreen extends ConsumerStatefulWidget {
  final Session? session;

  const LogSessionScreen({super.key, this.session});

  @override
  ConsumerState<LogSessionScreen> createState() => _LogSessionScreenState();
}

class _LogSessionScreenState extends ConsumerState<LogSessionScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  late String _selectedStake;
  bool _isCustomStake = false;
  final _customStakeCtrl = TextEditingController();
  final _buyInCtrl = TextEditingController();
  final _cashOutCtrl = TextEditingController();
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  double? _livePL;
  late int _liveDuration;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    if (s != null) {
      _date = DateTime.parse(s.date);
      _isCustomStake = !_stakeOptions.contains(s.stakes);
      _selectedStake = _isCustomStake ? 'Other' : s.stakes;
      if (_isCustomStake) _customStakeCtrl.text = s.stakes;
      _buyInCtrl.text = s.buyIn.toStringAsFixed(0);
      _cashOutCtrl.text = s.cashOut.toStringAsFixed(0);
      _startTime = _parseTime(s.startTime);
      _endTime = _parseTime(s.endTime);
      _locationCtrl.text = s.location ?? '';
      _notesCtrl.text = s.notes ?? '';
      _livePL = s.profitLoss;
      _liveDuration = s.durationMinutes;
    } else {
      _date = DateTime.now();
      _selectedStake = _stakeOptions[0];
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now();
      _liveDuration = 0;
    }
    _buyInCtrl.addListener(_updateLive);
    _cashOutCtrl.addListener(_updateLive);
  }

  @override
  void dispose() {
    _customStakeCtrl.dispose();
    _buyInCtrl.dispose();
    _cashOutCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _updateLive() {
    final buyIn = double.tryParse(_buyInCtrl.text);
    final cashOut = double.tryParse(_cashOutCtrl.text);
    setState(() {
      _livePL = (buyIn != null && cashOut != null) ? cashOut - buyIn : null;
      _liveDuration =
          calcDurationMinutes(_formatTime(_startTime), _formatTime(_endTime));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _startTime);
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _liveDuration =
            calcDurationMinutes(_formatTime(_startTime), _formatTime(_endTime));
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: _endTime);
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _liveDuration =
            calcDurationMinutes(_formatTime(_startTime), _formatTime(_endTime));
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final stakesVal =
        _isCustomStake ? _customStakeCtrl.text.trim() : _selectedStake;
    final buyIn = double.parse(_buyInCtrl.text);
    final cashOut = double.parse(_cashOutCtrl.text);
    final pl = cashOut - buyIn;
    final startStr = _formatTime(_startTime);
    final endStr = _formatTime(_endTime);
    final dur = calcDurationMinutes(startStr, endStr);
    final dateStr = DateFormat('yyyy-MM-dd').format(_date);
    final now = DateTime.now().toIso8601String();

    Value<String?> locationVal = Value(
        _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim());
    Value<String?> notesVal = Value(
        _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim());

    final db = ref.read(databaseProvider);
    final s = widget.session;

    if (s == null) {
      await db.insertSession(SessionsCompanion(
        date: Value(dateStr),
        stakes: Value(stakesVal),
        buyIn: Value(buyIn),
        cashOut: Value(cashOut),
        profitLoss: Value(pl),
        startTime: Value(startStr),
        endTime: Value(endStr),
        durationMinutes: Value(dur),
        location: locationVal,
        notes: notesVal,
        createdAt: Value(now),
      ));
    } else {
      await db.updateSession(s.copyWith(
        date: dateStr,
        stakes: stakesVal,
        buyIn: buyIn,
        cashOut: cashOut,
        profitLoss: pl,
        startTime: startStr,
        endTime: endStr,
        durationMinutes: dur,
        location: locationVal,
        notes: notesVal,
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session == null ? 'Log Session' : 'Edit Session'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(_date)),
              onTap: _pickDate,
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Stakes
            DropdownButtonFormField<String>(
              initialValue: _selectedStake,
              decoration: const InputDecoration(
                labelText: 'Stakes',
                border: OutlineInputBorder(),
              ),
              items: _stakeOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedStake = v!;
                _isCustomStake = v == 'Other';
              }),
            ),
            if (_isCustomStake) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _customStakeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Custom Stakes',
                  hintText: 'e.g. 3/6',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (_isCustomStake &&
                        (v == null || v.trim().isEmpty))
                    ? 'Enter stakes'
                    : null,
              ),
            ],
            const SizedBox(height: 16),

            // Buy-in / Cash-out
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buyInCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Buy-in',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cashOutCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Cash-out',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Start / End time
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time),
                    title: const Text('Start'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: _pickStartTime,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time_filled),
                    title: const Text('End'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: _pickEndTime,
                  ),
                ),
              ],
            ),

            // Live summary
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Duration',
                            style: theme.textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          formatDuration(_liveDuration),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (_livePL != null)
                      Column(
                        children: [
                          Text('Result', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text(
                            formatPL(_livePL!),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _livePL! >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Location
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'e.g. Horseshoe Casino',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
              child: const Text('Save Session'),
            ),
          ],
        ),
      ),
    );
  }
}
