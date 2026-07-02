import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Standardizes the "icon in a tinted backdrop" pattern repeated across
/// category chips, stat cards, and empty states: glyph at full color, a
/// soft backdrop at 10-14% alpha, signature asymmetric corners.
class DuotoneIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double backdropAlpha;

  const DuotoneIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
    this.backdropAlpha = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: backdropAlpha),
        borderRadius: AppRadius.cardCut(open: size * 0.32, tight: size * 0.09),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}
