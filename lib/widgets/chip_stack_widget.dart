import 'package:flutter/material.dart';

class ChipStack extends StatelessWidget {
  final int amount;
  final int bigBlind;
  final bool isAllIn;
  final double chipDiameter;

  const ChipStack({
    super.key,
    required this.amount,
    required this.bigBlind,
    this.isAllIn = false,
    this.chipDiameter = 22,
  });

  Color get _chipColor {
    if (isAllIn) return const Color(0xFFFFD700);
    if (bigBlind == 0) return Colors.white;
    final bbs = amount / bigBlind;
    if (bbs < 2) return Colors.white;
    if (bbs < 5) return const Color(0xFF1E88E5);
    if (bbs < 20) return const Color(0xFF43A047);
    if (bbs < 100) return const Color(0xFF424242);
    return const Color(0xFF7B1FA2);
  }

  int get _numChips {
    if (amount == 0) return 0;
    final bbs = bigBlind > 0 ? amount / bigBlind : 1.0;
    return (bbs.clamp(1, 7)).ceil().clamp(1, 7);
  }

  String _fmt(int v) =>
      v >= 1000 ? '\$${(v / 1000).toStringAsFixed(1)}k' : '\$$v';

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return const SizedBox.shrink();
    final n = _numChips;
    final c = _chipColor;
    final stackH = n * (chipDiameter * 0.42) + chipDiameter * 0.58;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: chipDiameter,
          height: stackH,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: List.generate(n, (i) {
              final isTop = i == n - 1;
              return Positioned(
                bottom: i * (chipDiameter * 0.42),
                child: Container(
                  width: chipDiameter,
                  height: chipDiameter * 0.58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTop ? c : c.withAlpha(160),
                    border: Border.all(color: Colors.white38, width: 0.8),
                    boxShadow: isAllIn
                        ? [
                            BoxShadow(
                                color: c.withAlpha(180),
                                blurRadius: 8,
                                spreadRadius: 2)
                          ]
                        : null,
                  ),
                  child: isTop && isAllIn
                      ? const Center(
                          child: Text('A',
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)))
                      : null,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            _fmt(amount),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isAllIn ? const Color(0xFFFFD700) : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
