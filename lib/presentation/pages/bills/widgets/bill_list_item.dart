import 'package:flutter/material.dart';
import '../../../../domain/entities/bill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../widgets/ledger_row.dart';

class BillListItem extends StatelessWidget {
  final Bill bill;
  final String dueLabel;
  final Color dueColor;
  final bool isPaid;
  final VoidCallback onTap;
  final Future<bool?> Function() onConfirmDismiss;
  final VoidCallback onDismissed;

  const BillListItem({
    super.key,
    required this.bill,
    required this.dueLabel,
    required this.dueColor,
    required this.isPaid,
    required this.onTap,
    required this.onConfirmDismiss,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    return Dismissible(
      key: Key('bill_${bill.id}'),
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
      child: LedgerRow(
        title: bill.title,
        subtitle: dueLabel,
        subtitleColor: dueColor,
        leadingIcon:
            isPaid ? Icons.check_circle_rounded : Icons.receipt_rounded,
        leadingIconColor: dueColor,
        amount: bill.amount,
        amountColor: isPaid ? appColors.success : dueColor,
        onTap: isPaid ? null : onTap,
      ),
    );
  }
}
