import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/page_header.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/monthly_summary_list.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const PageHeader(
              title: 'Comparativo Mensal',
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
                        MonthlyBarChart(
                          chart: chart,
                          maxY: maxY,
                          touchedIndex: _touchedIndex,
                          onTouched: (i) => setState(() => _touchedIndex = i),
                        ),
                        const SizedBox(height: 20),
                        MonthlySummaryList(chart: chart),
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
