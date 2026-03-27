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
    return Scaffold(
      appBar: AppBar(title: const Text('Metas de Economia')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<SavingsCubit, SavingsState>(
        builder: (context, state) {
          if (state is SavingsLoading) return const AppLoadingIndicator();
          if (state is SavingsError) return AppErrorWidget(message: state.message, onRetry: _loadData);
          if (state is SavingsLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 16),
                  ],
                  if (state.goals.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.savings,
                      title: 'Nenhuma meta',
                      subtitle: 'Crie sua primeira meta de economia',
                    )
                  else
                    ...state.goals.map((goal) {
                      final progress = goal.targetAmount > 0
                          ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
                          : 0.0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.savings, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        goal.title,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Text('${(progress * 100).toStringAsFixed(0)}%',
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(CurrencyFormatter.format(goal.currentAmount),
                                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                                    Text(CurrencyFormatter.format(goal.targetAmount),
                                        style: theme.textTheme.bodySmall),
                                  ],
                                ),
                                if (goal.deadline != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Prazo: ${DateFormatter.shortDate(goal.deadline!)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
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
        },
      ),
    );
  }
}
