import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

class ShadowedFab extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const ShadowedFab({
    super.key,
    required this.onPressed,
    this.child = const Icon(Icons.add),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: AppShadows.buttonPrimary(theme.colorScheme.primary),
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        elevation: 0,
        child: child,
      ),
    );
  }
}
