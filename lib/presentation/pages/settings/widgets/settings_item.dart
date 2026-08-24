import 'package:flutter/material.dart';
import '../../../widgets/ledger_row.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return LedgerRow(
      leadingIcon: icon,
      leadingIconColor: iconColor,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      showDivider: showDivider,
    );
  }
}
