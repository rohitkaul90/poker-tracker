import 'package:flutter/material.dart';

// ── Archetype tags (large toggle buttons, mutually exclusive-ish) ──────────
const Map<String, String> kArchetypeTags = {
  'fish': 'Fish',
  'nit': 'Nit',
  'tag_player': 'TAG',
  'lag_player': 'LAG',
  'calling_station': 'Calling Station',
  'maniac': 'Maniac',
  'tricky': 'Tricky/GTO',
};

// ── Tendency tags (smaller chips, grouped) ─────────────────────────────────
const Map<String, Map<String, String>> kTendencyGroups = {
  'Preflop': {
    'limps': 'Limps',
    'opens_wide': 'Opens Wide',
    'opens_tight': 'Opens Tight',
    'three_bets_light': '3-Bets Light',
    'folds_3bet': 'Folds to 3-Bet',
    'cold_calls': 'Cold Calls',
  },
  'Postflop': {
    'c_bets_always': 'C-Bets Always',
    'check_folds': 'Check-Folds',
    'over_bluffs': 'Over-Bluffs',
    'slow_plays': 'Slow-Plays',
    'value_heavy': 'Value-Heavy',
    'check_raises': 'Check-Raises',
  },
};

String tagDisplayName(String tag) {
  if (kArchetypeTags.containsKey(tag)) { return kArchetypeTags[tag]!; }
  for (final group in kTendencyGroups.values) {
    if (group.containsKey(tag)) { return group[tag]!; }
  }
  return tag;
}

Color tagColor(String tag) {
  switch (tag) {
    case 'fish':
      return Colors.orange;
    case 'calling_station':
      return Colors.orange.shade700;
    case 'nit':
      return Colors.blueGrey;
    case 'tag_player':
      return Colors.green;
    case 'lag_player':
      return Colors.red;
    case 'maniac':
      return Colors.red.shade900;
    case 'tricky':
      return Colors.purple;
    default:
      return Colors.teal;
  }
}

bool isArchetype(String tag) => kArchetypeTags.containsKey(tag);
