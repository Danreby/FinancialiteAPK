import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../domain/entities/dashboard.dart';

/// Compact "Próximas Contas" panel -- editorial-ledger style, no card, no
/// icon badges. Meant to sit side-by-side with [CategoriesPanel]; the two
/// have distinct internal layouts (rows-with-date vs. percentage bars) so
/// the pair doesn't read as the same list template twice.
class UpcomingBillsPanel extends StatelessWidget {
  final List<UpcomingBill> bills;
  final VoidCallback onSeeAll;

  const UpcomingBillsPanel({super.key, required this.bills, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return _Panel(
      title: 'Próximas',
      onAction: onSeeAll,
      child: Column(
        children: bills.take(3).map((bill) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: appColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  bill.dueDate != null
                      ? DateFormatter.shortDate(bill.dueDate!)
                      : 'Dia ${bill.dueDay}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: appColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Compact "Gastos por Categoria" panel: percentage bars only.
class CategoriesPanel extends StatelessWidget {
  final List<CategorySpending> categories;
  final double totalExpense;

  const CategoriesPanel({super.key, required this.categories, required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return _Panel(
      title: 'Categorias',
      child: Column(
        children: categories.take(3).map((cat) {
          final percent = totalExpense > 0 ? (cat.amount / totalExpense) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cat.name,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: appColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: appColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 2,
                    backgroundColor: appColors.divider,
                    valueColor: AlwaysStoppedAnimation(appColors.accent),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onAction;

  const _Panel({required this.title, required this.child, this.onAction});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: appColors.onSurfaceVariant,
              ),
            ),
            if (onAction != null)
              GestureDetector(
                onTap: onAction,
                child: Text(
                  'Ver',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: appColors.accent,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}
