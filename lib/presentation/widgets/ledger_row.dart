import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_money_style.dart';
import '../../core/utils/currency_formatter.dart';

/// The app's new universal list-row primitive: title/subtitle on the left,
/// a value (money or plain text) on the right, separated by a hairline
/// divider -- no card box, no shadow, no tinted icon badge. This replaces
/// the earlier "cardCut + DuotoneIconBadge + shadow" pattern everywhere a
/// screen renders a list of financial items (bills, transactions, budgets,
/// goals, accounts, notifications...). An optional leading glyph is allowed
/// for rows where an icon carries real meaning (status, category), but it
/// renders as a plain icon -- no tinted box behind it.
class LedgerRow extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final String? subtitle;
  final Color? subtitleColor;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  /// Money figure for the trailing slot. Mutually exclusive with
  /// [trailingText] -- set one or the other.
  final double? amount;
  final String? amountSign;
  final Color? amountColor;
  final TextStyle amountStyle;
  /// Plain trailing text (status chip text, a count, etc.) when the row
  /// isn't showing a money figure.
  final String? trailingText;
  final Color? trailingTextColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const LedgerRow({
    super.key,
    required this.title,
    this.titleColor,
    this.subtitle,
    this.subtitleColor,
    this.leadingIcon,
    this.leadingIconColor,
    this.amount,
    this.amountSign,
    this.amountColor,
    this.amountStyle = AppMoneyStyle.small,
    this.trailingText,
    this.trailingTextColor,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: appColors.divider, width: 1))
              : null,
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18, color: leadingIconColor ?? appColors.onSurfaceVariant),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? appColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor ?? appColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (trailing != null)
              trailing!
            else if (amount != null)
              Text.rich(
                AppMoneyStyle.rich(
                  amount: CurrencyFormatter.toInputFormat(amount!),
                  style: amountStyle,
                  digitColor: amountColor ?? appColors.onSurface,
                  symbolColor: (amountColor ?? appColors.onSurface).withValues(alpha: 0.7),
                  sign: amountSign,
                ),
              )
            else if (trailingText != null)
              Text(
                trailingText!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: trailingTextColor ?? appColors.onSurfaceVariant,
                ),
              ),
            if (onTap != null && trailing == null) ...[
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: appColors.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small uppercase-tracked eyebrow label used as a section heading in the
/// editorial-ledger language, with an optional "Ver todas"-style action.
class LedgerSectionLabel extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const LedgerSectionLabel({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: appColors.onSurfaceVariant,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: appColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}
