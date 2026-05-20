import 'package:flutter/material.dart';
import '../utils/helpers.dart';

const _labels = [
  'Very Tough — mostly regs, no recreational players',
  'Tough — more regs than recs, difficult spots',
  'Average — typical mix of regs and recreational players',
  'Soft — several recreational players, good spots',
  'Very Soft — mostly recreational players, highly profitable',
];

class StarRatingWidget extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const StarRatingWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Table Quality', style: theme.textTheme.bodyMedium),
            const SizedBox(width: 12),
            ...List.generate(5, (i) {
              final star = i + 1;
              final selected = value != null && star <= value!;
              return GestureDetector(
                onTap: () => onChanged(value == star ? null : star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    selected ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: selected ? Colors.amber : theme.colorScheme.outline,
                    size: 28,
                  ),
                ),
              );
            }),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(
                tableQualityLabel(value),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        if (value != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _labels[value! - 1],
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
      ],
    );
  }
}
