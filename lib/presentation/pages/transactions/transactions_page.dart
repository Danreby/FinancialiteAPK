import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/transaction_tile.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  DateTime _selectedMonth = DateTime.now();
  final _scrollController = ScrollController();

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
    context.read<TransactionBloc>().add(TransactionsFetched(
          reset: true,
          filters: {'month': DateFormatter.monthKey(_selectedMonth)},
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(const TransactionsFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 8,
            ),
            child: Row(
              children: [
                Text(
                  'Transações',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: MonthSelector(
              selectedMonth: _selectedMonth,
              onChanged: (date) {
                setState(() => _selectedMonth = date);
                _loadData();
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const AppLoadingIndicator(
                    useShimmer: true,
                    shimmerLines: 6,
                  );
                }
                if (state is TransactionError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: _loadData,
                  );
                }
                if (state is TransactionLoaded) {
                  if (state.transactions.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Nenhuma transação',
                      subtitle: 'Adicione sua primeira transação do mês',
                      actionLabel: 'Nova transação',
                      onAction: () => context.push('/transactions/new'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.transactions.length) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ),
                          );
                        }
                        final tx = state.transactions[index];
                        final isExpense = tx.type == 'despesa';
                        return Dismissible(
                          key: Key('tx_${tx.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) => ConfirmDialog.show(
                            context,
                            title: 'Excluir transação',
                            message: 'Deseja realmente excluir esta transação?',
                            confirmText: 'Excluir',
                            confirmColor: theme.colorScheme.error,
                          ),
                          onDismissed: (_) {
                            context
                                .read<TransactionBloc>()
                                .add(TransactionDeleted(tx.id!));
                          },
                          child: TransactionTile(
                            title: tx.title,
                            subtitle:
                                '${tx.categoryName ?? 'Sem categoria'}${tx.date != null ? ' • ${DateFormatter.shortDate(tx.date!)}' : ''}',
                            amount: CurrencyFormatter.format(tx.amount),
                            isExpense: isExpense,
                            categoryIcon: isExpense
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            onTap: () =>
                                context.push('/transactions/${tx.id}'),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/transactions/new'),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}
