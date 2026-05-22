// GTO range presets for 9-max NL Hold'em.
// Each range is a Set<String> of hand notations ("AA", "AKs", "AKo").

class GtoPreset {
  final String key;
  final String label;
  final String category; // e.g. 'Cash RFI', 'Cash 3-bet', 'Tournament RFI'
  final Set<String> hands;

  const GtoPreset({
    required this.key,
    required this.label,
    required this.category,
    required this.hands,
  });
}

final List<GtoPreset> gtoPresets = [
  // ─── Cash Game RFI (100BB, 9-max) ───────────────────────────────────────
  GtoPreset(
    key: 'cash_rfi_utg',
    label: 'UTG Open',
    category: 'Cash RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT',
      'AKs', 'AQs', 'AJs', 'ATs', 'KQs', 'KJs',
      'AKo', 'AQo',
    },
  ),
  GtoPreset(
    key: 'cash_rfi_utg1',
    label: 'UTG+1 Open',
    category: 'Cash RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'KQs', 'KJs', 'QJs',
      'AKo', 'AQo', 'AJo',
    },
  ),
  GtoPreset(
    key: 'cash_rfi_utg2',
    label: 'UTG+2 Open',
    category: 'Cash RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s',
      'KQs', 'KJs', 'KTs', 'QJs', 'JTs',
      'AKo', 'AQo', 'AJo', 'KQo',
    },
  ),
  GtoPreset(
    key: 'cash_rfi_mp',
    label: 'MP Open',
    category: 'Cash RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s',
      'KQs', 'KJs', 'KTs', 'QJs', 'QTs', 'JTs', 'T9s',
      'AKo', 'AQo', 'AJo', 'ATo', 'KQo', 'KJo',
    },
  ),
  GtoPreset(
    key: 'cash_rfi_hj',
    label: 'HJ Open',
    category: 'Cash RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s',
      'KQs', 'KJs', 'KTs', 'K9s',
      'QJs', 'QTs', 'Q9s', 'JTs', 'J9s', 'T9s', '98s', '87s',
      'AKo', 'AQo', 'AJo', 'ATo', 'A9o', 'KQo', 'KJo', 'KTo', 'QJo',
    },
  ),
  GtoPreset(
    key: 'cash_rfi_co',
    label: 'CO Open',
    category: 'Cash RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s',
      'KQs', 'KJs', 'KTs', 'K9s', 'K8s',
      'QJs', 'QTs', 'Q9s', 'JTs', 'J9s', 'J8s',
      'T9s', 'T8s', '98s', '97s', '87s', '76s', '65s',
      'AKo', 'AQo', 'AJo', 'ATo', 'A9o', 'A8o',
      'KQo', 'KJo', 'KTo', 'QJo', 'QTo', 'JTo',
    },
  ),
  GtoPreset(
    key: 'cash_rfi_btn',
    label: 'BTN Open',
    category: 'Cash RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55', '44', '33', '22',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s', 'A3s', 'A2s',
      'KQs', 'KJs', 'KTs', 'K9s', 'K8s', 'K7s', 'K6s', 'K5s',
      'QJs', 'QTs', 'Q9s', 'Q8s', 'Q7s',
      'JTs', 'J9s', 'J8s', 'J7s',
      'T9s', 'T8s', 'T7s',
      '98s', '97s', '96s', '87s', '86s', '85s',
      '76s', '75s', '74s', '65s', '64s', '63s',
      '54s', '53s', '52s', '43s',
      'AKo', 'AQo', 'AJo', 'ATo', 'A9o', 'A8o', 'A7o', 'A6o', 'A5o', 'A4o',
      'KQo', 'KJo', 'KTo', 'K9o', 'K8o',
      'QJo', 'QTo', 'Q9o',
      'JTo', 'J9o', 'T9o', 'T8o', '98o', '87o', '76o',
    },
  ),
  GtoPreset(
    key: 'cash_rfi_sb',
    label: 'SB Open',
    category: 'Cash RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55', '44', '33', '22',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s', 'A3s', 'A2s',
      'KQs', 'KJs', 'KTs', 'K9s', 'K8s', 'K7s', 'K6s',
      'QJs', 'QTs', 'Q9s', 'Q8s',
      'JTs', 'J9s', 'J8s',
      'T9s', 'T8s', 'T7s', '98s', '97s', '96s',
      '87s', '86s', '85s', '76s', '75s', '65s', '54s',
      'AKo', 'AQo', 'AJo', 'ATo', 'A9o', 'A8o', 'A7o', 'A6o', 'A5o',
      'KQo', 'KJo', 'KTo', 'K9o',
      'QJo', 'JTo', 'T9o', '98o',
    },
  ),

  // ─── Cash Game 3-Bet Ranges (100BB) ──────────────────────────────────────
  GtoPreset(
    key: 'cash_3b_bb_vs_btn',
    label: 'BB 3-bet vs BTN',
    category: 'Cash 3-bet',
    hands: {
      'AA', 'KK', 'QQ', 'JJ',
      'AKs', 'AQs', 'AJs', 'ATs',
      'A5s', 'A4s', 'A3s', 'A2s',
      'KQs', 'QJs', 'JTs', 'T9s', '98s',
      'AKo', 'AQo',
    },
  ),
  GtoPreset(
    key: 'cash_3b_bb_vs_co',
    label: 'BB 3-bet vs CO',
    category: 'Cash 3-bet',
    hands: {
      'AA', 'KK', 'QQ', 'JJ',
      'AKs', 'AQs', 'AJs',
      'A5s', 'A4s', 'A3s',
      'KQs', 'QJs', 'JTs',
      'AKo', 'AQo',
    },
  ),
  GtoPreset(
    key: 'cash_3b_bb_vs_utg',
    label: 'BB 3-bet vs UTG',
    category: 'Cash 3-bet',
    hands: {
      'AA', 'KK', 'QQ',
      'AKs', 'AQs',
      'A5s', 'A4s',
      'AKo',
    },
  ),
  GtoPreset(
    key: 'cash_3b_btn_vs_co',
    label: 'BTN 3-bet vs CO',
    category: 'Cash 3-bet',
    hands: {
      'AA', 'KK', 'QQ', 'JJ',
      'AKs', 'AQs', 'AJs',
      'A5s', 'A4s', 'A3s',
      'KQs', 'JTs',
      'AKo', 'AQo',
    },
  ),
  GtoPreset(
    key: 'cash_3b_co_vs_hj',
    label: 'CO 3-bet vs HJ',
    category: 'Cash 3-bet',
    hands: {
      'AA', 'KK', 'QQ',
      'AKs', 'AQs', 'AJs',
      'A5s', 'A4s',
      'KQs',
      'AKo', 'AQo',
    },
  ),
  GtoPreset(
    key: 'cash_3b_sb_vs_btn',
    label: 'SB 3-bet vs BTN',
    category: 'Cash 3-bet',
    hands: {
      'AA', 'KK', 'QQ', 'JJ',
      'AKs', 'AQs', 'AJs', 'ATs',
      'A5s', 'A4s', 'A3s', 'A2s',
      'KQs', 'QJs', 'JTs',
      'AKo', 'AQo',
    },
  ),

  // ─── Cash Game Calling Ranges (BB defense) ──────────────────────────────
  GtoPreset(
    key: 'cash_call_bb_vs_btn',
    label: 'BB Call vs BTN',
    category: 'Cash Call',
    hands: {
      '22', '33', '44', '55', '66', '77', '88',
      'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s', 'A3s', 'A2s',
      'KTs', 'K9s', 'K8s', 'K7s', 'K6s', 'K5s', 'K4s', 'K3s', 'K2s',
      'QTs', 'Q9s', 'Q8s', 'Q7s', 'Q6s',
      'JTs', 'J9s', 'J8s', 'J7s',
      'T8s', 'T7s', '97s', '96s', '86s', '85s',
      '75s', '74s', '64s', '63s', '53s', '52s', '43s',
      'ATo', 'A9o', 'A8o', 'A7o',
      'KJo', 'KTo', 'K9o',
      'QJo', 'QTo', 'JTo',
    },
  ),
  GtoPreset(
    key: 'cash_call_bb_vs_co',
    label: 'BB Call vs CO',
    category: 'Cash Call',
    hands: {
      '22', '33', '44', '55', '66', '77',
      'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s', 'A3s', 'A2s',
      'K9s', 'K8s', 'K7s', 'K6s', 'K5s', 'K4s',
      'QTs', 'Q9s', 'Q8s', 'Q7s',
      'JTs', 'J9s', 'J8s',
      'T8s', 'T7s', '97s', '96s', '86s', '85s', '75s', '64s', '53s', '43s',
      'AJo', 'ATo', 'A9o',
      'KJo', 'KTo',
      'QJo', 'JTo',
    },
  ),
  GtoPreset(
    key: 'cash_call_bb_vs_utg',
    label: 'BB Call vs UTG',
    category: 'Cash Call',
    hands: {
      '22', '33', '44', '55', '66',
      'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s', 'A3s', 'A2s',
      'K9s', 'K8s', 'K7s',
      'QTs', 'Q9s', 'JTs', 'J9s', 'T9s', 'T8s',
      '98s', '87s', '76s', '65s', '54s',
      'AJo', 'ATo',
      'KQo', 'KJo',
      'QJo',
    },
  ),
  GtoPreset(
    key: 'cash_call_btn_vs_co',
    label: 'BTN Call vs CO',
    category: 'Cash Call',
    hands: {
      '88', '99', 'TT',
      'A9s', 'A8s', 'A7s', 'A6s', 'A5s',
      'KTs', 'K9s',
      'QTs', 'Q9s', 'JTs', 'J9s',
      'T9s', 'T8s', '98s', '97s', '87s', '86s', '76s', '65s',
      'AJo',
      'KQo', 'KJo',
      'QJo',
    },
  ),

  // ─── Tournament RFI (100BB, 9-max, slightly tighter) ────────────────────
  GtoPreset(
    key: 'trn_rfi_utg',
    label: 'UTG Open',
    category: 'Tournament RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ',
      'AKs', 'AQs', 'AJs', 'ATs', 'KQs',
      'AKo', 'AQo',
    },
  ),
  GtoPreset(
    key: 'trn_rfi_utg1',
    label: 'UTG+1 Open',
    category: 'Tournament RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT',
      'AKs', 'AQs', 'AJs', 'ATs', 'KQs', 'KJs', 'QJs',
      'AKo', 'AQo', 'AJo',
    },
  ),
  GtoPreset(
    key: 'trn_rfi_utg2',
    label: 'UTG+2 Open',
    category: 'Tournament RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'KQs', 'KJs', 'KTs', 'QJs', 'JTs',
      'AKo', 'AQo', 'AJo', 'KQo',
    },
  ),
  GtoPreset(
    key: 'trn_rfi_mp',
    label: 'MP Open',
    category: 'Tournament RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s',
      'KQs', 'KJs', 'KTs', 'QJs', 'JTs', 'T9s',
      'AKo', 'AQo', 'AJo', 'ATo', 'KQo',
    },
  ),
  GtoPreset(
    key: 'trn_rfi_hj',
    label: 'HJ Open',
    category: 'Tournament RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s',
      'KQs', 'KJs', 'KTs', 'K9s',
      'QJs', 'QTs', 'JTs', 'J9s', 'T9s', '98s', '87s',
      'AKo', 'AQo', 'AJo', 'ATo', 'A9o', 'KQo', 'KJo', 'QJo',
    },
  ),
  GtoPreset(
    key: 'trn_rfi_co',
    label: 'CO Open',
    category: 'Tournament RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s',
      'KQs', 'KJs', 'KTs', 'K9s', 'K8s',
      'QJs', 'QTs', 'Q9s', 'JTs', 'J9s', 'T9s', 'T8s', '98s', '87s', '76s',
      'AKo', 'AQo', 'AJo', 'ATo', 'A9o', 'A8o',
      'KQo', 'KJo', 'KTo', 'QJo', 'JTo',
    },
  ),
  GtoPreset(
    key: 'trn_rfi_btn',
    label: 'BTN Open',
    category: 'Tournament RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55', '44', '33', '22',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s', 'A3s', 'A2s',
      'KQs', 'KJs', 'KTs', 'K9s', 'K8s', 'K7s', 'K6s',
      'QJs', 'QTs', 'Q9s', 'Q8s', 'Q7s',
      'JTs', 'J9s', 'J8s', 'T9s', 'T8s', 'T7s',
      '98s', '97s', '87s', '86s', '76s', '75s', '65s', '54s',
      'AKo', 'AQo', 'AJo', 'ATo', 'A9o', 'A8o', 'A7o', 'A6o', 'A5o',
      'KQo', 'KJo', 'KTo', 'K9o', 'K8o',
      'QJo', 'QTo', 'Q9o', 'JTo', 'T9o', '98o', '87o', '76o',
    },
  ),
  GtoPreset(
    key: 'trn_rfi_sb',
    label: 'SB Open',
    category: 'Tournament RFI',
    hands: {
      'AA', 'KK', 'QQ', 'JJ', 'TT', '99', '88', '77', '66', '55', '44', '33', '22',
      'AKs', 'AQs', 'AJs', 'ATs', 'A9s', 'A8s', 'A7s', 'A6s', 'A5s', 'A4s', 'A3s', 'A2s',
      'KQs', 'KJs', 'KTs', 'K9s', 'K8s', 'K7s',
      'QJs', 'QTs', 'Q9s', 'Q8s',
      'JTs', 'J9s', 'J8s', 'T9s', 'T8s', '98s', '97s', '87s', '76s', '65s', '54s',
      'AKo', 'AQo', 'AJo', 'ATo', 'A9o', 'A8o', 'A7o', 'A6o',
      'KQo', 'KJo', 'KTo', 'K9o',
      'QJo', 'JTo', 'T9o', '98o',
    },
  ),

  // ─── Tournament 3-bet ────────────────────────────────────────────────────
  GtoPreset(
    key: 'trn_3b_bb_vs_btn',
    label: 'BB 3-bet vs BTN',
    category: 'Tournament 3-bet',
    hands: {
      'AA', 'KK', 'QQ', 'JJ',
      'AKs', 'AQs', 'AJs',
      'A5s', 'A4s', 'A3s',
      'KQs', 'QJs', 'JTs',
      'AKo', 'AQo',
    },
  ),
  GtoPreset(
    key: 'trn_3b_btn_vs_co',
    label: 'BTN 3-bet vs CO',
    category: 'Tournament 3-bet',
    hands: {
      'AA', 'KK', 'QQ', 'JJ',
      'AKs', 'AQs', 'AJs',
      'A5s', 'A4s',
      'KQs',
      'AKo', 'AQo',
    },
  ),
];

// Group presets by category
Map<String, List<GtoPreset>> get gtoPresetsByCategory {
  final map = <String, List<GtoPreset>>{};
  for (final preset in gtoPresets) {
    map.putIfAbsent(preset.category, () => []).add(preset);
  }
  return map;
}

// Convert a preset's hand set to a Set of matrix cell keys (row * 13 + col)
Set<int> handSetToCells(Set<String> hands) {
  final cells = <int>{};
  for (final hand in hands) {
    final cell = _handToCell(hand);
    if (cell != null) cells.add(cell.$1 * 13 + cell.$2);
  }
  return cells;
}

(int, int)? _handToCell(String hand) {
  const ranks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];
  if (hand.length == 2) {
    final r = ranks.indexOf(hand[0]);
    if (r < 0) return null;
    return (r, r);
  }
  if (hand.length != 3) return null;
  final r1 = ranks.indexOf(hand[0]);
  final r2 = ranks.indexOf(hand[1]);
  if (r1 < 0 || r2 < 0) return null;
  if (hand[2] == 's') return (r1, r2);
  return (r2, r1); // offsuit: row=lower-rank idx (higher number), col=higher-rank idx (lower number)
}
