import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_loading_indicator.dart';

class ReportMonthlyPage extends StatefulWidget {
  const ReportMonthlyPage({super.key});

  @override
  State<ReportMonthlyPage> createState() => _ReportMonthlyPageState();
}

class _ReportMonthlyPageState extends State<ReportMonthlyPage> {
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Load with no month filter to get full monthly_summary data
    context.read<DashboardCubit>().load();
  }

  String _shortMonth(String monthKey) {
    try {
      final date = DateTime.parse('$monthKey-01');
      final months = [
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
      return months[date.month - 1];
    } catch (_) {
      return monthKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 18, color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Comparativo Mensal',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
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
                          Icon(Icons.bar_chart,
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

                  final maxY = chart.fold(
                      0.0,
                      (m, d) => [m, d.income, d.expense]
                          .fold(0.0, (a, b) => a > b ? a : b));

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _legendDot(
                                color: const Color(0xFF10B981),
                                label: 'Receitas'),
                            const SizedBox(width: 20),
                            _legendDot(
                                color: theme.colorScheme.error,
                                label: 'Despesas'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Bar Chart
                        Container(
                          height: 260,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5)),
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
                          child: BarChart(
                            BarChartData(
                              maxY: maxY * 1.2,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipRoundedRadius: 8,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    final d = chart[groupIndex];
                                    final isIncome = rodIndex == 0;
                                    return BarTooltipItem(
                                      '${isIncome ? 'Receita' : 'Despesa'}\n${CurrencyFormatter.format(rod.toY)}',
                                      TextStyle(
                                        color: isIncome
                                            ? const Color(0xFF10B981)
                                            : theme.colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    );
                                  },
                                ),
                                touchCallback: (event, response) {
                                  setState(() {
                                    _touchedIndex =
                                        response?.spot?.touchedBarGroupIndex ??
                                            -1;
                                  });
                                },
                              ),
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= chart.length)
                                        return const SizedBox();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _shortMonth(chart[idx].month),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      );
                                    },
                                    reservedSize: 28,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 48,
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
                              barGroups: List.generate(chart.length, (i) {
                                final d = chart[i];
                                final isTouched = i == _touchedIndex;
                                return BarChartGroupData(
                                  x: i,
                                  groupVertically: false,
                                  barRods: [
                                    BarChartRodData(
                                      toY: d.income,
                                      color: const Color(0xFF10B981),
                                      width: isTouched ? 9 : 7,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                    ),
                                    BarChartRodData(
                                      toY: d.expense,
                                      color: theme.colorScheme.error,
                                      width: isTouched ? 9 : 7,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Monthly summary list
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: chart.reversed.take(6).map((d) {
                              final balance = d.income - d.expense;
                              final isPositive = balance >= 0;
                              final isFirst = chart.reversed.take(6).first == d;
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
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _monthYearLabel(d.month),
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  _miniTag(
                                                      '+${CurrencyFormatter.formatCompact(d.income)}',
                                                      const Color(0xFF10B981),
                                                      theme),
                                                  const SizedBox(width: 6),
                                                  _miniTag(
                                                      '-${CurrencyFormatter.formatCompact(d.expense)}',
                                                      theme.colorScheme.error,
                                                      theme),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${isPositive ? '+' : ''}${CurrencyFormatter.format(balance)}',
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: isPositive
                                                    ? const Color(0xFF10B981)
                                                    : theme.colorScheme.error,
                                              ),
                                            ),
                                            Text(
                                              'saldo do mês',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
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

  Widget _legendDot({required Color color, required String label}) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _miniTag(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  String _monthYearLabel(String monthKey) {
    try {
      final date = DateTime.parse('$monthKey-01');
      return DateFormatter.formatMonthYear(date);
    } catch (_) {
      return monthKey;
    }
  }
}
