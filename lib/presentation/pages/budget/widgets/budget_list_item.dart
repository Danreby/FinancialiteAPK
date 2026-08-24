import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_money_style.dart';
import '../../../../domain/entities/budget.dart';
import '../../../widgets/ledger_row.dart';

class BudgetListItem extends StatelessWidget {
  final Budget budget;
  final Future<bool?> Function() onConfirmDismiss;
  final VoidCallback onDismissed;

  const BudgetListItem({
    super.key,
    required this.budget,
    required this.onConfirmDismiss,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    final spent = budget.totalSpent ?? 0;
    final progress = budget.monthlyLimit > 0
        ? (spent / budget.monthlyLimit).clamp(0.0, 1.0)
        : 0.0;
    final isOver = spent > budget.monthlyLimit;
    final progressColor =
        isOver ? theme.colorScheme.error : theme.colorScheme.primary;

    return Dismissible(
      key: Key('budget_${budget.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => onConfirmDismiss(),
      onDismissed: (_) => onDismissed(),
      // Whole entry (header + progress bar + gasto/limite + chips) is wrapped
      // in a single hairline-bottom-bordered block so it reads as one
      // coherent ledger line, not a floating disconnected progress bar.
      child: Container(
        padding: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: appColors.divider, width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LedgerRow(
              title: 'Orçamento ${budget.monthYear}',
              subtitle: isOver ? 'Limite excedido' : 'Dentro do limite',
              subtitleColor: isOver ? theme.colorScheme.error : null,
              trailingText: '${(progress * 100).toStringAsFixed(0)}%',
              trailingTextColor: progressColor,
              showDivider: false,
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: progressColor,
                backgroundColor: progressColor.withValues(alpha: 0.12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Gasto: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppMoneyStyle.rich(
                        amount: CurrencyFormatter.format(spent)
                            .replaceFirst(RegExp(r'R\$\s*'), ''),
                        style: AppMoneyStyle.small,
                        digitColor: theme.colorScheme.onSurfaceVariant,
                        symbolColor: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Limite: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppMoneyStyle.rich(
                        amount: CurrencyFormatter.format(budget.monthlyLimit)
                            .replaceFirst(RegExp(r'R\$\s*'), ''),
                        style: AppMoneyStyle.small,
                        digitColor: theme.colorScheme.onSurfaceVariant,
                        symbolColor: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((budget.categories ?? []).isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (budget.categories ?? [])
                    .map((c) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            c.categoryName ?? '',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
