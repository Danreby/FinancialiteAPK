import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_money_style.dart';
import '../../../../domain/entities/dashboard.dart';

class DashboardBalanceCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final double pendingBillAmount;
  final double monthDebitTotal;
  final List<MonthlyChartData> trend;

  const DashboardBalanceCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
    required this.pendingBillAmount,
    required this.monthDebitTotal,
    this.trend = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    final isPositive = balance >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: appColors.heroGradient,
          borderRadius: AppRadius.cardCut(),
          boxShadow: AppShadows.cardBold(appColors.primary),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.cardCut(),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo do Mês',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (isPositive
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFF87171))
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: (isPositive
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFF87171))
                                  .withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPositive
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                size: 12,
                                color: isPositive
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFF87171),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPositive ? 'Positivo' : 'Negativo',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isPositive
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFF87171),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Balance amount (animated count-up) + inline trend sparkline
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: balance),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutExpo,
                            builder: (context, animatedValue, _) {
                              // FittedBox/scaleDown so amounts with more
                              // digits (e.g. "R$ 1.000,00") shrink to fit
                              // this row instead of overflowing and being
                              // clipped away entirely at the 44px hero size.
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text.rich(
                                    AppMoneyStyle.rich(
                                      amount: CurrencyFormatter.toInputFormat(
                                          animatedValue),
                                      style: AppMoneyStyle.hero,
                                      digitColor: Colors.white,
                                      symbolColor:
                                          Colors.white.withValues(alpha: 0.7),
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (trend.length >= 2) ...[
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 64,
                            height: 28,
                            child: _TrendSparkline(trend: trend),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Divider
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: 18),
                    // Stats grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _BalanceStat(
                                label: 'Receitas',
                                value: totalIncome,
                                icon: Icons.arrow_upward_rounded,
                                color: const Color(0xFF34D399),
                              ),
                            ),
                            _Divider(),
                            Expanded(
                              child: _BalanceStat(
                                label: 'Despesas',
                                value: totalExpense,
                                icon: Icons.arrow_downward_rounded,
                                color: const Color(0xFFFB7185),
                              ),
                            ),
                            _Divider(),
                            Expanded(
                              child: _BalanceStat(
                                label: 'Crédito',
                                value: pendingBillAmount,
                                icon: Icons.credit_card_rounded,
                                color: const Color(0xFF60A5FA),
                              ),
                            ),
                            _Divider(),
                            Expanded(
                              child: _BalanceStat(
                                label: 'Débito',
                                value: monthDebitTotal,
                                icon: Icons.account_balance_rounded,
                                color: const Color(0xFFFBBF24),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendSparkline extends StatelessWidget {
  final List<MonthlyChartData> trend;
  const _TrendSparkline({required this.trend});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < trend.length; i++)
        FlSpot(i.toDouble(), trend[i].income - trend[i].expense),
    ];
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b),
        maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2,
            color: Colors.white.withValues(alpha: 0.7),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const _BalanceStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, size: 11, color: color),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                AppMoneyStyle.rich(
                  amount: CurrencyFormatter.toInputFormat(value),
                  style: AppMoneyStyle.small,
                  digitColor: Colors.white,
                  symbolColor: Colors.white.withValues(alpha: 0.55),
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
