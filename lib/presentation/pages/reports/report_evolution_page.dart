import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/page_header.dart';

class ReportEvolutionPage extends StatefulWidget {
  const ReportEvolutionPage({super.key});

  @override
  State<ReportEvolutionPage> createState() => _ReportEvolutionPageState();
}

class _ReportEvolutionPageState extends State<ReportEvolutionPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const PageHeader(
              title: 'Evolução Patrimonial',
              showBackButton: true,
              bottomPadding: 16),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 5);
                }
                if (state is DashboardError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<DashboardCubit>().load(),
                  );
                }
                if (state is DashboardLoaded) {
                  final chart = state.data.monthlyChart;
                  if (chart.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_up,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('Sem dados disponíveis',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  // Build cumulative balance evolution
                  double cumulative = 0;
                  final points = chart.map((d) {
                    cumulative += d.income - d.expense;
                    return cumulative;
                  }).toList();

                  final minY = points.fold(0.0, (m, v) => v < m ? v : m);
                  final maxY = points.fold(0.0, (m, v) => v > m ? v : m);
                  final range = (maxY - minY).abs();
                  final paddedMin = minY - range * 0.1;
                  final paddedMax = maxY + range * 0.1;

                  final latestBalance = points.isNotEmpty ? points.last : 0.0;
                  final prevBalance =
                      points.length > 1 ? points[points.length - 2] : 0.0;
                  final monthGrowth = prevBalance != 0
                      ? ((latestBalance - prevBalance) /
                          prevBalance.abs() *
                          100)
                      : 0.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Summary card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary
                                    .withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patrimônio Acumulado',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                CurrencyFormatter.format(latestBalance),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (monthGrowth != 0) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${monthGrowth >= 0 ? '▲' : '▼'} ${monthGrowth.abs().toStringAsFixed(1)}% vs mês anterior',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Line Chart
                        Container(
                          height: 240,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5)),
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
                          child: LineChart(
                            LineChartData(
                              minY: paddedMin,
                              maxY: paddedMax.isNaN || paddedMax == 0
                                  ? 1000
                                  : paddedMax,
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipRoundedRadius: 8,
                                  getTooltipItems: (spots) => spots.map((spot) {
                                    final idx = spot.x.toInt();
                                    final monthLabel =
                                        idx >= 0 && idx < chart.length
                                            ? DateFormatter.shortMonthFromKey(
                                                chart[idx].month)
                                            : '';
                                    return LineTooltipItem(
                                      '$monthLabel\n${CurrencyFormatter.format(spot.y)}',
                                      TextStyle(
                                        color: spot.y >= 0
                                            ? const Color(0xFF10B981)
                                            : theme.colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= chart.length)
                                        return const SizedBox();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          DateFormatter.shortMonthFromKey(
                                              chart[idx].month),
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: theme.colorScheme
                                                  .onSurfaceVariant),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 56,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0) return const SizedBox();
                                      return Text(
                                        CurrencyFormatter.formatCompact(value),
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: theme
                                                .colorScheme.onSurfaceVariant),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: points
                                      .asMap()
                                      .entries
                                      .map((e) =>
                                          FlSpot(e.key.toDouble(), e.value))
                                      .toList(),
                                  isCurved: true,
                                  curveSmoothness: 0.35,
                                  color: theme.colorScheme.primary,
                                  barWidth: 2.5,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, _, __, ___) =>
                                        FlDotCirclePainter(
                                      radius: 3,
                                      color: theme.colorScheme.primary,
                                      strokeWidth: 2,
                                      strokeColor: theme.colorScheme.surface,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary
                                            .withValues(alpha: 0.15),
                                        theme.colorScheme.primary
                                            .withValues(alpha: 0.01),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Monthly breakdown
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: chart
                                .asMap()
                                .entries
                                .toList()
                                .reversed
                                .take(6)
                                .toList()
                                .asMap()
                                .entries
                                .map((outerEntry) {
                              final idx = outerEntry.value.key;
                              final d = outerEntry.value.value;
                              final bal = points[idx];
                              final isPositive = bal >= 0;
                              final isFirst = outerEntry.key == 0;
                              return Column(
                                children: [
                                  if (!isFirst)
                                    Divider(
                                        height: 1,
                                        indent: 16,
                                        color: theme.colorScheme.outlineVariant
                                            .withValues(alpha: 0.3)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: (isPositive
                                                    ? const Color(0xFF10B981)
                                                    : theme.colorScheme.error)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            isPositive
                                                ? Icons.trending_up
                                                : Icons.trending_down,
                                            size: 20,
                                            color: isPositive
                                                ? const Color(0xFF10B981)
                                                : theme.colorScheme.error,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            DateFormatter.monthYearFromKey(
                                                d.month),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(bal),
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isPositive
                                                ? const Color(0xFF10B981)
                                                : theme.colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 32),
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
