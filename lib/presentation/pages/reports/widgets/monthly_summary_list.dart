import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/dashboard.dart';
import '../../../../core/theme/app_tokens.dart';

class MonthlySummaryList extends StatelessWidget {
  final List<MonthlyChartData> chart;

  const MonthlySummaryList({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = chart.reversed.take(6).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          final balance = d.income - d.expense;
          final isPositive = balance >= 0;
          return Column(
            children: [
              if (i > 0)
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormatter.monthYearFromKey(d.month),
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _miniTag(
                                  '+${CurrencyFormatter.formatCompact(d.income)}',
                                  const Color(0xFF10B981),
                                  theme),
                              const SizedBox(width: 6),
                              _miniTag(
                                  '-${CurrencyFormatter.formatCompact(d.expense)}',
                                  theme.colorScheme.error,
                                  theme),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPositive ? '+' : ''}${CurrencyFormatter.format(balance)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isPositive
                                ? const Color(0xFF10B981)
                                : theme.colorScheme.error,
                          ),
                        ),
                        Text(
                          'saldo do mês',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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

  Widget _miniTag(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
