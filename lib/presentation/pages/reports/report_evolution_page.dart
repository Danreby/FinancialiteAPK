import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/page_header.dart';
import 'widgets/evolution_summary_card.dart';
import 'widgets/evolution_line_chart.dart';
import 'widgets/evolution_month_list.dart';

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
                        EvolutionSummaryCard(
                          latestBalance: latestBalance,
                          monthGrowth: monthGrowth,
                        ),
                        const SizedBox(height: 16),
                        EvolutionLineChart(
                          points: points,
                          chart: chart,
                          paddedMin: paddedMin,
                          paddedMax: paddedMax,
                        ),
                        const SizedBox(height: 20),
                        EvolutionMonthList(chart: chart, points: points),
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
