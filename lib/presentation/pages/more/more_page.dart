import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/page_header.dart';
import '../../widgets/ledger_row.dart';
import '../../../core/theme/app_theme.dart';

/// Curated menu-icon colors, sourced from the hues already used across the
/// app's color schemes (rose/forest/gold/lavender/midnight -- see
/// app_colors.dart) instead of generic Material swatches, so the "one
/// distinct color per menu item" pattern still reads as this app's palette.
class _MenuColors {
  _MenuColors._();

  static const forestGreen = Color(0xFF059669); // forest scheme primary
  static const amber = Color(0xFFD97706); // gold scheme primary
  static const blue = Color(0xFF3B82F6); // midnight scheme secondary
  static const purple = Color(0xFF7C3AED); // lavender scheme primary
  static const teal = Color(0xFF2DD4BF); // forest scheme accent
  static const rose = Color(0xFFE11D48); // rose scheme secondary
  static const pink = Color(0xFFF43F5E); // rose scheme accent
  static const slate = Color(0xFF4B5563); // black scheme accent
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;

    return Scaffold(
      backgroundColor: appColors.background,
      body: Column(
        children: [
          PageHeader(title: 'Mais'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 130),
              children: [
                _SectionLabel('Financeiro'),
                const SizedBox(height: 8),
                _buildGroup(context, [
                  _MenuItemData(Icons.trending_up_rounded, 'Receitas',
                      _MenuColors.forestGreen, () => context.push('/income')),
                  _MenuItemData(Icons.receipt_long_rounded, 'Faturas',
                      _MenuColors.amber, () => context.push('/faturas')),
                  _MenuItemData(Icons.account_balance_wallet_rounded, 'Extrato',
                      _MenuColors.blue, () => context.push('/extract')),
                  _MenuItemData(
                      Icons.show_chart_rounded,
                      'Projeções',
                      _MenuColors.purple,
                      () => context.push('/projections')),
                  _MenuItemData(Icons.savings_rounded, 'Metas de Economia',
                      _MenuColors.teal, () => context.push('/savings')),
                  _MenuItemData(
                      Icons.account_balance_rounded,
                      'Contas Bancárias',
                      _MenuColors.rose,
                      () => context.push('/bank-accounts')),
                  _MenuItemData(Icons.credit_card_rounded, 'Cartões',
                      _MenuColors.pink, () => context.push('/cards')),
                ]),
                const SizedBox(height: 20),
                _SectionLabel('Organização'),
                const SizedBox(height: 8),
                _buildGroup(context, [
                  _MenuItemData(
                      Icons.category_rounded,
                      'Categorias',
                      _MenuColors.slate,
                      () => context.push('/categories')),
                  _MenuItemData(
                      Icons.notifications_rounded,
                      'Notificações',
                      _MenuColors.amber,
                      () => context.push('/notifications')),
                  _MenuItemData(Icons.bar_chart_rounded, 'Relatórios',
                      _MenuColors.blue, () => context.push('/reports')),
                ]),
                const SizedBox(height: 20),
                _SectionLabel('Conta'),
                const SizedBox(height: 8),
                _buildGroup(context, [
                  _MenuItemData(
                      Icons.person_rounded,
                      'Perfil',
                      theme.colorScheme.primary,
                      () => context.push('/profile')),
                  _MenuItemData(Icons.settings_rounded, 'Configurações',
                      _MenuColors.slate, () => context.push('/settings')),
                ]),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Financialite v1.2.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, List<_MenuItemData> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return LedgerRow(
            leadingIcon: item.icon,
            leadingIconColor: item.color,
            title: item.label,
            onTap: item.onTap,
            showDivider: i < items.length - 1,
          );
        }),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItemData(this.icon, this.label, this.color, this.onTap);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
