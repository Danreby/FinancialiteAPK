import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/month_selector.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final monthKey = DateFormatter.monthKey(_selectedMonth);
    context.read<DashboardCubit>().load(month: monthKey);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final monthKey = DateFormatter.monthKey(_selectedMonth);
          await context.read<DashboardCubit>().refresh(month: monthKey);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              MonthSelector(
                selectedMonth: _selectedMonth,
                onChanged: (date) {
                  setState(() => _selectedMonth = date);
                  _loadData();
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const SizedBox(height: 300, child: AppLoadingIndicator());
                  }
                  if (state is DashboardError) {
                    return AppErrorWidget(message: state.message, onRetry: _loadData);
                  }
                  if (state is DashboardLoaded) {
                    return _buildContent(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    final data = state.data;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Saldo do Mês', style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  )),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(data.balance),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: data.balance >= 0
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                title: 'Receitas',
                value: CurrencyFormatter.format(data.totalIncome),
                icon: Icons.trending_up,
                iconColor: Colors.green,
                onTap: () => context.push('/income'),
              ),
              StatCard(
                title: 'Despesas',
                value: CurrencyFormatter.format(data.totalExpense),
                icon: Icons.trending_down,
                iconColor: Colors.red,
                onTap: () => context.push('/transactions'),
              ),
              StatCard(
                title: 'Contas a pagar',
                value: '${data.pendingBills}',
                icon: Icons.receipt_long,
                iconColor: Colors.orange,
                onTap: () => context.push('/bills'),
              ),
              StatCard(
                title: 'Economias',
                value: CurrencyFormatter.format(data.savingsTotal),
                icon: Icons.savings,
                iconColor: Colors.blue,
                onTap: () => context.push('/savings'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Upcoming bills
          if (data.upcomingBills.isNotEmpty) ...[
            Text('Próximas Contas', style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 12),
            ...data.upcomingBills.take(5).map((bill) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.errorContainer,
                      child: Icon(Icons.receipt, color: theme.colorScheme.error, size: 20),
                    ),
                    title: Text(bill.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('Dia ${bill.dueDay}'),
                    trailing: Text(
                      CurrencyFormatter.format(bill.amount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                )),
          ],
          // Category spending
          if (data.topCategories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Gastos por Categoria', style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 12),
            ...data.topCategories.take(5).map((cat) {
              final percent = data.totalExpense > 0
                  ? (cat.amount / data.totalExpense * 100)
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Text(CurrencyFormatter.format(cat.amount),
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percent / 100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
