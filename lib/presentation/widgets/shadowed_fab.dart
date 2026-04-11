import 'package:flutter/material.dart';

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
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
