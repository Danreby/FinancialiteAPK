import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_money_style.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Editorial-ledger stat row: label + large tabular number, separated by a
/// hairline divider -- no box, no icon badge, no shadow. Deliberately reads
/// like a line in a statement/ledger rather than a dashboard "stat card".
class LedgerStatRow extends StatelessWidget {
  final String label;
  final double value;
  /// When set, renders this plain text instead of formatting [value] as
  /// money -- used for count-based rows (e.g. "5 faturas").
  final String? valueText;
  final String? trailingText;
  final Color? trailingColor;
  final VoidCallback? onTap;
  final TextStyle moneyStyle;
  final Color? valueColor;

  const LedgerStatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueText,
    this.trailingText,
    this.trailingColor,
    this.onTap,
    this.moneyStyle = AppMoneyStyle.large,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: appColors.divider, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: appColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  valueText != null
                      ? Text(
                          valueText!,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: appColors.onSurface,
                            letterSpacing: -0.3,
                          ),
                        )
                      : Text.rich(
                          AppMoneyStyle.rich(
                            amount: CurrencyFormatter.toInputFormat(value),
                            style: moneyStyle,
                            digitColor: valueColor ?? appColors.onSurface,
                            symbolColor: (valueColor ?? appColors.onSurfaceVariant)
                                .withValues(alpha: valueColor != null ? 0.75 : 1),
                          ),
                        ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: trailingColor ?? appColors.onSurfaceVariant,
                ),
              )
            else if (onTap != null)
              Icon(Icons.arrow_forward_rounded, size: 18, color: appColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Two ledger rows sharing one line -- used for Crédito/Débito, which read
/// as a pair rather than each needing its own full-width row.
class LedgerStatPairRow extends StatelessWidget {
  final String leftLabel;
  final double leftValue;
  final String rightLabel;
  final double rightValue;
  /// Overrides the formatted-money display with plain text (e.g. counts).
  final String? leftValueText;
  final String? rightValueText;
  /// When set, the whole column becomes tappable and shows an inline arrow
  /// next to its label -- used for pairs that are navigational shortcuts
  /// (e.g. Contas a pagar / Metas) rather than plain read-only figures.
  final VoidCallback? leftOnTap;
  final VoidCallback? rightOnTap;

  const LedgerStatPairRow({
    super.key,
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    this.leftValueText,
    this.rightValueText,
    this.leftOnTap,
    this.rightOnTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    Widget column(
      String label,
      double value, {
      String? valueText,
      VoidCallback? onTap,
    }) {
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: appColors.onSurfaceVariant,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 11, color: appColors.onSurfaceVariant),
              ],
            ],
          ),
          const SizedBox(height: 4),
          valueText != null
              ? Text(
                  valueText,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: appColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                )
              : Text.rich(
                  AppMoneyStyle.rich(
                    amount: CurrencyFormatter.toInputFormat(value),
                    style: AppMoneyStyle.medium,
                    digitColor: appColors.onSurface,
                    symbolColor: appColors.onSurfaceVariant,
                  ),
                ),
        ],
      );

      return Expanded(
        child: onTap != null
            ? InkWell(onTap: onTap, child: content)
            : content,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          column(leftLabel, leftValue, valueText: leftValueText, onTap: leftOnTap),
          column(rightLabel, rightValue, valueText: rightValueText, onTap: rightOnTap),
        ],
      ),
    );
  }
}
