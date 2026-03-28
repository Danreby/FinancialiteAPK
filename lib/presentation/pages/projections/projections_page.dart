import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class ProjectionsPage extends StatefulWidget {
  const ProjectionsPage({super.key});

  @override
  State<ProjectionsPage> createState() => _ProjectionsPageState();
}

class _ProjectionsPageState extends State<ProjectionsPage> {
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
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new, size: 18, color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projeções',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Baseado no histórico financeiro',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const AppLoadingIndicator(useShimmer: true, shimmerLines: 5);
                }
                if (state is DashboardError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<DashboardCubit>().load(),
                  );
                }
                if (state is DashboardLoaded) {
                  final data = state.data;
                  final chart = data.monthlyChart;

                  if (chart.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.show_chart, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('Dados insuficientes para projeção', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 6),
                          Text('Registre transações por pelo menos 2 meses', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  // Calculate averages from last 3 months
                  final recent = chart.length >= 3 ? chart.sublist(chart.length - 3) : chart;
                  final avgIncome = recent.fold(0.0, (s, d) => s + d.income) / recent.length;
                  final avgExpense = recent.fold(0.0, (s, d) => s + d.expense) / recent.length;
                  final avgSaving = avgIncome - avgExpense;
                  final savingRate = avgIncome > 0 ? (avgSaving / avgIncome * 100) : 0.0;

                  // Generate 6-month projections
                  final now = DateTime.now();
                  final projectedMonths = List.generate(6, (i) {
                    final date = DateTime(now.year, now.month + i + 1, 1);
                    return date;
                  });

                  double projectedBalance = data.totalBalance;
                  final projectionPoints = projectedMonths.map((date) {
                    projectedBalance += avgSaving;
                    return projectedBalance;
                  }).toList();

                  // Historical points for context
                  double cumulative = data.totalBalance - chart.fold(0.0, (s, d) => s + (d.income - d.expense));
                  final histPoints = chart.map((d) {
                    cumulative += d.income - d.expense;
                    return cumulative;
                  }).toList();

                  final allValues = [...histPoints, ...projectionPoints];
                  final maxVal = allValues.fold(0.0, (m, v) => v > m ? v : m);
                  final minVal = allValues.fold(0.0, (m, v) => v < m ? v : m);
                  final valRange = (maxVal - minVal).abs();
                  final paddedMin = minVal - valRange * 0.1;
                  final paddedMax = maxVal + valRange * 0.1;

                  final histOffset = histPoints.length.toDouble();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Health score card
                        _buildHealthCard(data.healthScore, theme),
                        const SizedBox(height: 16),
                        // Averages summary
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                'Receita Média',
                                CurrencyFormatter.format(avgIncome),
                                Icons.arrow_downward,
                                const Color(0xFF10B981),
                                'por mês',
                                theme,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSummaryItem(
                                'Gasto Médio',
                                CurrencyFormatter.format(avgExpense),
                                Icons.arrow_upward,
                                theme.colorScheme.error,
                                'por mês',
                                theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                'Poupança Média',
                                CurrencyFormatter.format(avgSaving.abs()),
                                avgSaving >= 0 ? Icons.savings : Icons.warning,
                                avgSaving >= 0 ? const Color(0xFF10B981) : theme.colorScheme.error,
                                avgSaving >= 0 ? 'por mês' : 'déficit',
                                theme,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildSummaryItem(
                                'Taxa de Poupança',
                                '${savingRate.toStringAsFixed(1)}%',
                                Icons.percent,
                                savingRate >= 20
                                    ? const Color(0xFF10B981)
                                    : savingRate >= 10
                                        ? Colors.amber
                                        : theme.colorScheme.error,
                                savingRate >= 20 ? 'excelente' : savingRate >= 10 ? 'regular' : 'baixa',
                                theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Projection chart
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Projeção de Patrimônio — 6 meses',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Linha sólida = histórico  |  Linha pontilhada = projeção',
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: LineChart(
                                  LineChartData(
                                    minY: paddedMin,
                                    maxY: paddedMax.isNaN ? 1000 : paddedMax,
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 56,
                                          getTitlesWidget: (value, meta) => Text(
                                            CurrencyFormatter.formatCompact(value),
                                            style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurfaceVariant),
                                          ),
                                        ),
                                      ),
                                    ),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (_) => FlLine(
                                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      // Historical line (solid)
                                      LineChartBarData(
                                        spots: histPoints.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                        isCurved: true,
                                        curveSmoothness: 0.3,
                                        color: theme.colorScheme.primary,
                                        barWidth: 2.5,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary.withValues(alpha: 0.12),
                                              theme.colorScheme.primary.withValues(alpha: 0.01),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                      // Projection line (dashed effect - lighter color)
                                      LineChartBarData(
                                        spots: projectionPoints.asMap().entries
                                            .map((e) => FlSpot(histOffset - 1 + e.key.toDouble(), e.value))
                                            .toList(),
                                        isCurved: true,
                                        curveSmoothness: 0.3,
                                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                        barWidth: 2,
                                        isStrokeCapRound: true,
                                        dashArray: [6, 4],
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                                            radius: 2.5,
                                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                            strokeWidth: 0,
                                            strokeColor: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Projected months table
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                                child: Text(
                                  'Patrimônio Projetado',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                              ...projectedMonths.asMap().entries.map((entry) {
                                final i = entry.key;
                                final date = entry.value;
                                final projected = projectionPoints[i];
                                final isPositive = projected >= 0;
                                return Column(
                                  children: [
                                    if (i > 0)
                                      Divider(height: 1, indent: 16, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: (isPositive ? const Color(0xFF10B981) : theme.colorScheme.error).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${i + 1}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: isPositive ? const Color(0xFF10B981) : theme.colorScheme.error,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              DateFormatter.formatMonthYear(date),
                                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          Text(
                                            CurrencyFormatter.format(projected),
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isPositive ? const Color(0xFF10B981) : theme.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
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

  Widget _buildHealthCard(double score, ThemeData theme) {
    Color scoreColor;
    String scoreLabel;
    if (score >= 80) {
      scoreColor = const Color(0xFF10B981);
      scoreLabel = 'Excelente';
    } else if (score >= 60) {
      scoreColor = Colors.amber;
      scoreLabel = 'Bom';
    } else if (score >= 40) {
      scoreColor = Colors.orange;
      scoreLabel = 'Regular';
    } else {
      scoreColor = theme.colorScheme.error;
      scoreLabel = 'Atenção';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 24,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: score,
                        color: scoreColor,
                        radius: 10,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: 100 - score,
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        radius: 10,
                        title: '',
                      ),
                    ],
                  ),
                ),
                Text(
                  '${score.toInt()}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saúde Financeira',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scoreLabel,
                    style: TextStyle(color: scoreColor, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  score >= 60
                      ? 'Suas finanças estão bem controladas!'
                      : 'Atenção: revise seus gastos mensais.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color, String sub, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: color)),
          Text(sub, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}
