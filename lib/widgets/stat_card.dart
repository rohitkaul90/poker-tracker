import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? theme.colorScheme.primary;

    return Card(
      color: accent.withAlpha(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          // Scale fonts proportionally to card height, clamped for min/max legibility.
          final valueFontSize = (h * 0.35).clamp(18.0, 42.0);
          final labelFontSize = (h * 0.17).clamp(10.0, 15.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: h * 0.05),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
