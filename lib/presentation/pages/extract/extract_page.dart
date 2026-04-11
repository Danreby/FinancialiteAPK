import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/transaction_tile.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../widgets/page_header.dart';

class ExtractPage extends StatelessWidget {
  const ExtractPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionBloc(sl<TransactionRepository>()),
      child: const _ExtractView(),
    );
  }
}

class _ExtractView extends StatefulWidget {
  const _ExtractView();

  @override
  State<_ExtractView> createState() => _ExtractViewState();
}

class _ExtractViewState extends State<_ExtractView> {
  DateTime _selectedMonth = DateTime.now();
  final _scrollController = ScrollController();
  String _typeFilter = 'all'; // all, debit, credit

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final filters = <String, dynamic>{
      'month': DateFormatter.monthKey(_selectedMonth),
    };
    if (_typeFilter != 'all') filters['type'] = _typeFilter;

    context.read<TransactionBloc>().add(TransactionsFetched(
          reset: true,
          filters: filters,
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(const TransactionsFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const PageHeader(title: 'Extrato', showBackButton: true),
          MonthSelector(
            selectedMonth: _selectedMonth,
            onChanged: (date) {
              setState(() => _selectedMonth = date);
              _loadData();
            },
          ),
          const SizedBox(height: 8),
          // Type filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _filterChip('all', 'Todos', theme),
                const SizedBox(width: 8),
                _filterChip('credit', 'Crédito', theme),
                const SizedBox(width: 8),
                _filterChip('debit', 'Débito', theme),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 6);
                }
                if (state is TransactionError) {
                  return AppErrorWidget(
                      message: state.message, onRetry: _loadData);
                }
                if (state is TransactionLoaded) {
                  final transactions = state.transactions;
                  if (transactions.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Extrato vazio',
                      subtitle: 'Nenhuma transação encontrada neste mês',
                    );
                  }

                  final credits =
                      transactions.where((t) => t.type == 'credit').toList();
                  final debits =
                      transactions.where((t) => t.type == 'debit').toList();
                  final totalIn = credits.fold(0.0, (s, t) => s + t.amount);
                  final totalOut = debits.fold(0.0, (s, t) => s + t.amount);
                  final balance = totalIn - totalOut;

                  return Column(
                    children: [
                      // Stats cards
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                                child: _statCard(
                                    'Crédito',
                                    totalIn,
                                    theme.colorScheme.error,
                                    Icons.credit_card,
                                    theme)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _statCard(
                                    'Débito',
                                    totalOut,
                                    theme.colorScheme.error,
                                    Icons.account_balance,
                                    theme)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _statCard(
                                    'Saldo',
                                    balance,
                                    balance >= 0
                                        ? const Color(0xFF10B981)
                                        : theme.colorScheme.error,
                                    Icons.account_balance_wallet,
                                    theme)),
                          ],
                        ),
                      ),
                      // Mini pie chart if showing all
                      if (_typeFilter == 'all' &&
                          totalIn > 0 &&
                          totalOut > 0) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildMiniChart(totalIn, totalOut, theme),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 4, bottom: 32),
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 74,
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                          itemCount:
                              transactions.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i >= transactions.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              );
                            }
                            final t = transactions[i];
                            return TransactionTile(
                              title: t.title,
                              subtitle: t.date != null
                                  ? DateFormatter.format(t.date!)
                                  : t.categoryName ?? '',
                              amount: CurrencyFormatter.format(t.amount),
                              isExpense: true,
                              categoryIcon: iconFromName(t.categoryIcon),
                              categoryColor: colorFromHex(t.categoryColor),
                              onTap: () =>
                                  context.push('/transactions/${t.id}'),
                            );
                          },
                        ),
                      ),
                    ],
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

  Widget _filterChip(String value, String label, ThemeData theme) {
    final selected = _typeFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _typeFilter = value);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String label, double value, Color color, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatCompact(value),
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart(double totalIn, double totalOut, ThemeData theme) {
    final total = totalIn + totalOut;
    final pctIn = totalIn / total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 20,
                sections: [
                  PieChartSectionData(
                    value: totalIn,
                    color: const Color(0xFF7C3AED),
                    radius: 12,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: totalOut,
                    color: theme.colorScheme.error,
                    radius: 12,
                    title: '',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chartLegend(
                    'Crédito', pctIn * 100, const Color(0xFF7C3AED), theme),
                const SizedBox(height: 6),
                _chartLegend('Débito', (1 - pctIn) * 100,
                    theme.colorScheme.error, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, double pct, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
        const Spacer(),
        Text(
          '${pct.toStringAsFixed(1)}%',
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
