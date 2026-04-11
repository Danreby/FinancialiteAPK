import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final Widget? trailing;
  final double bottomPadding;

  const PageHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.trailing,
    this.bottomPadding = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: bottomPadding,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back_ios_new,
                    size: 18, color: theme.colorScheme.onSurface),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
