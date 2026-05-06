import 'package:flutter/material.dart';

class NotificationTypeStyle {
  final Color color;
  final IconData icon;

  const NotificationTypeStyle({required this.color, required this.icon});
}

class NotificationTypeMapper {
  static NotificationTypeStyle resolve(BuildContext context, String rawType) {
    final theme = Theme.of(context);
    // Normalize: strip Laravel FQCN like "App\Notifications\BillDueSoon"
    final type = rawType
        .split('\\')
        .last
        .replaceAll('Notification', '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_\s]+'), '_');

    if (_isError(type)) {
      return NotificationTypeStyle(
        color: theme.colorScheme.error,
        icon: Icons.error_outline_rounded,
      );
    }
    if (_isWarning(type)) {
      return NotificationTypeStyle(
        color: Colors.amber.shade700,
        icon: Icons.warning_amber_rounded,
      );
    }
    if (_isSuccess(type)) {
      return const NotificationTypeStyle(
        color: Color(0xFF10B981),
        icon: Icons.check_circle_outline_rounded,
      );
    }
    if (_isBill(type)) {
      return NotificationTypeStyle(
        color: Colors.orange.shade700,
        icon: Icons.receipt_long_rounded,
      );
    }
    if (_isBudget(type)) {
      return NotificationTypeStyle(
        color: theme.colorScheme.error,
        icon: Icons.account_balance_wallet_rounded,
      );
    }
    if (_isSavings(type)) {
      return const NotificationTypeStyle(
        color: Color(0xFF3B82F6),
        icon: Icons.savings_rounded,
      );
    }
    // Default: info
    return NotificationTypeStyle(
      color: theme.colorScheme.primary,
      icon: Icons.notifications_active_outlined,
    );
  }

  static bool _isError(String t) =>
      t == 'error' || t.contains('fail') || t.contains('erro');
  static bool _isWarning(String t) =>
      t == 'warning' || t.contains('alert') || t.contains('alerta');
  static bool _isSuccess(String t) =>
      t == 'success' ||
      t.contains('income') ||
      t.contains('receita') ||
      t.contains('paid');
  static bool _isBill(String t) =>
      t.contains('bill') ||
      t.contains('due') ||
      t.contains('conta') ||
      t.contains('venc');
  static bool _isBudget(String t) =>
      t.contains('budget') || t.contains('exceeded') || t.contains('orçamento');
  static bool _isSavings(String t) =>
      t.contains('saving') || t.contains('goal') || t.contains('meta');
}
