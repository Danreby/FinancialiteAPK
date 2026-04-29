import 'package:flutter/material.dart';

class NotificationTypeStyle {
  final Color color;
  final IconData icon;

  const NotificationTypeStyle({required this.color, required this.icon});
}

class NotificationTypeMapper {
  static NotificationTypeStyle resolve(BuildContext context, String rawType) {
    final theme = Theme.of(context);
    final type = rawType.trim().toLowerCase();

    switch (type) {
      case 'error':
      case 'bill_due':
        return NotificationTypeStyle(
          color: theme.colorScheme.error,
          icon: Icons.error_outline_rounded,
        );
      case 'warning':
      case 'budget_exceeded':
        return NotificationTypeStyle(
          color: Colors.amber.shade700,
          icon: Icons.warning_amber_rounded,
        );
      case 'success':
      case 'income_received':
        return const NotificationTypeStyle(
          color: Color(0xFF10B981),
          icon: Icons.check_circle_outline_rounded,
        );
      case 'info':
      case 'savings_goal':
      default:
        return NotificationTypeStyle(
          color: theme.colorScheme.primary,
          icon: Icons.notifications_active_outlined,
        );
    }
  }
}
