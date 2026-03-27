import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/budget/budget_cubit.dart';
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

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<BudgetCubit>().loadBudgets(month: DateFormatter.monthKey(_selectedMonth));
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
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
              Text('Novo Orçamento', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameCtrl,
                label: 'Nome',
                prefixIcon: Icons.label,
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
              CurrencyTextField(controller: amountCtrl, label: 'Limite', validator: Validators.currency),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  context.read<BudgetCubit>().createBudget({
                    'nome': nameCtrl.text.trim(),
                    'valor_limite': double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0,
                    'mes': DateFormatter.monthKey(_selectedMonth),
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
      appBar: AppBar(title: const Text('Orçamento')),
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
            child: BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, state) {
                if (state is BudgetLoading) return const AppLoadingIndicator();
                if (state is BudgetError) return AppErrorWidget(message: state.message, onRetry: _loadData);
                if (state is BudgetLoaded) {
                  if (state.budgets.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.pie_chart,
                      title: 'Nenhum orçamento',
                      subtitle: 'Crie seu primeiro orçamento mensal',
                      actionLabel: 'Novo orçamento',
                      onAction: _showCreateDialog,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.budgets.length,
                      itemBuilder: (context, index) {
                        final budget = state.budgets[index];
                        final spent = budget.totalSpent ?? 0;
                        final progress = budget.monthlyLimit > 0
                            ? (spent / budget.monthlyLimit).clamp(0.0, 1.0)
                            : 0.0;
                        final isOver = spent > budget.monthlyLimit;
                        final progressColor = isOver ? theme.colorScheme.error : theme.colorScheme.primary;
                        return Dismissible(
                          key: Key('budget_${budget.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: theme.colorScheme.error,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) => ConfirmDialog.show(
                            context,
                            title: 'Excluir orçamento',
                            message: 'Deseja excluir o orçamento de ${budget.monthYear}?',
                            confirmText: 'Excluir',
                            confirmColor: theme.colorScheme.error,
                          ),
                          onDismissed: (_) => context.read<BudgetCubit>().deleteBudget(budget.id!),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Orçamento ${budget.monthYear}',
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${(progress * 100).toStringAsFixed(0)}%',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          color: progressColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      color: progressColor,
                                      backgroundColor: progressColor.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Gasto: ${CurrencyFormatter.format(spent)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      Text(
                                        'Limite: ${CurrencyFormatter.format(budget.monthlyLimit)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  if ((budget.categories ?? []).isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      children: (budget.categories ?? []).map((c) => Chip(
                                        label: Text(c.categoryName ?? '', style: const TextStyle(fontSize: 11)),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      )).toList(),
                                    ),
                                  ],
                                ],
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
}
