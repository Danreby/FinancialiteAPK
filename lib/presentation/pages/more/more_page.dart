import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/page_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

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
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _SectionLabel('Financeiro'),
                const SizedBox(height: 8),
                _buildGroup(context, appColors, [
                  _MenuItemData(Icons.trending_up_rounded, 'Receitas',
                      const Color(0xFF4CAF50), () => context.push('/income')),
                  _MenuItemData(Icons.receipt_long_rounded, 'Faturas',
                      const Color(0xFF10B981), () => context.push('/faturas')),
                  _MenuItemData(Icons.account_balance_wallet_rounded, 'Extrato',
                      const Color(0xFF2196F3), () => context.push('/extract')),
                  _MenuItemData(
                      Icons.show_chart_rounded,
                      'Projeções',
                      const Color(0xFF7C3AED),
                      () => context.push('/projections')),
                  _MenuItemData(Icons.savings_rounded, 'Metas de Economia',
                      const Color(0xFF2196F3), () => context.push('/savings')),
                  _MenuItemData(
                      Icons.account_balance_rounded,
                      'Contas Bancárias',
                      const Color(0xFF9C27B0),
                      () => context.push('/bank-accounts')),
                  _MenuItemData(Icons.credit_card_rounded, 'Cartões',
                      const Color(0xFFFF9800), () => context.push('/cards')),
                ]),
                const SizedBox(height: 20),
                _SectionLabel('Organização'),
                const SizedBox(height: 8),
                _buildGroup(context, appColors, [
                  _MenuItemData(
                      Icons.category_rounded,
                      'Categorias',
                      const Color(0xFFE91E63),
                      () => context.push('/categories')),
                  _MenuItemData(
                      Icons.notifications_rounded,
                      'Notificações',
                      const Color(0xFFFF5722),
                      () => context.push('/notifications')),
                  _MenuItemData(Icons.bar_chart_rounded, 'Relatórios',
                      const Color(0xFF607D8B), () => context.push('/reports')),
                ]),
                const SizedBox(height: 20),
                _SectionLabel('Conta'),
                const SizedBox(height: 8),
                _buildGroup(context, appColors, [
                  _MenuItemData(
                      Icons.person_rounded,
                      'Perfil',
                      theme.colorScheme.primary,
                      () => context.push('/profile')),
                  _MenuItemData(Icons.settings_rounded, 'Configurações',
                      const Color(0xFF78909C), () => context.push('/settings')),
                ]),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Financialite v1.2.0',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
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

  Widget _buildGroup(
      BuildContext context, ThemeColors appColors, List<_MenuItemData> items) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: appColors.divider.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.only(
                      topLeft: i == 0 ? const Radius.circular(16) : Radius.zero,
                      topRight:
                          i == 0 ? const Radius.circular(16) : Radius.zero,
                      bottomLeft: i == items.length - 1
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: i == items.length - 1
                          ? const Radius.circular(16)
                          : Radius.zero,
                    ),
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.icon, color: item.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: 66,
                    color: appColors.divider.withValues(alpha: 0.5),
                  ),
              ],
            );
          }),
        ),
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
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
