import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/dashboard/dashboard_cubit.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/page_header.dart';
import '../../../core/theme/app_tokens.dart';

class ReportCategoryPage extends StatefulWidget {
  const ReportCategoryPage({super.key});

  @override
  State<ReportCategoryPage> createState() => _ReportCategoryPageState();
}

class _ReportCategoryPageState extends State<ReportCategoryPage> {
  DateTime _selectedMonth = DateTime.now();
  int _touchedIndex = -1;

  void _loadData() {
    context
        .read<DashboardCubit>()
        .load(month: DateFormatter.monthKey(_selectedMonth));
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          const PageHeader(
              title: 'Gastos por Categoria',
              showBackButton: true,
              bottomPadding: 16),
          MonthSelector(
            selectedMonth: _selectedMonth,
            onChanged: (d) {
              setState(() => _selectedMonth = d);
              _loadData();
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 5);
                }
                if (state is DashboardError) {
                  return AppErrorWidget(
                      message: state.message, onRetry: _loadData);
                }
                if (state is DashboardLoaded) {
                  final cats = state.data.topCategories;
                  if (cats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pie_chart_outline,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text('Sem dados para este mês',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  final total = cats.fold(0.0, (s, c) => s + c.amount);
                  final colors = [
                    theme.colorScheme.primary,
                    const Color(0xFF3B82F6),
                    const Color(0xFF10B981),
                    const Color(0xFFF59E0B),
                    const Color(0xFF8B5CF6),
                    const Color(0xFFEF4444),
                    const Color(0xFF06B6D4),
                    const Color(0xFFEC4899),
                  ];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Pie chart
                        Container(
                          height: 260,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    _touchedIndex = response?.touchedSection
                                            ?.touchedSectionIndex ??
                                        -1;
                                  });
                                },
                              ),
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              sections: List.generate(cats.length, (i) {
                                final cat = cats[i];
                                final isTouched = i == _touchedIndex;
                                final pct = total > 0
                                    ? (cat.amount / total * 100)
                                    : 0.0;
                                return PieChartSectionData(
                                  color: colors[i % colors.length],
                                  value: cat.amount,
                                  title: isTouched
                                      ? '${pct.toStringAsFixed(1)}%'
                                      : '',
                                  radius: isTouched ? 60 : 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Category list
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            children: cats.asMap().entries.map((entry) {
                              final i = entry.key;
                              final cat = entry.value;
                              final pct =
                                  total > 0 ? (cat.amount / total * 100) : 0.0;
                              return Column(
                                children: [
                                  if (i > 0)
                                    Divider(
                                        height: 1,
                                        indent: 60,
                                        color: theme.colorScheme.outlineVariant
                                            .withValues(alpha: 0.3)),
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: colors[i % colors.length]
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.md),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color:
                                                    colors[i % colors.length],
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(cat.name,
                                                  style: theme
                                                      .textTheme.bodyMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              ClipRRect(
                                                borderRadius: BorderRadius
                                                    .circular(AppRadius.xs),
                                                child: LinearProgressIndicator(
                                                  value: pct / 100,
                                                  minHeight: 4,
                                                  color:
                                                      colors[i % colors.length],
                                                  backgroundColor:
                                                      colors[i % colors.length]
                                                          .withValues(
                                                              alpha: 0.1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              CurrencyFormatter.format(
                                                  cat.amount),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                            ),
                                            Text(
                                              '${pct.toStringAsFixed(1)}%',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color:
                                                    colors[i % colors.length],
                                                fontWeight: FontWeight.w600,
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
}
