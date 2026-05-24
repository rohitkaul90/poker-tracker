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
      default: return '';
    }
  }

  Color get _suitColor =>
      (_suit == 'h' || _suit == 'd') ? const Color(0xFFD32F2F) : const Color(0xFF1A1A1A);

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
          Positioned(
            top: 1,
            left: 2,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_displayRank,
                  style: TextStyle(
                      fontSize: width * 0.27,
                      fontWeight: FontWeight.bold,
                      color: _suitColor,
                      height: 1.1)),
              Text(_suitSymbol,
                  style: TextStyle(
                      fontSize: width * 0.22,
                      color: _suitColor,
                      height: 1.0)),
            ]),
          ),
          Center(
            child: Text(_suitSymbol,
                style: TextStyle(fontSize: width * 0.48, color: _suitColor)),
          ),
          Positioned(
            bottom: 1,
            right: 2,
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_displayRank,
                    style: TextStyle(
                        fontSize: width * 0.27,
                        fontWeight: FontWeight.bold,
                        color: _suitColor,
                        height: 1.1)),
                Text(_suitSymbol,
                    style: TextStyle(
                        fontSize: width * 0.22,
                        color: _suitColor,
                        height: 1.0)),
              ]),
            ),
          ),
        ]),
      );
}
