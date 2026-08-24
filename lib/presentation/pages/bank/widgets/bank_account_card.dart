import 'package:flutter/material.dart';
import '../../../../domain/entities/bank_account.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/ledger_row.dart';

class BankAccountCard extends StatelessWidget {
  final BankAccount account;
  final Future<bool?> Function() onConfirmDismiss;
  final VoidCallback onDismissed;
  final VoidCallback? onEdit;

  const BankAccountCard({
    super.key,
    required this.account,
    required this.onConfirmDismiss,
    required this.onDismissed,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    return Dismissible(
      key: Key('bank_${account.id}'),
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
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: appColors.divider, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: LedgerRow(
                title: account.displayName,
                subtitle: _typeLabel(account.accountType ?? 'corrente'),
                leadingIcon: Icons.account_balance_rounded,
                leadingIconColor: theme.colorScheme.primary,
                amount: account.balance,
                amountColor: account.balance >= 0
                    ? appColors.income
                    : theme.colorScheme.error,
                showDivider: false,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: appColors.onSurfaceVariant),
              onPressed: onEdit,
              constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'corrente':
        return 'Conta Corrente';
      case 'poupanca':
        return 'Poupança';
      case 'investimento':
        return 'Investimento';
      case 'carteira':
        return 'Carteira';
      default:
        return type;
    }
  }
}
