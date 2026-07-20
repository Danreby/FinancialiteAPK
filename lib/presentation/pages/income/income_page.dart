import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/income/income_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/page_header.dart';
import '../../widgets/shadowed_fab.dart';
import '../../../core/theme/app_tokens.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<IncomeCubit>().loadIncomes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton:
          ShadowedFab(onPressed: () => context.push('/income/new')),
      body: Column(
        children: [
          const PageHeader(title: 'Receitas', bottomPadding: 16),
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
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xl),
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
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xl),
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
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.xl),
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
                                            Row(
                                              children: [
                                                Text(
                                                  income.typeLabel,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                if (income.isRecurring) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFF3B82F6)
                                                          .withValues(
                                                              alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.sm),
                                                    ),
                                                    child: const Text(
                                                      'Recorrente',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xFF3B82F6),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
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
                                                      BorderRadius.circular(
                                                          AppRadius.lg),
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
                                            context.push('/income/${income.id}'),
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
