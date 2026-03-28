import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/projections/projections_cubit.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../../core/utils/currency_formatter.dart';

class ProjectionsPage extends StatefulWidget {
  const ProjectionsPage({super.key});

  @override
  State<ProjectionsPage> createState() => _ProjectionsPageState();
}

class _ProjectionsPageState extends State<ProjectionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectionsCubit>().load();
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proje\u00e7\u00f5es',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Previs\u00e3o de gastos futuros',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ProjectionsCubit, ProjectionsState>(
              builder: (context, state) {
                if (state is ProjectionsLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 6);
                }
                if (state is ProjectionsError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<ProjectionsCubit>().load(),
                  );
                }
                if (state is ProjectionsLoaded) {
                  return _buildContent(context, state, theme);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ProjectionsLoaded state, ThemeData theme) {
    final months = state.projectedMonths;
    final transactions = state.transactions;

    if (months.isEmpty && transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text('Nenhuma proje\u00e7\u00e3o dispon\u00edvel',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Text('Adicione transa\u00e7\u00f5es com parcelas ou recorrentes',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final maxDebit = months.fold(
        0.0,
        (m, d) =>
            (d['projected_debit'] as num).toDouble() > m
                ? (d['projected_debit'] as num).toDouble()
                : m);
    final maxIncome = months.fold(
        0.0,
        (m, d) =>
            (d['projected_income'] as num).toDouble() > m
                ? (d['projected_income'] as num).toDouble()
                : m);
    final chartMax = ((maxDebit > maxIncome ? maxDebit : maxIncome) * 1.2)
        .ceilToDouble();

    return RefreshIndicator(
      onRefresh: () async => context.read<ProjectionsCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Gasto Este M\u00eas',
                  value: CurrencyFormatter.format(state.currentMonthDebit),
                  icon: Icons.arrow_upward,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Renda Mensal',
                  value: CurrencyFormatter.format(state.monthlyRecurringIncome),
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (months.isNotEmpty)
            _MonthlyProjectionChart(
              months: months,
              chartMax: chartMax,
              theme: theme,
            ),
          const SizedBox(height: 16),
          if (transactions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Compromissos Futuros',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ...transactions.map((tx) => _TransactionProjectionCard(
                  tx: tx,
                  theme: theme,
                )),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _MonthlyProjectionChart extends StatelessWidget {
  final List<Map<String, dynamic>> months;
  final double chartMax;
  final ThemeData theme;

  const _MonthlyProjectionChart({
    required this.months,
    required this.chartMax,
    required this.theme,
  });

  String _monthAbbr(int month) {
    const abbrs = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return abbrs[(month - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proje\u00e7\u00e3o Mensal \u2014 6 meses',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Legend(
                  color: const Color(0xFF10B981),
                  label: 'Renda (recorrente)'),
              const SizedBox(width: 12),
              _Legend(
                  color: theme.colorScheme.error,
                  label: 'D\u00e9bito projetado'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: chartMax > 0 ? chartMax : 1000,
                minY: 0,
                groupsSpace: 8,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) {
                      final isIncome =
                          rod.color == const Color(0xFF10B981).withValues(alpha: 0.85);
                      final label = isIncome ? 'Renda' : 'D\u00e9bito';
                      return BarTooltipItem(
                        '$label\n${CurrencyFormatter.format(rod.toY)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          CurrencyFormatter.formatCompact(value),
                          style: TextStyle(
                              fontSize: 9,
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= months.length) {
                          return const SizedBox.shrink();
                        }
                        final monthKey = months[idx]['month'] as String;
                        final parts = monthKey.split('-');
                        final abbr =
                            _monthAbbr(int.tryParse(parts[1]) ?? 1);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            abbr,
                            style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
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
                barGroups: months.asMap().entries.map((e) {
                  final idx = e.key;
                  final m = e.value;
                  final income =
                      (m['projected_income'] as num).toDouble();
                  final debit =
                      (m['projected_debit'] as num).toDouble();
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: income,
                        color: const Color(0xFF10B981)
                            .withValues(alpha: 0.85),
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: debit,
                        color: theme.colorScheme.error
                            .withValues(alpha: 0.85),
                        width: 10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _TransactionProjectionCard extends StatelessWidget {
  final Map<String, dynamic> tx;
  final ThemeData theme;

  const _TransactionProjectionCard(
      {required this.tx, required this.theme});

  Color _colorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecurring = tx['is_recurring'] as bool;
    final remaining = tx['remaining_installments'] as int?;
    final total = tx['total_installments'] as int;
    final amountPerMonth = (tx['amount_per_month'] as num).toDouble();
    final catColor = tx['category_color'] != null
        ? _colorFromHex(tx['category_color'] as String)
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isRecurring ? Icons.autorenew : Icons.credit_card,
                color: catColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx['title'] as String,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isRecurring
                        ? 'Recorrente \u00b7 ${tx['bank_name']}'
                        : remaining != null
                            ? '$remaining de $total parcelas restantes \u00b7 ${tx['bank_name']}'
                            : '$total parcelas \u00b7 ${tx['bank_name']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(amountPerMonth),
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error),
                ),
                Text(
                  'por m\u00eas',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
