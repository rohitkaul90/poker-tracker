import 'package:flutter/material.dart';

class PlayingCard extends StatelessWidget {
  final String? card; // e.g. 'Ah', 'Kd', null = face-down
  final double width;
  final double height;

  const PlayingCard({super.key, this.card, this.width = 36, this.height = 50});

  String get _rank => (card != null && card!.length >= 2)
      ? card![0].toUpperCase()
      : '';
  String get _suit => (card != null && card!.length >= 2)
      ? card![card!.length - 1].toLowerCase()
      : '';

  String get _suitSymbol {
    switch (_suit) {
      case 'h': return '♥';
      case 'd': return '♦';
      case 'c': return '♣';
      case 's': return '♠';
      default:  return '';
    }
  }

  Color get _suitColor =>
      (_suit == 'h' || _suit == 'd')
          ? const Color(0xFFD32F2F)
          : const Color(0xFF1A1A1A);

  String get _displayRank => _rank == 'T' ? '10' : _rank;

  @override
  Widget build(BuildContext context) =>
      card == null ? _faceDown() : _faceUp();

  Widget _faceDown() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
          border: Border.all(color: Colors.white24, width: 0.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 3,
                offset: const Offset(1, 1))
          ],
        ),
        child: Center(
          child: Icon(Icons.grid_4x4,
              color: Colors.white24, size: width * 0.4),
        ),
      );

  // Two-corner design — no large center suit symbol.
  // Removing the center element eliminates the three-symbol overlap that
  // causes blotting on high-DPR Android displays.
  Widget _faceUp() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 3,
                offset: const Offset(1, 1))
          ],
        ),
        child: Stack(children: [
          Positioned(top: 1, left: 2, child: _cornerLabel()),
          Positioned(
            bottom: 1,
            right: 2,
            child: Transform.rotate(
              angle: 3.14159,
              child: _cornerLabel(),
            ),
          ),
        ]),
      );

  Widget _cornerLabel() {
    final rankSize = (width * 0.32).clamp(5.0, 22.0);
    final suitSize = (width * 0.26).clamp(4.0, 18.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _displayRank,
          style: TextStyle(
              fontSize: rankSize,
              fontWeight: FontWeight.bold,
              color: _suitColor,
              height: 1.1),
        ),
        Text(
          _suitSymbol,
          style: TextStyle(
              fontSize: suitSize,
              color: _suitColor,
              height: 1.0),
        ),
      ],
    );
  }
}
