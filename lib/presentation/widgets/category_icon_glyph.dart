import 'package:flutter/material.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/icon_utils.dart';

/// Renders a category's stored `icon` string the same way financialite
/// (web) does: as the matching emoji when the key is part of the shared
/// icon set (see `core/utils/category_icons.dart`), falling back to the
/// legacy Material icon for categories created before that set existed.
class CategoryIconGlyph extends StatelessWidget {
  final String? icon;
  final double size;
  final Color color;

  const CategoryIconGlyph({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = emojiForCategoryIcon(icon);
    if (emoji != null) {
      return Text(emoji, style: TextStyle(fontSize: size, height: 1));
    }
    return Icon(iconFromName(icon), size: size, color: color);
  }
}
