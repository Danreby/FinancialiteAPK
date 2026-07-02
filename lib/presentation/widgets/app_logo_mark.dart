import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// The financialite brand mark: a dark rounded-square badge with three
/// horizontal "ledger" bars in the active theme's primary color. Mirrors
/// financialite (web)'s `ApplicationLogo.jsx` pixel-for-pixel proportions,
/// so mobile and web share one real identity instead of a generic wallet
/// icon standing in for a logo.
class AppLogoMark extends StatelessWidget {
  final double size;
  final Color? barColor;

  const AppLogoMark({super.key, this.size = 64, this.barColor});

  @override
  Widget build(BuildContext context) {
    final bars = barColor ?? Theme.of(context).appColors.primary;
    const badge = Color(0xFF0B0B0B);
    final barHeight = size * (1.6 / 24);
    final barWidth = size * (10 / 24);
    final gap = size * (2.4 / 24);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: badge,
        borderRadius: BorderRadius.circular(size * (6 / 24)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) SizedBox(height: gap),
              Container(
                width: barWidth,
                height: barHeight,
                decoration: BoxDecoration(
                  color: bars,
                  borderRadius: BorderRadius.circular(barHeight / 2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
