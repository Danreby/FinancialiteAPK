import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/bill/bill_cubit.dart';
import '../../../domain/entities/bill.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/page_header.dart';
import '../../widgets/shadowed_fab.dart';

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
    final lp = bill.lastPayment;
    if (lp == null || lp.status != 'paid') return false;
    final now = DateTime.now();
    final dueDate = lp.dueDate;
    if (dueDate == null) return false;
    return dueDate.year == now.year && dueDate.month == now.month;
  }

  (String, Color) _dueInfo(Bill bill, ThemeData theme) {
    if (_isPaidThisCycle(bill)) {
      final next = _nextDueDate(bill.dueDay);
      final now = DateTime.now();
      final nextCycle = DateTime(
        next.month == 12 ? next.year + 1 : next.year,
        next.month == 12 ? 1 : next.month + 1,
        1,
      );
      final daysInNextCycleMonth =
          DateTime(nextCycle.year, nextCycle.month + 1, 0).day;
      final clampedDay = bill.dueDay > daysInNextCycleMonth
          ? daysInNextCycleMonth
          : bill.dueDay;
      final nextDue = DateTime(nextCycle.year, nextCycle.month, clampedDay);
      final diff =
          nextDue.difference(DateTime(now.year, now.month, now.day)).inDays;
      return ('Pago · próx. ${diff}d', Colors.green);
    }

    final nextDue = _nextDueDate(bill.dueDay);
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final diff = nextDue.difference(today).inDays;

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

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dueDayCtrl = TextEditingController();
    String recurrenceType = 'monthly';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nova Conta', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                AppTextField(
                  controller: titleCtrl,
                  label: 'Título',
                  prefixIcon: Icons.description,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                CurrencyTextField(
                    controller: amountCtrl,
                    label: 'Valor',
                    validator: Validators.currency),
                const SizedBox(height: 12),
                AppTextField(
                  controller: dueDayCtrl,
                  label: 'Dia do vencimento (1-31)',
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  validator: Validators.dayOfMonth,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: recurrenceType,
                  decoration: const InputDecoration(
                    labelText: 'Recorrência',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'monthly', child: Text('Mensal')),
                    DropdownMenuItem(value: 'yearly', child: Text('Anual')),
                    DropdownMenuItem(
                        value: 'none', child: Text('Sem recorrência')),
                  ],
                  onChanged: (v) =>
                      setLocalState(() => recurrenceType = v ?? 'monthly'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    context.read<BillCubit>().createBill({
                      'title': titleCtrl.text.trim(),
                      'amount': CurrencyTextField.parseValue(amountCtrl.text),
                      'due_day': int.tryParse(dueDayCtrl.text) ?? 1,
                      'recurrence_type': recurrenceType,
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      floatingActionButton: ShadowedFab(onPressed: _showCreateDialog),
      body: Column(
        children: [
          const PageHeader(title: 'Contas a Pagar', bottomPadding: 16),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<BillCubit, BillState>(
              builder: (context, state) {
                if (state is BillLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 6);
                }
                if (state is BillError)
                  return AppErrorWidget(
                      message: state.message, onRetry: _loadData);
                if (state is BillLoaded) {
                  if (state.bills.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.receipt_long,
                      title: 'Nenhuma conta',
                      subtitle: 'Adicione uma conta a pagar',
                      actionLabel: 'Nova conta',
                      onAction: _showCreateDialog,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: Key('bill_${bill.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) => ConfirmDialog.show(
                              context,
                              title: 'Excluir conta',
                              message: 'Deseja excluir "${bill.title}"?',
                              confirmText: 'Excluir',
                              confirmColor: theme.colorScheme.error,
                            ),
                            onDismissed: (_) =>
                                context.read<BillCubit>().deleteBill(bill.id!),
                            child: GestureDetector(
                              onTap: () {
                                if (!isPaid) {
                                  _showPayDialog(bill.id!, bill.amount);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.receipt,
                                          color: color, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bill.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Vence: dia ${bill.dueDay}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(bill.amount),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                                color.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            dueLabel,
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: color,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPayDialog(int billId, double amount) {
    final amountCtrl = TextEditingController(text: amount.toStringAsFixed(2));
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pagar Conta', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            CurrencyTextField(
                controller: amountCtrl, label: 'Valor do pagamento'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<BillCubit>().payBill(billId, {
                  'valor_pago':
                      double.tryParse(amountCtrl.text.replaceAll(',', '.')) ??
                          amount,
                  'data_pagamento':
                      DateTime.now().toIso8601String().substring(0, 10),
                });
                Navigator.pop(ctx);
              },
              child: const Text('Confirmar Pagamento'),
            ),
          ],
        ),
      ),
    );
  }
}
