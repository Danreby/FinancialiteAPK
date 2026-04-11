import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/icon_utils.dart';

class FaturaItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const FaturaItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = item['title'] as String? ?? '';
    final installmentAmount =
        (item['installment_amount'] as num?)?.toDouble() ?? 0.0;
    final totalInstallments =
        (item['total_installments'] as num?)?.toInt() ?? 1;
    final displayInstallment =
        (item['display_installment'] as num?)?.toInt() ?? 1;
    final isRecurring = item['is_recurring'] == true;
    final status = item['status'] as String? ?? 'pending';
    final hasInstallments = totalInstallments > 1;
    final categoryIcon = item['category_icon'] as String?;
    final categoryColor = item['category_color'] as String?;
    final bankName = item['bank_name'] as String?;
    final iconColor = colorFromHex(categoryColor) ?? theme.colorScheme.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  Icon(iconFromName(categoryIcon), size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (hasInstallments)
                        _badge('$displayInstallment/$totalInstallments',
                            const Color(0xFF7C3AED)),
                      if (isRecurring)
                        _badge('Recorrente', const Color(0xFF3B82F6)),
                      _statusBadge(status, theme),
                      if (bankName != null)
                        Text(
                          bankName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '- ${CurrencyFormatter.format(installmentAmount)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _statusBadge(String status, ThemeData theme) {
    Color color;
    String label;
    switch (status) {
      case 'paid':
        color = const Color(0xFF10B981);
        label = 'Pago';
        break;
      case 'overdue':
        color = theme.colorScheme.error;
        label = 'Vencido';
        break;
      default:
        color = theme.colorScheme.onSurfaceVariant;
        label = 'Em aberto';
    }
    return _badge(label, color);
  }
}
