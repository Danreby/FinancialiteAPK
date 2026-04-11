import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/budget/budget_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/page_header.dart';
import '../../widgets/shadowed_fab.dart';
import 'widgets/budget_list_item.dart';
import 'widgets/budget_create_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: ShadowedFab(
          onPressed: () => showBudgetCreateDialog(context, _selectedMonth)),
      body: Column(
        children: [
          const PageHeader(title: 'Orçamento', bottomPadding: 16),
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
                      onAction: () =>
                          showBudgetCreateDialog(context, _selectedMonth),
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
                        return BudgetListItem(
                          budget: budget,
                          onConfirmDismiss: () => ConfirmDialog.show(
                            context,
                            title: 'Excluir orçamento',
                            message:
                                'Deseja excluir o orçamento de ${budget.monthYear}?',
                            confirmText: 'Excluir',
                            confirmColor: theme.colorScheme.error,
                          ),
                          onDismissed: () => context
                              .read<BudgetCubit>()
                              .deleteBudget(budget.id!),
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
