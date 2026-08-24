import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/transaction.dart';
import '../../../../domain/repositories/transaction_repository.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../blocs/notification/notification_cubit.dart';
import '../../blocs/savings/savings_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/ledger_row.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_utils.dart';
import 'widgets/balance_card.dart';
import 'widgets/dashboard_split_row.dart';
import 'widgets/monthly_line_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _transactionRepo = sl<TransactionRepository>();
  List<Transaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRecentTransactions();
  }

  void _loadData() {
    final monthKey = DateFormatter.monthKey(DateTime.now());
    context.read<DashboardCubit>().load(month: monthKey);
    context.read<SavingsCubit>().loadGoals();
  }

  Future<void> _loadRecentTransactions() async {
    try {
      final transactions = await _transactionRepo.getTransactions(perPage: 4);
      if (!mounted) return;
      setState(() => _recentTransactions = transactions);
    } catch (_) {
      // Non-critical: the rest of the dashboard still works without this.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    return Scaffold(
      backgroundColor: appColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          final monthKey = DateFormatter.monthKey(DateTime.now());
          await context.read<DashboardCubit>().refresh(month: monthKey);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: PageHeader(
                title: 'Visão Geral',
                bottomPadding: 4,
                trailing: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, notifState) {
                    final unread = notifState is NotificationLoaded
                        ? notifState.unreadCount
                        : 0;
                    return InkWell(
                      onTap: () => context.push('/notifications'),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Badge(
                          isLabelVisible: unread > 0,
                          label: Text(
                            '$unread',
                            style: const TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: theme.colorScheme.onSurface,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const AppLoadingIndicator(
                        useShimmer: true, shimmerLines: 5);
                  }
                  if (state is DashboardError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: _loadData,
                    );
                  }
                  if (state is DashboardLoaded) {
                    return _buildContent(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    final data = state.data;
    final appColors = Theme.of(context).appColors;

    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Editorial-ledger hero: balance, "Resumo do Mês" figures, and
          // the Entrada/Saída actions now read as one continuous block
          // instead of three components competing for top-of-page space.
          // "Receitas" is intentionally omitted from the summary -- it
          // duplicates the Entrada action below and the income figure
          // already implied by the balance, so it read as noise.
          BlocBuilder<SavingsCubit, SavingsState>(
            builder: (context, savingsState) {
              final metasTotal = savingsState is SavingsLoaded
                  ? (savingsState.summary?.totalSaved ?? 0.0)
                  : 0.0;
              return DashboardBalanceCard(
                balance: data.balance,
                despesas: data.totalExpense,
                credito: data.pendingBillAmount,
                debito: data.monthDebitTotal,
                pendingBillsCount: data.pendingBills,
                metasTotal: metasTotal,
                onNewExpense: () => context.push('/transactions/new'),
                onNewIncome: () => context.push('/income/new'),
                onTapContas: () => context.push('/bills'),
                onTapMetas: () => context.push('/savings'),
              );
            },
          ),
          if (_recentTransactions.isNotEmpty) ...[
            const SizedBox(height: 32),
            LedgerSectionLabel(
              title: 'Últimas Transações',
              actionText: 'Ver todas',
              onAction: () => context.push('/transactions'),
            ),
            const SizedBox(height: 4),
            ..._recentTransactions.map((tx) {
              final isCredit = tx.type == 'credit';
              return TransactionTile(
                title: tx.title,
                subtitle: [
                  isCredit ? 'Crédito' : 'Débito',
                  tx.categoryName ?? 'Sem categoria',
                  if (tx.date != null) DateFormatter.shortDate(tx.date!),
                ].join(' • '),
                amount: CurrencyFormatter.format(tx.amount),
                isExpense: !isCredit,
                categoryIconName: tx.categoryIcon,
                categoryColor:
                    tx.categoryColor != null ? colorFromHex(tx.categoryColor) : null,
                onTap: () => context.push('/transactions/${tx.id}'),
              );
            }),
          ],
          if (data.monthlyChart.isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Evolução Mensal', style: Theme.of(context).textTheme.titleMedium),
                GestureDetector(
                  onTap: () => context.push('/reports'),
                  child: Text(
                    'Ver relatórios',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: appColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MonthlyLineChart(data: data.monthlyChart),
          ],
          if (data.upcomingBills.isNotEmpty || data.topCategories.isNotEmpty) ...[
            const SizedBox(height: 32),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (data.upcomingBills.isNotEmpty)
                    Expanded(
                      child: UpcomingBillsPanel(
                        bills: data.upcomingBills,
                        onSeeAll: () => context.push('/bills'),
                      ),
                    ),
                  if (data.upcomingBills.isNotEmpty && data.topCategories.isNotEmpty)
                    const SizedBox(width: 24),
                  if (data.topCategories.isNotEmpty)
                    Expanded(
                      child: CategoriesPanel(
                        categories: data.topCategories,
                        totalExpense: data.totalExpense,
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 130),
        ],
      ),
    );
  }
}
