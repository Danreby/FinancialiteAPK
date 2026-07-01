import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../domain/entities/dashboard.dart';

class UpcomingBillsSection extends StatelessWidget {
  final List<UpcomingBill> bills;

  const UpcomingBillsSection({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: bills
          .take(4)
          .map((bill) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _dueLabel(bill),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _dueColor(theme, bill),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(bill.amount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  String _dueLabel(UpcomingBill bill) {
    if (bill.dueDate != null) {
      return 'Vence ${DateFormatter.shortDate(bill.dueDate!)}';
    }
    return 'Vence dia ${bill.dueDay}';
  }

  Color _dueColor(ThemeData theme, UpcomingBill bill) {
    if (bill.status == 'overdue') return theme.colorScheme.error;
    if (bill.status == 'paid') return theme.colorScheme.primary;
    return theme.colorScheme.onSurfaceVariant;
  }
}
