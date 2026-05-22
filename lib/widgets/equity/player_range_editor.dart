import 'package:flutter/material.dart';
import '../../equity/gto_ranges.dart';
import 'range_matrix.dart';

const List<String> kPositions = [
  'UTG', 'UTG+1', 'UTG+2', 'MP', 'HJ', 'CO', 'BTN', 'SB', 'BB',
];

class PlayerRangeEditor extends StatefulWidget {
  final String position;
  final Set<int> selectedCells;
  final Set<String> takenPositions; // positions already used by other players
  final void Function(String position, Set<int> cells) onSave;
  final VoidCallback? onDelete;

  const PlayerRangeEditor({
    super.key,
    required this.position,
    required this.selectedCells,
    required this.takenPositions,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<PlayerRangeEditor> createState() => _PlayerRangeEditorState();
}

class _PlayerRangeEditorState extends State<PlayerRangeEditor> {
  late String _position;
  late Set<int> _cells;
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _position = widget.position;
    _cells = Set<int>.from(widget.selectedCells);
  }

  Map<String, List<GtoPreset>> get _presetsByCategory => gtoPresetsByCategory;

  void _applyPreset(String key) {
    final preset = gtoPresets.firstWhere((p) => p.key == key);
    setState(() {
      _selectedPreset = key;
      _cells = handSetToCells(preset.hands);
    });
  }

  void _clearAll() => setState(() => _cells = {});

  void _selectAll() {
    setState(() {
      _cells = {for (int r = 0; r < 13; r++) for (int c = 0; c < 13; c++) r * 13 + c};
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availablePositions = kPositions
        .where((p) => p == _position || !widget.takenPositions.contains(p))
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const Text('Edit Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (widget.onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        widget.onDelete!();
                        Navigator.pop(context);
                      },
                    ),
                  TextButton(
                    onPressed: () {
                      widget.onSave(_position, _cells);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scroll,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Position selector
                    Row(
                      children: [
                        const Text('Position:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        _DropdownContainer(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _position,
                              isDense: true,
                              items: availablePositions
                                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _position = v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // GTO preset selector
                    const Text('Load GTO Preset:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _DropdownContainer(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPreset,
                          isExpanded: true,
                          hint: const Text('Select preset...'),
                          items: [
                            for (final entry in _presetsByCategory.entries) ...[
                              DropdownMenuItem<String>(
                                value: '__header_${entry.key}',
                                enabled: false,
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              for (final preset in entry.value)
                                DropdownMenuItem<String>(
                                  value: preset.key,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text(preset.label),
                                  ),
                                ),
                            ]
                          ],
                          onChanged: (v) {
                            if (v != null && !v.startsWith('__header_')) _applyPreset(v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quick actions
                    Row(
                      children: [
                        TextButton(onPressed: _clearAll, child: const Text('Clear All')),
                        const SizedBox(width: 8),
                        TextButton(onPressed: _selectAll, child: const Text('Select All')),
                        const Spacer(),
                        RangeStats(selectedCells: _cells),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendDot(color: Colors.amber, label: 'Pairs'),
                        const SizedBox(width: 12),
                        _LegendDot(color: Colors.green.shade600, label: 'Suited'),
                        const SizedBox(width: 12),
                        _LegendDot(color: Colors.blue.shade600, label: 'Offsuit'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Matrix
                    RangeMatrix(
                      selectedCells: _cells,
                      onChanged: (cells) {
                        setState(() {
                          _cells = cells;
                          _selectedPreset = null; // custom
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DropdownContainer extends StatelessWidget {
  final Widget child;
  const _DropdownContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
