import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/budget/budget_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/section_header.dart';
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
    context
        .read<BudgetCubit>()
        .loadBudgets(month: DateFormatter.monthKey(_selectedMonth));
  }

  void _showCreateDialog() {
    final amountCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Novo Orçamento', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              CurrencyTextField(
                  controller: amountCtrl,
                  label: 'Limite mensal',
                  validator: Validators.currency),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  context.read<BudgetCubit>().createBudget({
                    'monthly_limit':
                        CurrencyTextField.parseValue(amountCtrl.text),
                    'month_year': DateFormatter.monthKey(_selectedMonth),
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
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: _showCreateDialog,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Orçamento',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          MonthSelector(
            selectedMonth: _selectedMonth,
            onChanged: (date) {
              setState(() => _selectedMonth = date);
              _loadData();
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<BudgetCubit, BudgetState>(
              builder: (context, state) {
                if (state is BudgetLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 5);
                }
                if (state is BudgetError)
                  return AppErrorWidget(
                      message: state.message, onRetry: _loadData);
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: state.budgets.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SectionHeader(
                              title: 'Seus Orçamentos',
                              padding: EdgeInsets.zero,
                            ),
                          );
                        }
                        final budget = state.budgets[index - 1];
                        final spent = budget.totalSpent ?? 0;
                        final progress = budget.monthlyLimit > 0
                            ? (spent / budget.monthlyLimit).clamp(0.0, 1.0)
                            : 0.0;
                        final isOver = spent > budget.monthlyLimit;
                        final progressColor = isOver
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key('budget_${budget.id}'),
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
                              title: 'Excluir orçamento',
                              message:
                                  'Deseja excluir o orçamento de ${budget.monthYear}?',
                              confirmText: 'Excluir',
                              confirmColor: theme.colorScheme.error,
                            ),
                            onDismissed: (_) => context
                                .read<BudgetCubit>()
                                .deleteBudget(budget.id!),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: progressColor.withValues(
                                              alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          Icons.pie_chart_rounded,
                                          color: progressColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Orçamento ${budget.monthYear}',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isOver
                                                  ? 'Limite excedido'
                                                  : 'Dentro do limite',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: isOver
                                                    ? theme.colorScheme.error
                                                    : theme.colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: progressColor.withValues(
                                              alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${(progress * 100).toStringAsFixed(0)}%',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: progressColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      color: progressColor,
                                      backgroundColor:
                                          progressColor.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Gasto: ${CurrencyFormatter.format(spent)}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        'Limite: ${CurrencyFormatter.format(budget.monthlyLimit)}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((budget.categories ?? []).isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: (budget.categories ?? [])
                                          .map((c) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme
                                                      .primaryContainer
                                                      .withValues(alpha: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  c.categoryName ?? '',
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.colorScheme
                                                        .onPrimaryContainer,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
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
