import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_tokens.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final bool useShimmer;
  final int shimmerLines;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.useShimmer = false,
    this.shimmerLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (useShimmer) return _buildShimmer(context);
    return _buildSpinner(context);
  }

  Widget _buildSpinner(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
              color: theme.colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF222640) : const Color(0xFFE5E7EB),
      highlightColor:
          isDark ? const Color(0xFF2A2D42) : const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(shimmerLines, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
