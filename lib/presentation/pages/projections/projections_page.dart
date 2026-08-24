import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/projections/projections_cubit.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/empty_state_widget.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/page_header.dart';
import 'widgets/summary_card.dart';
import 'widgets/monthly_projection_chart.dart';
import 'widgets/transaction_projection_card.dart';

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
          const PageHeader(
              title: 'Projeções', showBackButton: true, bottomPadding: 16),
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
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        title: 'Nenhuma projeção disponível',
        subtitle: 'Adicione transações com parcelas ou recorrentes',
      );
    }

    final maxDebit = months.fold(
        0.0,
        (m, d) => (d['projected_debit'] as num).toDouble() > m
            ? (d['projected_debit'] as num).toDouble()
            : m);
    final maxIncome = months.fold(
        0.0,
        (m, d) => (d['projected_income'] as num).toDouble() > m
            ? (d['projected_income'] as num).toDouble()
            : m);
    final chartMax =
        ((maxDebit > maxIncome ? maxDebit : maxIncome) * 1.2).ceilToDouble();

    return RefreshIndicator(
      onRefresh: () async => context.read<ProjectionsCubit>().load(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  label: 'Gasto Este Mês',
                  value: CurrencyFormatter.format(state.currentMonthDebit),
                  icon: Icons.arrow_upward,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
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
            MonthlyProjectionChart(months: months, chartMax: chartMax),
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
            ...transactions.map((tx) => TransactionProjectionCard(tx: tx)),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
