import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../blocs/notification/notification_cubit.dart';
import '../../blocs/savings/savings_cubit.dart';
import '../../widgets/income_form_dialog.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_content.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import 'widgets/balance_card.dart';
import 'widgets/monthly_line_chart.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/upcoming_bills_section.dart';
import 'widgets/category_spending_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final monthKey = DateFormatter.monthKey(DateTime.now());
    context.read<DashboardCubit>().load(month: monthKey);
    context.read<SavingsCubit>().loadGoals();
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
                    return GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: appColors.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appColors.divider.withValues(alpha: 0.6),
                          ),
                        ),
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
                            size: 22,
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
                    return const SizedBox(
                      height: 400,
                      child: AppLoadingIndicator(
                          useShimmer: true, shimmerLines: 5),
                    );
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

    return ResponsiveContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          DashboardBalanceCard(
            balance: data.balance,
            totalIncome: data.totalIncome,
            totalExpense: data.totalExpense,
            pendingBillAmount: data.pendingBillAmount,
            monthDebitTotal: data.monthDebitTotal,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Contas a pagar',
                  value: '${data.pendingBills}',
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  onTap: () => context.push('/bills'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<SavingsCubit, SavingsState>(
                  builder: (context, savingsState) {
                    final total = savingsState is SavingsLoaded
                        ? (savingsState.summary?.totalSaved ?? 0.0)
                        : 0.0;
                    return StatCard(
                      title: 'Metas',
                      value: CurrencyFormatter.format(total),
                      icon: Icons.savings_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      onTap: () => context.push('/savings'),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  label: 'Nova Saída',
                  icon: Icons.arrow_downward_rounded,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () => context.push('/transactions/new'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  label: 'Nova Entrada',
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => showIncomeFormDialog(context),
                ),
              ),
            ],
          ),
          if (data.monthlyChart.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Evolução Mensal',
              actionText: 'Ver relatórios',
              onAction: () => context.push('/reports'),
            ),
            const SizedBox(height: 12),
            MonthlyLineChart(data: data.monthlyChart),
          ],
          if (data.upcomingBills.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Próximas Contas',
              actionText: 'Ver todas',
              onAction: () => context.push('/bills'),
            ),
            const SizedBox(height: 12),
            UpcomingBillsSection(bills: data.upcomingBills),
          ],
          if (data.topCategories.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Gastos por Categoria',
              actionText: 'Ver relatório',
              onAction: () => context.push('/reports'),
            ),
            const SizedBox(height: 12),
            CategorySpendingSection(
              categories: data.topCategories,
              totalExpense: data.totalExpense,
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
