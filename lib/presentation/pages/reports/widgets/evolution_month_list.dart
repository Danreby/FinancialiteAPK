import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_tokens.dart';

class EvolutionMonthList extends StatelessWidget {
  final List<dynamic> chart;
  final List<double> points;

  const EvolutionMonthList({
    super.key,
    required this.chart,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: chart
            .asMap()
            .entries
            .toList()
            .reversed
            .take(6)
            .toList()
            .asMap()
            .entries
            .map((outerEntry) {
          final idx = outerEntry.value.key;
          final d = outerEntry.value.value;
          final bal = points[idx];
          final isPositive = bal >= 0;
          final isFirst = outerEntry.key == 0;
          return Column(
            children: [
              if (!isFirst)
                Divider(
                    height: 1,
                    indent: 16,
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.3)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isPositive
                                ? const Color(0xFF10B981)
                                : theme.colorScheme.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 20,
                        color: isPositive
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormatter.monthYearFromKey(d.month),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(bal),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isPositive
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
