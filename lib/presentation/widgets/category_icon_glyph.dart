import 'package:flutter/material.dart';
import '../../core/utils/category_icons.dart';
import '../../core/utils/icon_utils.dart';

/// Renders a category's stored `icon` string as a monochrome [Icon]: the
/// matching glyph when the key is part of the shared icon set (see
/// `core/utils/category_icons.dart`), falling back to the legacy Material
/// icon for categories created before that set existed. Always centered so
/// it sits correctly inside whatever fixed-size badge the caller wraps it
/// in, regardless of that container's own alignment.
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
    final iconData = iconDataForCategoryIcon(icon) ?? iconFromName(icon);
    return Center(child: Icon(iconData, size: size, color: color));
  }
}
