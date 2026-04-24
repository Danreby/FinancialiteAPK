import 'package:flutter/material.dart';

/// Constrains content width on tablets/desktop while keeping full width on mobile.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 980,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Padding(padding: padding, child: child);
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(padding: padding, child: child),
          ),
        );
      },
    );
  }
}
