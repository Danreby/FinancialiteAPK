import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CreditDebitChart extends StatelessWidget {
  final double totalIn;
  final double totalOut;

  const CreditDebitChart({
    super.key,
    required this.totalIn,
    required this.totalOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = totalIn + totalOut;
    final pctIn = totalIn / total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 20,
                sections: [
                  PieChartSectionData(
                    value: totalIn,
                    color: const Color(0xFF7C3AED),
                    radius: 12,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: totalOut,
                    color: theme.colorScheme.error,
                    radius: 12,
                    title: '',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chartLegend(
                    'Crédito', pctIn * 100, const Color(0xFF7C3AED), theme),
                const SizedBox(height: 6),
                _chartLegend('Débito', (1 - pctIn) * 100,
                    theme.colorScheme.error, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, double pct, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
        const Spacer(),
        Text(
          '${pct.toStringAsFixed(1)}%',
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
