import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/savings/savings_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/page_header.dart';
import '../../widgets/shadowed_fab.dart';
import 'widgets/savings_goal_card.dart';
import 'widgets/savings_dialogs.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() => context.read<SavingsCubit>().loadGoals();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton:
          ShadowedFab(onPressed: () => showGoalDialog(context)),
      body: BlocBuilder<SavingsCubit, SavingsState>(
        builder: (context, state) {
          return Column(
            children: [
              const PageHeader(title: 'Metas de Economia', bottomPadding: 16),
              Expanded(child: _buildBody(context, state, theme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SavingsState state, ThemeData theme) {
    if (state is SavingsLoading) {
      return const AppLoadingIndicator(useShimmer: true, shimmerLines: 5);
    }
    if (state is SavingsError) {
      return AppErrorWidget(message: state.message, onRetry: _loadData);
    }
    if (state is SavingsLoaded) {
      return RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            if (state.summary != null) ...[
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Economizado',
                      value:
                          CurrencyFormatter.format(state.summary!.totalSaved),
                      icon: Icons.savings,
                      iconColor: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: StatCard(
                      title: 'Meta Total',
                      value:
                          CurrencyFormatter.format(state.summary!.totalTarget),
                      icon: Icons.flag,
                      iconColor: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            if (state.goals.isNotEmpty) ...[
              const SectionHeader(title: 'Suas Metas'),
              const SizedBox(height: 12),
            ],
            if (state.goals.isEmpty)
              const EmptyStateWidget(
                icon: Icons.savings,
                title: 'Nenhuma meta',
                subtitle: 'Crie sua primeira meta de economia',
              )
            else
              ...state.goals.map((goal) => SavingsGoalCard(
                    goal: goal,
                    onTap: () => showDepositDialog(context, goal.id!),
                    onLongPress: () async {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Excluir meta',
                        message: 'Deseja excluir "${goal.title}"?',
                        confirmText: 'Excluir',
                        confirmColor: theme.colorScheme.error,
                      );
                      if (confirmed == true) {
                        context.read<SavingsCubit>().deleteGoal(goal.id!);
                      }
                    },
                    onEdit: () => showGoalDialog(context, editing: goal),
                  )),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
