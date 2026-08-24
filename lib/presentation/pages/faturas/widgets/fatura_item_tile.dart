import 'package:flutter/material.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/ledger_row.dart';

class FaturaItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const FaturaItemTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
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
    final iconColor = colorFromHex(categoryColor);
    final iconData =
        iconDataForCategoryIcon(categoryIcon) ?? iconFromName(categoryIcon);

    // Fold the status/installment/recurring badges and bank name into a
    // single subtitle line -- LedgerRow has no room for a badge Wrap.
    final subtitleParts = <String>[
      _statusLabel(status),
      if (hasInstallments) '$displayInstallment/$totalInstallments',
      if (isRecurring) 'Recorrente',
      if (bankName != null) bankName,
    ];

    return LedgerRow(
      title: title,
      subtitle: subtitleParts.join(' • '),
      subtitleColor: _statusColor(status, appColors),
      leadingIcon: iconData,
      leadingIconColor: iconColor,
      amount: installmentAmount,
      amountSign: '-',
      amountColor: Theme.of(context).colorScheme.error,
      onTap: onTap,
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'Pago';
      case 'overdue':
        return 'Vencido';
      default:
        return 'Em aberto';
    }
  }

  Color _statusColor(String status, ThemeColors appColors) {
    switch (status) {
      case 'paid':
        return appColors.success;
      case 'overdue':
        return appColors.error;
      default:
        return appColors.onSurfaceVariant;
    }
  }
}
