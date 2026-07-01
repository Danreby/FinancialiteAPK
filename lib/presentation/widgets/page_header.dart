import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_tokens.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final Widget? trailing;
  final double bottomPadding;
  final Widget? subtitle;

  const PageHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.trailing,
    this.bottomPadding = 8,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        color: appColors.headerBackground,
        boxShadow: AppShadows.xs,
        border: Border(
          bottom: BorderSide(
            color: appColors.divider.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: topPad + 14,
          left: 20,
          right: 20,
          bottom: bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (showBackButton) ...[
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: appColors.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: appColors.divider,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              DefaultTextStyle(
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                child: subtitle!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
