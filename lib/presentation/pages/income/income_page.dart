import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/income/income_cubit.dart';
import '../../../domain/entities/income.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
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
    context
        .read<IncomeCubit>()
        .loadIncomes(month: DateFormatter.monthKey(_selectedMonth));
  }

  void _showIncomeDialog({Income? editing}) {
    final titleCtrl = TextEditingController(text: editing?.title ?? '');
    final amountCtrl = TextEditingController(
      text: editing != null ? editing.amount.toStringAsFixed(2) : '',
    );
    String incomeType = editing?.type ?? 'salary';
    DateTime date = editing?.createdAt ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setLocalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  editing != null ? 'Editar Receita' : 'Nova Receita',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: titleCtrl,
                  label: 'Título',
                  prefixIcon: Icons.description,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                CurrencyTextField(
                    controller: amountCtrl, validator: Validators.currency),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: incomeType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'salary', child: Text('Salário')),
                    DropdownMenuItem(
                        value: 'freelance', child: Text('Freelance')),
                    DropdownMenuItem(
                        value: 'investment', child: Text('Investimento')),
                    DropdownMenuItem(value: 'rental', child: Text('Aluguel')),
                    DropdownMenuItem(
                        value: 'benefit', child: Text('Benefício')),
                    DropdownMenuItem(value: 'pix', child: Text('Pix')),
                    DropdownMenuItem(value: 'other', child: Text('Outro')),
                  ],
                  onChanged: (v) =>
                      setLocalState(() => incomeType = v ?? 'salary'),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Data',
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                  controller: TextEditingController(
                      text: DateFormatter.shortDate(date)),
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
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final data = {
                      'title': titleCtrl.text.trim(),
                      'amount': double.tryParse(
                              amountCtrl.text.replaceAll(',', '.')) ??
                          0,
                      'type': incomeType,
                      'is_recurring': false,
                      'received_at': date.toIso8601String().substring(0, 10),
                    };
                    if (editing != null) {
                      context
                          .read<IncomeCubit>()
                          .updateIncome(editing.id!, data);
                    } else {
                      context.read<IncomeCubit>().createIncome(data);
                    }
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

  void _showCreateDialog() => _showIncomeDialog();

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
                    'Receitas',
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
            child: BlocBuilder<IncomeCubit, IncomeState>(
              builder: (context, state) {
                if (state is IncomeLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 6);
                }
                if (state is IncomeError)
                  return AppErrorWidget(
                      message: state.message, onRetry: _loadData);
                if (state is IncomeLoaded) {
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
                                  title: 'Total Mensal',
                                  value: CurrencyFormatter.format(
                                      state.summary!.totalMonthly),
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
                          const SizedBox(height: 16),
                        ],
                        if (state.incomes.isEmpty)
                          const EmptyStateWidget(
                            icon: Icons.trending_up,
                            title: 'Nenhuma receita',
                            subtitle: 'Adicione sua primeira receita',
                          )
                        else ...[
                          SectionHeader(
                            title: 'Suas Receitas',
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 12),
                          ...state.incomes.map((income) {
                            final isReceived = income.isActive;
                            final iconColor =
                                isReceived ? Colors.green : Colors.orange;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Dismissible(
                                key: Key('income_${income.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                confirmDismiss: (_) => ConfirmDialog.show(
                                  context,
                                  title: 'Excluir receita',
                                  message: 'Deseja excluir "${income.title}"?',
                                  confirmText: 'Excluir',
                                  confirmColor: theme.colorScheme.error,
                                ),
                                onDismissed: (_) => context
                                    .read<IncomeCubit>()
                                    .deleteIncome(income.id!),
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
                                          color:
                                              iconColor.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isReceived
                                              ? Icons.check_circle
                                              : Icons.schedule,
                                          color: iconColor,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              income.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              income.typeLabel,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
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
                                            CurrencyFormatter.format(
                                                income.amount),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green,
                                            ),
                                          ),
                                          if (!isReceived) ...[
                                            const SizedBox(height: 4),
                                            GestureDetector(
                                              onTap: () => context
                                                  .read<IncomeCubit>()
                                                  .markAsReceived(income.id!),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  'Receber',
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined,
                                            size: 18,
                                            color: theme
                                                .colorScheme.onSurfaceVariant),
                                        onPressed: () =>
                                            _showIncomeDialog(editing: income),
                                        constraints: const BoxConstraints(
                                            maxWidth: 32, maxHeight: 32),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
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
