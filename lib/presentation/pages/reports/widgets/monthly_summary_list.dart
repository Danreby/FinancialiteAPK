import 'package:flutter/material.dart';
import '../../../../core/theme/app_money_style.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/dashboard.dart';
import '../../../../core/theme/app_theme.dart';

/// Editorial-ledger month row: month label + income/expense mini-figures on
/// the left, net balance on the right, separated by a hairline divider --
/// no card box, no shadow, mirrors [LedgerRow] but needs two money figures
/// on the left side so it's kept local to this file.
class MonthlySummaryList extends StatelessWidget {
  final List<MonthlyChartData> chart;

  const MonthlySummaryList({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    final items = chart.reversed.take(6).toList();

    return Column(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final d = entry.value;
        final balance = d.income - d.expense;
        final isPositive = balance >= 0;
        final isLast = i == items.length - 1;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: appColors.divider, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.monthYearFromKey(d.month),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: appColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '+${CurrencyFormatter.formatCompact(d.income)}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: appColors.income,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '-${CurrencyFormatter.formatCompact(d.expense)}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: appColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    AppMoneyStyle.rich(
                      amount: CurrencyFormatter.toInputFormat(balance.abs()),
                      style: AppMoneyStyle.small,
                      digitColor: isPositive ? appColors.income : appColors.expense,
                      symbolColor:
                          (isPositive ? appColors.income : appColors.expense)
                              .withValues(alpha: 0.7),
                      sign: isPositive ? '+' : '-',
                    ),
                  ),
                  Text(
                    'saldo do mês',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: appColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
