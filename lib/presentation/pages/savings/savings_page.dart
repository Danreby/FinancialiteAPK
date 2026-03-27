import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/savings/savings_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';

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

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    DateTime? deadline;
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
              Text('Nova Meta', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameCtrl,
                label: 'Nome da meta',
                prefixIcon: Icons.flag,
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
              CurrencyTextField(controller: targetCtrl, label: 'Valor alvo', validator: Validators.currency),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setLocalState) => AppTextField(
                  label: 'Prazo (opcional)',
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                  controller: TextEditingController(
                    text: deadline != null ? DateFormatter.shortDate(deadline!) : '',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 90)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setLocalState(() => deadline = picked);
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  context.read<SavingsCubit>().createGoal({
                    'nome': nameCtrl.text.trim(),
                    'valor_alvo': double.tryParse(targetCtrl.text.replaceAll(',', '.')) ?? 0,
                    if (deadline != null) 'prazo': deadline!.toIso8601String().substring(0, 10),
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

  void _showDepositDialog(int goalId) {
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Adicionar Depósito', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            CurrencyTextField(controller: amountCtrl, validator: Validators.currency),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                context.read<SavingsCubit>().addDeposit(goalId, {
                  'valor': double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0,
                });
                Navigator.pop(ctx);
              },
              child: const Text('Depositar'),
            ),
          ],
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton(
          onPressed: _showCreateDialog,
          child: const Icon(Icons.add),
        ),
      ),
      body: BlocBuilder<SavingsCubit, SavingsState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Metas de Economia',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                      value: CurrencyFormatter.format(state.summary!.totalSaved),
                      icon: Icons.savings,
                      iconColor: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: StatCard(
                      title: 'Meta Total',
                      value: CurrencyFormatter.format(state.summary!.totalTarget),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(Icons.savings, size: 40, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma meta',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crie sua primeira meta de economia',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...state.goals.map((goal) {
                final progress = goal.targetAmount > 0
                    ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
                    : 0.0;
                final progressColor = progress >= 1.0
                    ? Colors.green
                    : theme.colorScheme.primary;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showDepositDialog(goal.id!),
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
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                                  color: progressColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.savings, color: progressColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      goal.title,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (goal.deadline != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'Prazo: ${DateFormatter.shortDate(goal.deadline!)}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: progressColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: progressColor,
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
                              minHeight: 10,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              color: progressColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                CurrencyFormatter.format(goal.currentAmount),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: progressColor,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(goal.targetAmount),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
