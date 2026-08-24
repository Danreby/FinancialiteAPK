import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/icon_utils.dart';
import '../../core/utils/category_icons.dart';
import 'ledger_row.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool isExpense;
  final IconData categoryIcon;

  /// The category's raw stored icon key (e.g. 'piggy'). When set, takes
  /// priority over [categoryIcon] and renders via [CategoryIconGlyph] so
  /// this tile shows the same glyph financialite (web) would for the same
  /// category -- [categoryIcon] remains as a plain-IconData fallback for
  /// callers that don't have a real category (e.g. a generic list row).
  final String? categoryIconName;
  final Color? categoryColor;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isExpense,
    this.categoryIcon = Icons.swap_horiz_rounded,
    this.categoryIconName,
    this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    final amountColor = isExpense ? appColors.expense : appColors.income;
    final iconColor = categoryColor ?? amountColor;

    return LedgerRow(
      title: title,
      subtitle: subtitle,
      leadingIcon: categoryIconName != null
          ? (iconDataForCategoryIcon(categoryIconName) ??
              iconFromName(categoryIconName))
          : categoryIcon,
      leadingIconColor: iconColor,
      amount: CurrencyFormatter.parse(amount),
      amountSign: isExpense ? '-' : '+',
      amountColor: amountColor,
      onTap: onTap,
    );
  }
}
