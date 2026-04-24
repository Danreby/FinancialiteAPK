import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/bill/bill_cubit.dart';
import '../../../domain/entities/bill.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/section_header.dart';
import '../../widgets/page_header.dart';
import '../../widgets/shadowed_fab.dart';
import '../../widgets/responsive_content.dart';
import '../../../core/utils/date_formatter.dart';
import 'widgets/bill_dialogs.dart';
import 'widgets/bill_list_item.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<BillCubit>().loadBills();
  }

  DateTime _nextDueDate(int dueDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final clampedDay = dueDay > daysInMonth ? daysInMonth : dueDay;
    final thisMonth = DateTime(now.year, now.month, clampedDay);
    if (thisMonth.isAfter(today) || thisMonth.isAtSameMomentAs(today)) {
      return thisMonth;
    }
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final daysInNextMonth =
        DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    final clampedNext = dueDay > daysInNextMonth ? daysInNextMonth : dueDay;
    return DateTime(nextMonth.year, nextMonth.month, clampedNext);
  }

  bool _isPaidThisCycle(Bill bill) {
    if (bill.isPaidThisPeriod) return true;
    final lp = bill.lastPayment;
    if (lp == null || lp.status != 'paid') return false;
    final now = DateTime.now();
    final dueDate = lp.dueDate;
    if (dueDate == null) return false;
    return dueDate.year == now.year && dueDate.month == now.month;
  }

  DateTime _effectiveDueDate(Bill bill) {
    return bill.nextDueDate ?? _nextDueDate(bill.dueDay);
  }

  (String, Color) _dueInfo(Bill bill, ThemeData theme) {
    final dueDate = _effectiveDueDate(bill);
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final diff = dueDate.difference(today).inDays;

    if (_isPaidThisCycle(bill)) {
      return ('Pago · próx. ${DateFormatter.shortDate(dueDate)}', Colors.green);
    }

    if (diff < 0) {
      return ('Vencido há ${-diff}d', theme.colorScheme.error);
    } else if (diff == 0) {
      return ('Vence hoje', theme.colorScheme.error);
    } else if (diff == 1) {
      return ('Vence amanhã', Colors.orange);
    } else if (diff <= 7) {
      return ('Vence em ${diff}d', Colors.orange);
    } else {
      return ('Vence em ${diff}d', theme.colorScheme.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton:
          ShadowedFab(onPressed: () => showBillCreateDialog(context)),
      body: Column(
        children: [
          const PageHeader(title: 'Contas a Pagar', bottomPadding: 16),
          const SizedBox(height: 12),
          Expanded(
            child: ResponsiveContent(
              child: BlocBuilder<BillCubit, BillState>(
                builder: (context, state) {
                  if (state is BillLoading) {
                    return const AppLoadingIndicator(
                        useShimmer: true, shimmerLines: 6);
                  }
                  if (state is BillError) {
                    return AppErrorWidget(
                        message: state.message, onRetry: _loadData);
                  }
                  if (state is BillLoaded) {
                    if (state.bills.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.receipt_long,
                        title: 'Nenhuma conta',
                        subtitle: 'Adicione uma conta a pagar',
                        actionLabel: 'Nova conta',
                        onAction: () => showBillCreateDialog(context),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => _loadData(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: state.bills.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: SectionHeader(
                                title: 'Suas Contas',
                                padding: EdgeInsets.zero,
                              ),
                            );
                          }
                          final bill = state.bills[index - 1];
                          final (dueLabel, color) = _dueInfo(bill, theme);
                          final isPaid = _isPaidThisCycle(bill);
                          return BillListItem(
                            bill: bill,
                            dueLabel: dueLabel,
                            dueColor: color,
                            isPaid: isPaid,
                            onTap: () => showBillPayDialog(
                                context, bill.id!, bill.amount),
                            onConfirmDismiss: () => ConfirmDialog.show(
                              context,
                              title: 'Excluir conta',
                              message: 'Deseja excluir "${bill.title}"?',
                              confirmText: 'Excluir',
                              confirmColor: theme.colorScheme.error,
                            ),
                            onDismissed: () =>
                                context.read<BillCubit>().deleteBill(bill.id!),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
