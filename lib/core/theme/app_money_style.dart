import 'package:flutter/material.dart';

/// Typography reserved exclusively for money figures. Inter (the app's UI
/// font) never renders an amount directly -- amounts always go through
/// [AppMoneyStyle.rich], which pairs a Space Grotesk tabular-figure digit
/// style with a de-emphasized Inter currency symbol, so figures read as
/// deliberately designed rather than "body text but bigger."
class AppMoneyStyle {
  AppMoneyStyle._();

  static const String _fontFamily = 'SpaceGrotesk';

  static const TextStyle hero = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle large = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.05,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle medium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle small = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Renders [amount] (already formatted, e.g. "1.234,56") with [symbol]
  /// ("R$") de-emphasized in Inter at ~70% size ahead of the tabular
  /// digits. [style] should be one of [hero]/[large]/[medium]/[small].
  static InlineSpan rich({
    required String amount,
    required TextStyle style,
    required Color digitColor,
    required Color symbolColor,
    String symbol = 'R\$',
    String? sign,
    Color? signColor,
  }) {
    return TextSpan(
      children: [
        if (sign != null)
          TextSpan(
            text: '$sign ',
            style: style.copyWith(color: signColor ?? digitColor),
          ),
        TextSpan(
          text: '$symbol ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: style.fontSize! * 0.7,
            color: symbolColor,
          ),
        ),
        TextSpan(text: amount, style: style.copyWith(color: digitColor)),
      ],
    );
  }
}
