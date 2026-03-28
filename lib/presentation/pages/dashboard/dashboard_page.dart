import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/gradient_card.dart';
import '../../widgets/section_header.dart';
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
      body: RefreshIndicator(
        onRefresh: () async {
          final monthKey = DateFormatter.monthKey(_selectedMonth);
          await context.read<DashboardCubit>().refresh(month: monthKey);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Custom Header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visão Geral',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: theme.colorScheme.onSurface,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Month Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: MonthSelector(
                  selectedMonth: _selectedMonth,
                  onChanged: (date) {
                    setState(() => _selectedMonth = date);
                    _loadData();
                  },
                ),
              ),
            ),
            // Content
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Hero Balance Card with Gradient
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GradientCard(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.85),
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo do Mês',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            data.balance >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            data.balance >= 0 ? 'Positivo' : 'Negativo',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.format(data.balance),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Income vs Expense row
                Row(
                  children: [
                    Expanded(
                      child: _BalanceRow(
                        label: 'Receitas',
                        value: CurrencyFormatter.format(data.totalIncome),
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _BalanceRow(
                        label: 'Despesas',
                        value: CurrencyFormatter.format(data.totalExpense),
                        icon: Icons.arrow_downward_rounded,
                        color: const Color(0xFFFB7185),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Credit (pending invoice) vs Debit (month total) row
                Row(
                  children: [
                    Expanded(
                      child: _BalanceRow(
                        label: 'Crédito',
                        value: CurrencyFormatter.format(data.pendingBillAmount),
                        icon: Icons.credit_card_rounded,
                        color: const Color(0xFF60A5FA),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _BalanceRow(
                        label: 'Débito',
                        value: CurrencyFormatter.format(data.monthDebitTotal),
                        icon: Icons.account_balance_rounded,
                        color: const Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Quick Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
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
                child: StatCard(
                  title: 'Economias',
                  value: CurrencyFormatter.format(data.savingsTotal),
                  icon: Icons.savings_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  onTap: () => context.push('/savings'),
                ),
              ),
            ],
          ),
        ),
        // Monthly Chart
        if (data.monthlyChart.isNotEmpty) ...[
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Evolução Mensal',
            actionText: 'Ver relatórios',
            onAction: () => context.push('/reports'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _MonthlyLineChart(data: data.monthlyChart),
          ),
        ],
        // Upcoming Bills
        if (data.upcomingBills.isNotEmpty) ...[
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Próximas Contas',
            actionText: 'Ver todas',
            onAction: () => context.push('/bills'),
          ),
          const SizedBox(height: 12),
          ...data.upcomingBills.take(4).map((bill) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Vence dia ${bill.dueDay}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(bill.amount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
        // Category Spending
        if (data.topCategories.isNotEmpty) ...[
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Gastos por Categoria',
            actionText: 'Ver relatório',
            onAction: () => context.push('/reports'),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: data.topCategories.take(5).map((cat) {
                  final percent = data.totalExpense > 0
                      ? (cat.amount / data.totalExpense * 100)
                      : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                    alpha: 1.0 -
                                        (data.topCategories.indexOf(cat) *
                                            0.15)),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(cat.amount),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${percent.toStringAsFixed(0)}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BalanceRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthlyLineChart extends StatelessWidget {
  final List data;
  const _MonthlyLineChart({required this.data});

  static const _months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final creditColor = const Color(0xFF10B981);
    final debitColor = theme.colorScheme.error;

    final chartData = data.length > 6 ? data.sublist(data.length - 6) : data;
    double maxVal = 0;
    for (final d in chartData) {
      final m = d as dynamic;
      if ((m.income as double) > maxVal) maxVal = m.income as double;
      if ((m.expense as double) > maxVal) maxVal = m.expense as double;
    }
    maxVal = maxVal == 0 ? 1000 : (maxVal * 1.25);

    final creditSpots = <FlSpot>[];
    final debitSpots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      final m = chartData[i] as dynamic;
      creditSpots
          .add(FlSpot(i.toDouble(), (m.income as double).clamp(0, maxVal)));
      debitSpots
          .add(FlSpot(i.toDouble(), (m.expense as double).clamp(0, maxVal)));
    }

    String _monthLabel(String monthStr) {
      final parts = monthStr.split('-');
      if (parts.length == 2) {
        final idx = (int.parse(parts[1]) - 1).clamp(0, 11);
        return _months[idx];
      }
      return monthStr;
    }

    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: creditColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text('Crédito',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 16),
              Container(
                width: 28,
                height: 3,
                decoration: BoxDecoration(
                  color: debitColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text('Débito',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxVal,
                clipData: const FlClipData.all(),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        theme.colorScheme.surfaceContainerHighest,
                    getTooltipItems: (spots) => spots.map((s) {
                      final isCredit = s.barIndex == 0;
                      return LineTooltipItem(
                        CurrencyFormatter.format(s.y),
                        theme.textTheme.labelSmall!.copyWith(
                          color: isCredit ? creditColor : debitColor,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: theme.colorScheme.outlineVariant
                        .withValues(alpha: 0.25),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= chartData.length)
                          return const SizedBox.shrink();
                        final m = (chartData[i] as dynamic).month as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _monthLabel(m),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  // Credit line
                  LineChartBarData(
                    spots: creditSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: creditColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: creditColor,
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          creditColor.withValues(alpha: 0.18),
                          creditColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                  // Debit line
                  LineChartBarData(
                    spots: debitSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: debitColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: debitColor,
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          debitColor.withValues(alpha: 0.12),
                          debitColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
