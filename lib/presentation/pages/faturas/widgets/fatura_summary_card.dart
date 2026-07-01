import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_tokens.dart';

class FaturaSummaryCard extends StatelessWidget {
  final double totalSpent;
  final double totalPaid;
  final bool isPaid;
  final bool isPartiallyPaid;
  final int paidItems;
  final int totalItems;

  const FaturaSummaryCard({
    super.key,
    required this.totalSpent,
    required this.totalPaid,
    required this.isPaid,
    required this.isPartiallyPaid,
    required this.paidItems,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isPaid ? const Color(0xFF10B981) : theme.colorScheme.error,
              (isPaid ? const Color(0xFF10B981) : theme.colorScheme.error)
                  .withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child:
                  const Icon(Icons.credit_card, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total do Mes',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    CurrencyFormatter.format(totalSpent),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isPartiallyPaid || (totalPaid > 0 && !isPaid))
                    Text(
                      'Pago: ${CurrencyFormatter.format(totalPaid)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$paidItems/$totalItems',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'pagas',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
