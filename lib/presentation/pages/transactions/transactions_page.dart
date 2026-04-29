import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/category/category_cubit.dart';
import '../../blocs/card/card_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/responsive_content.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/card_entity.dart';
import '../../widgets/page_header.dart';
import '../../widgets/shadowed_fab.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  DateTime _selectedMonth = DateTime.now();
  final _scrollController = ScrollController();

  String _typeFilter = 'all';
  String _statusFilter = 'all';
  String _recurringFilter = 'all';
  int? _bankUserId;
  int? _categoryId;
  String _order = 'created_desc';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategories();
    context.read<CardCubit>().loadCards();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildFilters() {
    final filters = <String, dynamic>{
      'month': DateFormatter.monthKey(_selectedMonth),
      'order': _order,
    };

    if (_typeFilter != 'all') filters['type'] = _typeFilter;
    if (_statusFilter != 'all') filters['status'] = _statusFilter;
    if (_bankUserId != null) filters['bank_user_id'] = _bankUserId;
    if (_categoryId != null) filters['category_id'] = _categoryId;
    final search = _searchController.text.trim();
    if (search.isNotEmpty) filters['search'] = search;
    if (_recurringFilter != 'all') {
      filters['is_recurring'] = _recurringFilter == 'recurring';
    }

    return filters;
  }

  void _loadData() {
    context.read<TransactionBloc>().add(TransactionsFetched(
          reset: true,
          filters: _buildFilters(),
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(const TransactionsFetched());
    }
  }

  void _openFilterSheet() {
    final cardsState = context.read<CardCubit>().state;
    final categoriesState = context.read<CategoryCubit>().state;
    final cards = cardsState is CardLoaded ? cardsState.cards : <CardUser>[];
    final categories = categoriesState is CategoryLoaded
        ? categoriesState.categories
        : <Category>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String tempStatus = _statusFilter;
        String tempRecurring = _recurringFilter;
        int? tempBankUserId = _bankUserId;
        int? tempCategoryId = _categoryId;
        String tempOrder = _order;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text('Filtros',
                              style: Theme.of(context).textTheme.titleLarge),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempStatus = 'all';
                                tempRecurring = 'all';
                                tempBankUserId = null;
                                tempCategoryId = null;
                                tempOrder = 'created_desc';
                              });
                            },
                            child: const Text('Limpar'),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: tempStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todos')),
                          DropdownMenuItem(value: 'paid', child: Text('Pago')),
                          DropdownMenuItem(
                              value: 'unpaid', child: Text('Pendente')),
                          DropdownMenuItem(
                              value: 'overdue', child: Text('Vencido')),
                        ],
                        onChanged: (v) =>
                            setModalState(() => tempStatus = v ?? 'all'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: tempRecurring,
                        decoration: const InputDecoration(
                          labelText: 'Recorrência',
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todas')),
                          DropdownMenuItem(
                              value: 'recurring', child: Text('Recorrente')),
                          DropdownMenuItem(
                              value: 'non_recurring',
                              child: Text('Não recorrente')),
                        ],
                        onChanged: (v) =>
                            setModalState(() => tempRecurring = v ?? 'all'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        value: tempBankUserId,
                        decoration: const InputDecoration(
                          labelText: 'Cartão',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                              value: null, child: Text('Todos')),
                          ...cards.map((c) => DropdownMenuItem<int?>(
                                value: c.id,
                                child: Text(c.cardName ?? 'Cartão #${c.id}'),
                              )),
                        ],
                        onChanged: (v) =>
                            setModalState(() => tempBankUserId = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        value: tempCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                              value: null, child: Text('Todas')),
                          ...categories.map((c) => DropdownMenuItem<int?>(
                                value: c.id,
                                child: Text(c.name),
                              )),
                        ],
                        onChanged: (v) =>
                            setModalState(() => tempCategoryId = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: tempOrder,
                        decoration: const InputDecoration(
                          labelText: 'Ordenação',
                          prefixIcon: Icon(Icons.sort),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'created_desc',
                              child: Text('Mais recentes')),
                          DropdownMenuItem(
                              value: 'created_asc',
                              child: Text('Mais antigas')),
                          DropdownMenuItem(
                              value: 'amount_desc', child: Text('Maior valor')),
                          DropdownMenuItem(
                              value: 'amount_asc', child: Text('Menor valor')),
                        ],
                        onChanged: (v) => setModalState(
                            () => tempOrder = v ?? 'created_desc'),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          setState(() {
                            _statusFilter = tempStatus;
                            _recurringFilter = tempRecurring;
                            _bankUserId = tempBankUserId;
                            _categoryId = tempCategoryId;
                            _order = tempOrder;
                          });
                          Navigator.pop(ctx);
                          _loadData();
                        },
                        child: const Text('Aplicar filtros'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          // Custom Header
          const PageHeader(title: 'Transações'),
          ResponsiveContent(
            child: Column(
              children: [
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('Todos')),
                          ButtonSegment(
                              value: 'credit', label: Text('Entrada')),
                          ButtonSegment(value: 'debit', label: Text('Saída')),
                        ],
                        selected: {_typeFilter},
                        onSelectionChanged: (value) {
                          setState(() => _typeFilter = value.first);
                          _loadData();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.tune),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar por descrição/título',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() => _searchController.clear());
                              _loadData();
                            },
                          ),
                  ),
                  onSubmitted: (_) {
                    // Search endpoint isn't available in mobile API yet.
                    _loadData();
                  },
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
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
                    child: ResponsiveContent(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount:
                            state.transactions.length + (state.hasMore ? 1 : 0),
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
                          final isCredit = tx.type == 'credit';
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
                              message:
                                  'Deseja realmente excluir esta transação?',
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
                                  '${isCredit ? 'Crédito' : 'Débito'} • ${tx.categoryName ?? 'Sem categoria'}${tx.date != null ? ' • ${DateFormatter.shortDate(tx.date!)}' : ''}',
                              amount: CurrencyFormatter.format(tx.amount),
                              isExpense: true,
                              categoryIcon: Icons.arrow_circle_down_rounded,
                              onTap: () =>
                                  context.push('/transactions/${tx.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ShadowedFab(
        onPressed: () => context.push('/transactions/new'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
