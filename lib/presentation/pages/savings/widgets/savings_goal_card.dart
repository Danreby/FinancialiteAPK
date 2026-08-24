import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_money_style.dart';
import '../../../../domain/entities/savings_goal.dart';
import '../../../widgets/ledger_row.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onLongPress,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final progressColor =
        progress >= 1.0 ? theme.appColors.success : theme.colorScheme.primary;
    final hasEmoji = goal.icon != null && goal.icon!.isNotEmpty;

    // Tap/long-press handled by one outer InkWell wrapping the whole entry
    // (header + progress bar + footer), since LedgerRow itself has no
    // onLongPress hook.
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: appColors.divider, width: 1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LedgerRow(
              title: goal.title,
              subtitle: goal.deadline != null
                  ? 'Prazo: ${DateFormatter.shortDate(goal.deadline!)}'
                  : null,
              // Emoji goals have no IconData to hand LedgerRow -- omit the
              // leading slot for those and keep the plain icon only for
              // goals without a custom emoji.
              leadingIcon: hasEmoji ? null : Icons.savings,
              leadingIconColor: progressColor,
              amount: goal.currentAmount,
              amountColor: progressColor,
              showDivider: false,
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                color: progressColor,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Meta: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AppMoneyStyle.rich(
                        amount: CurrencyFormatter.format(goal.targetAmount)
                            .replaceFirst(RegExp(r'R\$\s*'), ''),
                        style: AppMoneyStyle.small,
                        digitColor: theme.colorScheme.onSurfaceVariant,
                        symbolColor: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.edit_outlined,
                          size: 18, color: appColors.onSurfaceVariant),
                      onPressed: onEdit,
                      constraints:
                          const BoxConstraints(maxWidth: 32, maxHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
