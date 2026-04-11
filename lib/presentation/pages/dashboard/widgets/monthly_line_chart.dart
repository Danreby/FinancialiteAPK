import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/entities/dashboard.dart';

class MonthlyLineChart extends StatelessWidget {
  final List<MonthlyChartData> data;
  const MonthlyLineChart({super.key, required this.data});

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
    'Dez',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final creditColor = const Color(0xFF10B981);
    final debitColor = theme.colorScheme.error;

    final chartData = data.length > 6 ? data.sublist(data.length - 6) : data;
    double maxVal = 0;
    for (final d in chartData) {
      if (d.income > maxVal) maxVal = d.income;
      if (d.expense > maxVal) maxVal = d.expense;
    }
    maxVal = maxVal == 0 ? 1000 : (maxVal * 1.25);

    final creditSpots = <FlSpot>[];
    final debitSpots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      creditSpots
          .add(FlSpot(i.toDouble(), chartData[i].income.clamp(0, maxVal)));
      debitSpots
          .add(FlSpot(i.toDouble(), chartData[i].expense.clamp(0, maxVal)));
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
                        if (i < 0 || i >= chartData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _monthLabel(chartData[i].month),
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
                  _buildLine(creditSpots, creditColor, theme),
                  _buildLine(debitSpots, debitColor, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(
      List<FlSpot> spots, Color color, ThemeData theme) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
          radius: 3.5,
          color: color,
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
            color.withValues(
                alpha: color == const Color(0xFF10B981) ? 0.18 : 0.12),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  String _monthLabel(String monthStr) {
    final parts = monthStr.split('-');
    if (parts.length == 2) {
      final idx = (int.parse(parts[1]) - 1).clamp(0, 11);
      return _months[idx];
    }
    return monthStr;
  }
}
