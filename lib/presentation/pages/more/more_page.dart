import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/section_header.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Custom header
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 16,
              20,
              20,
            ),
            child: Text(
              'Mais',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Decorative search container
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Buscar opção...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Financeiro section
          const SectionHeader(title: 'Financeiro'),
          const SizedBox(height: 12),
          _buildSectionContainer(context, [
            _MenuItemData(Icons.trending_up, 'Receitas',
                const Color(0xFF4CAF50), () => context.push('/income')),
            _MenuItemData(Icons.receipt_long, 'Faturas',
                const Color(0xFF10B981), () => context.push('/faturas')),
            _MenuItemData(Icons.account_balance_wallet_outlined, 'Extrato',
                const Color(0xFF2196F3), () => context.push('/extract')),
            _MenuItemData(Icons.show_chart, 'Projeções',
                const Color(0xFF7C3AED), () => context.push('/projections')),
            _MenuItemData(Icons.savings_outlined, 'Metas de Economia',
                const Color(0xFF2196F3), () => context.push('/savings')),
            _MenuItemData(Icons.account_balance, 'Contas Bancárias',
                const Color(0xFF9C27B0), () => context.push('/bank-accounts')),
            _MenuItemData(Icons.credit_card, 'Cartões', const Color(0xFFFF9800),
                () => context.push('/cards')),
          ]),

          const SizedBox(height: 24),

          // Organização section
          const SectionHeader(title: 'Organização'),
          const SizedBox(height: 12),
          _buildSectionContainer(context, [
            _MenuItemData(Icons.category_outlined, 'Categorias',
                const Color(0xFFE91E63), () => context.push('/categories')),
            _MenuItemData(Icons.notifications_outlined, 'Notificações',
                const Color(0xFFFF5722), () => context.push('/notifications')),
            _MenuItemData(Icons.bar_chart, 'Relatórios',
                const Color(0xFF607D8B), () => context.push('/reports')),
          ]),

          const SizedBox(height: 24),

          // Conta section
          const SectionHeader(title: 'Conta'),
          const SizedBox(height: 12),
          _buildSectionContainer(context, [
            _MenuItemData(Icons.person_outline, 'Perfil',
                theme.colorScheme.primary, () => context.push('/profile')),
            _MenuItemData(Icons.settings_outlined, 'Configurações',
                const Color(0xFF78909C), () => context.push('/settings')),
          ]),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Financialite v1.2.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
      BuildContext context, List<_MenuItemData> items) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: item.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(item.icon, color: item.color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.label,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: 74,
                    color:
                        theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
