import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_money_style.dart';
import '../../../widgets/ledger_row.dart';
import 'bento_stat_tile.dart';

/// The dashboard's single overview block: the month's balance headline
/// flows directly into the "Resumo do Mês" figures and, at the bottom, the
/// Entrada/Saída actions -- one continuous editorial-ledger read instead of
/// three separate components competing for the same top-of-page attention.
class DashboardBalanceCard extends StatelessWidget {
  final double balance;
  final double despesas;
  final double credito;
  final double debito;
  final int pendingBillsCount;
  final double metasTotal;
  final VoidCallback onNewIncome;
  final VoidCallback onNewExpense;
  final VoidCallback onTapContas;
  final VoidCallback onTapMetas;

  const DashboardBalanceCard({
    super.key,
    required this.balance,
    required this.despesas,
    required this.credito,
    required this.debito,
    required this.pendingBillsCount,
    required this.metasTotal,
    required this.onNewIncome,
    required this.onNewExpense,
    required this.onTapContas,
    required this.onTapMetas,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    final isPositive = balance >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SALDO DO MÊS',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: appColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: balance),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutExpo,
          builder: (context, animatedValue, _) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text.rich(
                AppMoneyStyle.rich(
                  amount: CurrencyFormatter.toInputFormat(animatedValue),
                  style: AppMoneyStyle.hero.copyWith(fontSize: 52),
                  digitColor: appColors.onSurface,
                  symbolColor: appColors.onSurfaceVariant,
                ),
                maxLines: 1,
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Container(width: 56, height: 3, color: appColors.accent),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 15,
              color: isPositive ? appColors.income : appColors.expense,
            ),
            const SizedBox(width: 6),
            Text(
              isPositive ? 'Fluxo Positivo' : 'Fluxo Negativo',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: appColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const LedgerSectionLabel(title: 'Resumo do Mês'),
        const SizedBox(height: 4),
        // Despesas leads the summary and carries the expense tint -- it's
        // the direct counterpart to the balance above, so it earns the
        // same visual weight as a standalone row rather than sharing a
        // line with anything else.
        LedgerStatRow(
          label: 'Despesas',
          value: despesas,
          valueColor: appColors.expense,
        ),
        LedgerStatPairRow(
          leftLabel: 'Crédito',
          leftValue: credito,
          rightLabel: 'Débito',
          rightValue: debito,
        ),
        LedgerStatPairRow(
          leftLabel: 'Contas a pagar',
          leftValue: 0,
          leftValueText: '$pendingBillsCount faturas',
          leftOnTap: onTapContas,
          rightLabel: 'Metas',
          rightValue: metasTotal,
          rightOnTap: onTapMetas,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _FlatActionButton(
                label: 'Entrada',
                icon: Icons.north_east_rounded,
                iconColor: appColors.income,
                onTap: onNewIncome,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FlatActionButton(
                label: 'Saída',
                icon: Icons.south_west_rounded,
                iconColor: appColors.expense,
                onTap: onNewExpense,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Flat action button -- no shadow, just a hairline border and a solid
/// fill, matching the rest of the editorial-ledger surface.
class _FlatActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _FlatActionButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return Material(
      color: appColors.surfaceVariant,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: appColors.divider, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: appColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
