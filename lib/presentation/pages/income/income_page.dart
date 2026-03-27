import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/income/income_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/stat_card.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<IncomeCubit>().loadIncomes(month: DateFormatter.monthKey(_selectedMonth));
  }

  void _showCreateDialog() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime date = DateTime.now();
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
              Text('Nova Receita', style: Theme.of(ctx).textTheme.titleLarge),
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
                  label: 'Data',
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                  controller: TextEditingController(text: DateFormatter.shortDate(date)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setLocalState(() => date = picked);
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  context.read<IncomeCubit>().createIncome({
                    'descricao': descCtrl.text.trim(),
                    'valor': double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0,
                    'data': date.toIso8601String().substring(0, 10),
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
      appBar: AppBar(title: const Text('Receitas')),
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
            child: BlocBuilder<IncomeCubit, IncomeState>(
              builder: (context, state) {
                if (state is IncomeLoading) return const AppLoadingIndicator();
                if (state is IncomeError) return AppErrorWidget(message: state.message, onRetry: _loadData);
                if (state is IncomeLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: ListView(
                      children: [
                        if (state.summary != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Total Mensal',
                                    value: CurrencyFormatter.format(state.summary!.totalMonthly),
                                    icon: Icons.trending_up,
                                    iconColor: Colors.green,
                                  ),
                                ),
                                Expanded(
                                  child: StatCard(
                                    title: 'Ativas',
                                    value: '${state.summary!.activeCount}',
                                    icon: Icons.check_circle,
                                    iconColor: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (state.incomes.isEmpty)
                          const EmptyStateWidget(
                            icon: Icons.trending_up,
                            title: 'Nenhuma receita',
                            subtitle: 'Adicione sua primeira receita',
                          )
                        else
                          ...state.incomes.map((income) {
                            final isReceived = income.isActive;
                            return Dismissible(
                              key: Key('income_${income.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: theme.colorScheme.error,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) => ConfirmDialog.show(
                                context,
                                title: 'Excluir receita',
                                message: 'Deseja excluir "${income.title}"?',
                                confirmText: 'Excluir',
                                confirmColor: theme.colorScheme.error,
                              ),
                              onDismissed: (_) => context.read<IncomeCubit>().deleteIncome(income.id!),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.withValues(alpha: 0.15),
                                  child: Icon(
                                    isReceived ? Icons.check_circle : Icons.schedule,
                                    color: isReceived ? Colors.green : Colors.orange,
                                    size: 20,
                                  ),
                                ),
                                title: Text(income.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(income.typeLabel),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(income.amount),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                    if (!isReceived)
                                      TextButton(
                                        onPressed: () => context.read<IncomeCubit>().markAsReceived(income.id!),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text('Receber', style: TextStyle(fontSize: 12)),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
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
}
