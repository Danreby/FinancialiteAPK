import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/bill/bill_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<BillCubit>().loadBills(month: DateFormatter.monthKey(_selectedMonth));
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status) {
      case 'pago':
        return Colors.green;
      case 'vencido':
        return theme.colorScheme.error;
      case 'parcialmente_pago':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pago':
        return 'Pago';
      case 'vencido':
        return 'Vencido';
      case 'parcialmente_pago':
        return 'Parcial';
      default:
        return 'Pendente';
    }
  }

  void _showCreateDialog() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime dueDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nova Conta', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: descCtrl,
                label: 'Descrição',
                prefixIcon: Icons.description,
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
              CurrencyTextField(controller: amountCtrl, validator: Validators.currency),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setLocalState) => AppTextField(
                  label: 'Vencimento',
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                  controller: TextEditingController(
                    text: DateFormatter.shortDate(dueDate),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setLocalState(() => dueDate = picked);
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  context.read<BillCubit>().createBill({
                    'descricao': descCtrl.text.trim(),
                    'valor': double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0,
                    'data_vencimento': dueDate.toIso8601String().substring(0, 10),
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Contas a Pagar')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          MonthSelector(
            selectedMonth: _selectedMonth,
            onChanged: (date) {
              setState(() => _selectedMonth = date);
              _loadData();
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<BillCubit, BillState>(
              builder: (context, state) {
                if (state is BillLoading) return const AppLoadingIndicator();
                if (state is BillError) return AppErrorWidget(message: state.message, onRetry: _loadData);
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
                      itemCount: state.bills.length,
                      itemBuilder: (context, index) {
                        final bill = state.bills[index];
                        final status = bill.lastPayment?.status ?? 'pendente';
                        final color = _statusColor(status, theme);
                        return Dismissible(
                          key: Key('bill_${bill.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: theme.colorScheme.error,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) => ConfirmDialog.show(
                            context,
                            title: 'Excluir conta',
                            message: 'Deseja excluir "${bill.title}"?',
                            confirmText: 'Excluir',
                            confirmColor: theme.colorScheme.error,
                          ),
                          onDismissed: (_) => context.read<BillCubit>().deleteBill(bill.id!),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Icon(Icons.receipt, color: color, size: 20),
                            ),
                            title: Text(bill.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              'Vence: dia ${bill.dueDay}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(bill.amount),
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _statusLabel(status),
                                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (status != 'pago') {
                                _showPayDialog(bill.id!, bill.amount);
                              }
                            },
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
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pagar Conta', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            CurrencyTextField(controller: amountCtrl, label: 'Valor do pagamento'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<BillCubit>().payBill(billId, {
                  'valor_pago': double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? amount,
                  'data_pagamento': DateTime.now().toIso8601String().substring(0, 10),
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
