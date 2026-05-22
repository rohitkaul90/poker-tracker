import 'package:flutter/material.dart';
import '../equity/card.dart';
import '../equity/simulator.dart';
import '../widgets/equity/card_picker.dart';
import '../widgets/equity/player_range_editor.dart';
import '../widgets/equity/range_matrix.dart';

class _PlayerState {
  String position;
  Set<int> selectedCells;

  _PlayerState({required this.position, required this.selectedCells});

  int get comboCount {
    int total = 0;
    for (final key in selectedCells) {
      total += cellComboCount(key ~/ 13, key % 13);
    }
    return total;
  }

  double get rangePercent => comboCount / 1326 * 100;

  List<List<int>> expandCombos(Set<int> excludeCards) {
    final result = <List<int>>[];
    for (final key in selectedCells) {
      for (final combo in expandCell(key ~/ 13, key % 13, exclude: excludeCards)) {
        result.add([combo.$1, combo.$2]);
      }
    }
    return result;
  }
}

class EquityCalculatorScreen extends StatefulWidget {
  const EquityCalculatorScreen({super.key});

  @override
  State<EquityCalculatorScreen> createState() => _EquityCalculatorScreenState();
}

class _EquityCalculatorScreenState extends State<EquityCalculatorScreen> {
  final List<_PlayerState> _players = [];
  final List<int?> _board = List.filled(5, null); // 0-2=flop, 3=turn, 4=river
  SimulationResult? _result;
  bool _running = false;
  String? _errorMsg;
  List<int?> _resultBoard = List.filled(5, null);

  Set<String> get _takenPositions => _players.map((p) => p.position).toSet();
  bool get _canCalculate =>
      _players.length >= 2 && _players.every((p) => p.comboCount > 0);

  void _addPlayer() {
    final available = kPositions.where((p) => !_takenPositions.contains(p)).toList();
    if (available.isEmpty) return;
    setState(() => _players.add(_PlayerState(position: available.first, selectedCells: {})));
    _openRangeEditor(_players.length - 1);
  }

  void _openRangeEditor(int idx) {
    final p = _players[idx];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => PlayerRangeEditor(
        position: p.position,
        selectedCells: p.selectedCells,
        takenPositions: _takenPositions..remove(p.position),
        onSave: (pos, cells) => setState(() {
          _players[idx].position = pos;
          _players[idx].selectedCells = cells;
          _result = null;
        }),
        onDelete: _players.length > 2
            ? () => setState(() {
                  _players.removeAt(idx);
                  _result = null;
                })
            : null,
      ),
    );
  }

  void _openCardPicker(int boardSlot) {
    final surface = Theme.of(context).colorScheme.surface;
    const shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)));

    if (boardSlot <= 2) {
      // Flop: pick all 3 at once
      final excluded = {_board[3], _board[4]}.whereType<int>().toSet();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: surface,
        shape: shape,
        builder: (_) => FlopCardPickerSheet(
          excludedCards: excluded,
          currentFlop: [_board[0], _board[1], _board[2]],
          onConfirm: (cards) => setState(() {
            _board[0] = cards[0];
            _board[1] = cards[1];
            _board[2] = cards[2];
            _result = null;
          }),
        ),
      );
    } else {
      // Turn or River: single card
      final excluded = <int>{};
      for (int i = 0; i < 5; i++) {
        if (i != boardSlot && _board[i] != null) excluded.add(_board[i]!);
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: surface,
        shape: shape,
        builder: (_) => CardPickerSheet(
          excludedCards: excluded,
          currentCard: _board[boardSlot],
          onSelected: (idx) => setState(() {
            _board[boardSlot] = idx;
            _result = null;
          }),
        ),
      );
    }
  }

  Future<void> _calculate() async {
    if (!_canCalculate) return;
    setState(() { _running = true; _errorMsg = null; });
    try {
      final boardCards = _board.whereType<int>().toList();
      final boardSet = boardCards.toSet();
      final ranges = <List<List<int>>>[];
      for (int i = 0; i < _players.length; i++) {
        final combos = _players[i].expandCombos(boardSet);
        if (combos.isEmpty) {
          setState(() {
            _errorMsg = '${_players[i].position} has no valid combos given the board.';
            _running = false;
          });
          return;
        }
        ranges.add(combos);
      }
      final result = await runSimulation(ranges: ranges, boardCards: boardCards);
      setState(() { _result = result; _resultBoard = List<int?>.from(_board); _running = false; });
    } catch (e) {
      setState(() { _errorMsg = 'Simulation error: $e'; _running = false; });
    }
  }

  void _clearBoard() => setState(() {
    _board.fillRange(0, 5, null);
    _result = null;
    _errorMsg = null;
  });

  void _reset() => setState(() {
    _players.clear();
    _board.fillRange(0, 5, null);
    _result = null;
    _errorMsg = null;
  });

  String _streetLabel(List<int?> board) {
    final n = board.whereType<int>().length;
    if (n == 0) return 'Pre-flop';
    if (n <= 3) return 'Flop';
    if (n == 4) return 'Turn';
    return 'River';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sectionLabel = TextStyle(
      fontSize: 12, fontWeight: FontWeight.bold,
      letterSpacing: 1, color: theme.colorScheme.primary,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equity Calculator'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Reset', onPressed: _reset),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Players ─────────────────────────────────────────────────
            Row(
              children: [
                Text('PLAYERS', style: sectionLabel),
                const Spacer(),
                if (_players.length < 9)
                  TextButton.icon(
                    onPressed: _addPlayer,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Player'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_players.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const Icon(Icons.people_outline, size: 48, color: Colors.white24),
                      const SizedBox(height: 8),
                      const Text('Add at least 2 players to begin',
                          style: TextStyle(color: Colors.white38)),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _players.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _PlayerCard(
                    player: _players[i],
                    equity: (_result != null && i < _result!.equity.length)
                        ? _result!.equity[i]
                        : null,
                    color: _playerColors[i % _playerColors.length],
                    onTap: () => _openRangeEditor(i),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ── Board ────────────────────────────────────────────────────
            Row(
              children: [
                Text('BOARD', style: sectionLabel),
                const Spacer(),
                if (_board.any((c) => c != null))
                  TextButton.icon(
                    onPressed: _clearBoard,
                    icon: const Icon(Icons.clear, size: 14),
                    label: const Text('Clear Board'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Each group (flop / turn / river) wrapped in Column so labels
            // sit directly below their cards — no hardcoded pixel offsets.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flop — all 3 share one label
                Column(
                  children: [
                    Row(
                      children: [
                        BoardCardChip(cardIdx: _board[0], onTap: () => _openCardPicker(0)),
                        const SizedBox(width: 6),
                        BoardCardChip(cardIdx: _board[1], onTap: () => _openCardPicker(1)),
                        const SizedBox(width: 6),
                        BoardCardChip(cardIdx: _board[2], onTap: () => _openCardPicker(2)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Flop',
                        style: TextStyle(fontSize: 10, color: Colors.white38)),
                  ],
                ),
                const SizedBox(width: 12),
                // Turn
                Column(
                  children: [
                    BoardCardChip(cardIdx: _board[3], onTap: () => _openCardPicker(3)),
                    const SizedBox(height: 4),
                    const Text('Turn',
                        style: TextStyle(fontSize: 10, color: Colors.white38)),
                  ],
                ),
                const SizedBox(width: 12),
                // River
                Column(
                  children: [
                    BoardCardChip(cardIdx: _board[4], onTap: () => _openCardPicker(4)),
                    const SizedBox(height: 4),
                    const Text('River',
                        style: TextStyle(fontSize: 10, color: Colors.white38)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Calculate ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canCalculate && !_running ? _calculate : null,
                icon: _running
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.calculate),
                label: Text(_running ? 'Calculating…' : 'Calculate Equity'),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),

            if (_errorMsg != null) ...[
              const SizedBox(height: 10),
              Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent)),
            ],

            // ── Results ──────────────────────────────────────────────────
            if (_result != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('EQUITY — ${_streetLabel(_resultBoard)}', style: sectionLabel),
                  const Spacer(),
                  Text('${_result!.iterations ~/ 1000}k iterations',
                      style: const TextStyle(fontSize: 11, color: Colors.white38)),
                ],
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < _players.length && i < _result!.equity.length; i++)
                _EquityRow(
                  position: _players[i].position,
                  equity: _result!.equity[i],
                  comboCount: _players[i].comboCount,
                  color: _playerColors[i % _playerColors.length],
                ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static const List<Color> _playerColors = [
    Colors.teal, Colors.orange, Colors.purple, Colors.blue,
    Colors.pink, Colors.green, Colors.amber, Colors.cyan, Colors.deepOrange,
  ];
}

// ── Player card on main screen ─────────────────────────────────────────────

class _PlayerCard extends StatelessWidget {
  final _PlayerState player;
  final double? equity;
  final Color color;
  final VoidCallback onTap;

  const _PlayerCard({
    required this.player,
    required this.onTap,
    required this.color,
    this.equity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRange = player.comboCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasRange ? color.withAlpha(120) : Colors.white12,
            width: hasRange ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Position chip + edit icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withAlpha(50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    player.position,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.edit, size: 11, color: Colors.white30),
              ],
            ),
            const SizedBox(height: 6),
            if (hasRange) ...[
              // Mini 13×13 matrix preview
              MiniRangeMatrix(selectedCells: player.selectedCells),
              const SizedBox(height: 4),
              Text(
                '${player.comboCount} combos  ${player.rangePercent.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 9, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              if (equity != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${(equity! * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ] else ...[
              const Spacer(),
              const Text('Tap to\nset range',
                  style: TextStyle(fontSize: 10, color: Colors.white30),
                  textAlign: TextAlign.center),
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Equity result row ──────────────────────────────────────────────────────

class _EquityRow extends StatelessWidget {
  final String position;
  final double equity;
  final int comboCount;
  final Color color;

  const _EquityRow({
    required this.position,
    required this.equity,
    required this.comboCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withAlpha(50), borderRadius: BorderRadius.circular(4)),
                child: Text(position,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ),
              const SizedBox(width: 10),
              Text('${(equity * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              Text('$comboCount combos',
                  style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: equity,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
