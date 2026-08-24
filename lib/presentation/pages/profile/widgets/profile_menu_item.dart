import 'package:flutter/material.dart';
import '../../../widgets/ledger_row.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool showDivider;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LedgerRow(
      leadingIcon: icon,
      leadingIconColor: color,
      title: title,
      titleColor: color == theme.colorScheme.error ? color : null,
      onTap: onTap,
      showDivider: showDivider,
    );
  }
}
