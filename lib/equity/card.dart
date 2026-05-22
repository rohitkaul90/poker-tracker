// Card encoding: index = rank * 4 + suit
// rank: 0=2, 1=3, ..., 12=A
// suit: 0=clubs, 1=diamonds, 2=hearts, 3=spades

const List<String> kRankChars = ['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'];
const List<String> kSuitChars = ['c', 'd', 'h', 's'];
const List<String> kSuitSymbols = ['♣', '♦', '♥', '♠'];

// Matrix display order: A=0, K=1, ..., 2=12
const List<String> kMatrixRanks = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'];

int cardIndex(int rank, int suit) => rank * 4 + suit;
int cardRank(int cardIdx) => cardIdx >> 2;
int cardSuit(int cardIdx) => cardIdx & 3;
int matrixIdxToRank(int matIdx) => 12 - matIdx;
int rankToMatrixIdx(int rank) => 12 - rank;

String cardName(int cardIdx) =>
    kRankChars[cardRank(cardIdx)] + kSuitChars[cardSuit(cardIdx)];

String cardRankChar(int cardIdx) => kRankChars[cardRank(cardIdx)];
String cardSuitSymbol(int cardIdx) => kSuitSymbols[cardSuit(cardIdx)];

// Parse "Ah" → card index, returns -1 on failure
int parseCard(String s) {
  if (s.length != 2) return -1;
  final r = kRankChars.indexOf(s[0].toUpperCase());
  if (r < 0) return -1;
  final suitMap = {'c': 0, 'd': 1, 'h': 2, 's': 3};
  final su = suitMap[s[1].toLowerCase()];
  if (su == null) return -1;
  return cardIndex(r, su);
}

// Hand notation → (row, col) in 13x13 matrix
// "AA" → (0,0), "AKs" → (0,1), "AKo" → (1,0)
(int, int) handToCell(String hand) {
  const ranks = kMatrixRanks;
  if (hand.length == 2) {
    final r = ranks.indexOf(hand[0]);
    return (r, r);
  }
  final r1 = ranks.indexOf(hand[0]);
  final r2 = ranks.indexOf(hand[1]);
  if (hand[2] == 's') return (r1, r2); // r1 < r2 (suited, upper triangle)
  return (r2, r1); // offsuit: row=lower rank (larger idx), col=higher rank (smaller idx)
}

String cellToHand(int row, int col) {
  if (row == col) return '${kMatrixRanks[row]}${kMatrixRanks[col]}';
  if (row < col) return '${kMatrixRanks[row]}${kMatrixRanks[col]}s';
  return '${kMatrixRanks[col]}${kMatrixRanks[row]}o';
}

// Expand a matrix cell to all concrete card-index pairs, excluding used cards
List<(int, int)> expandCell(int row, int col, {Set<int> exclude = const {}}) {
  final result = <(int, int)>[];
  if (row == col) {
    // Pair
    final r = matrixIdxToRank(row);
    for (int s1 = 0; s1 < 4; s1++) {
      for (int s2 = s1 + 1; s2 < 4; s2++) {
        final c1 = cardIndex(r, s1), c2 = cardIndex(r, s2);
        if (!exclude.contains(c1) && !exclude.contains(c2)) result.add((c1, c2));
      }
    }
  } else if (row < col) {
    // Suited: higher rank = matrixIdxToRank(row)
    final r1 = matrixIdxToRank(row), r2 = matrixIdxToRank(col);
    for (int s = 0; s < 4; s++) {
      final c1 = cardIndex(r1, s), c2 = cardIndex(r2, s);
      if (!exclude.contains(c1) && !exclude.contains(c2)) result.add((c1, c2));
    }
  } else {
    // Offsuit: higher rank = matrixIdxToRank(col) (smaller matrix idx)
    final r1 = matrixIdxToRank(col), r2 = matrixIdxToRank(row);
    for (int s1 = 0; s1 < 4; s1++) {
      for (int s2 = 0; s2 < 4; s2++) {
        if (s1 == s2) continue;
        final c1 = cardIndex(r1, s1), c2 = cardIndex(r2, s2);
        if (!exclude.contains(c1) && !exclude.contains(c2)) result.add((c1, c2));
      }
    }
  }
  return result;
}

// Total combos for a cell (no exclusions)
int cellComboCount(int row, int col) {
  if (row == col) return 6;
  if (row < col) return 4;
  return 12;
}
