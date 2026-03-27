import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
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
      appBar: AppBar(title: const Text('Transações')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/new'),
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
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const AppLoadingIndicator();
                }
                if (state is TransactionError) {
                  return AppErrorWidget(message: state.message, onRetry: _loadData);
                }
                if (state is TransactionLoaded) {
                  if (state.transactions.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.swap_horiz,
                      title: 'Nenhuma transação',
                      subtitle: 'Adicione sua primeira transação',
                      actionLabel: 'Nova transação',
                      onAction: () => context.push('/transactions/new'),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.transactions.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final tx = state.transactions[index];
                        final isExpense = tx.type == 'despesa';
                        return Dismissible(
                          key: Key('tx_${tx.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: theme.colorScheme.error,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) => ConfirmDialog.show(
                            context,
                            title: 'Excluir transação',
                            message: 'Deseja realmente excluir esta transação?',
                            confirmText: 'Excluir',
                            confirmColor: theme.colorScheme.error,
                          ),
                          onDismissed: (_) {
                            context.read<TransactionBloc>().add(TransactionDeleted(tx.id!));
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isExpense
                                  ? theme.colorScheme.errorContainer
                                  : Colors.green.withValues(alpha: 0.15),
                              child: Icon(
                                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isExpense ? theme.colorScheme.error : Colors.green,
                                size: 20,
                              ),
                            ),
                            title: Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              '${tx.categoryName ?? 'Sem categoria'}${tx.date != null ? ' • ${DateFormatter.shortDate(tx.date!)}' : ''}',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Text(
                              '${isExpense ? '-' : '+'}${CurrencyFormatter.format(tx.amount)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isExpense ? theme.colorScheme.error : Colors.green,
                              ),
                            ),
                            onTap: () => context.push('/transactions/${tx.id}'),
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
