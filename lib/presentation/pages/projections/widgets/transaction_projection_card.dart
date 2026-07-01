import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../../core/theme/app_tokens.dart';

class TransactionProjectionCard extends StatelessWidget {
  final Map<String, dynamic> tx;

  const TransactionProjectionCard({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecurring = tx['is_recurring'] as bool;
    final remaining = tx['remaining_installments'] as int?;
    final total = tx['total_installments'] as int;
    final amountPerMonth = (tx['amount_per_month'] as num).toDouble();
    final catColor = tx['category_color'] != null
        ? colorFromHex(tx['category_color'] as String)
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                isRecurring ? Icons.autorenew : Icons.credit_card,
                color: catColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx['title'] as String,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isRecurring
                        ? 'Recorrente \u00b7 ${tx['bank_name']}'
                        : remaining != null
                            ? '$remaining de $total parcelas restantes \u00b7 ${tx['bank_name']}'
                            : '$total parcelas \u00b7 ${tx['bank_name']}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(amountPerMonth),
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error),
                ),
                Text(
                  'por mês',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
