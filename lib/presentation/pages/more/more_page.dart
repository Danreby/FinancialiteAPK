import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Mais')),
      body: ListView(
        children: [
          _buildSection(context, 'Financeiro', [
            _MenuItem(Icons.trending_up, 'Receitas', () => context.push('/income')),
            _MenuItem(Icons.savings_outlined, 'Metas de Economia', () => context.push('/savings')),
            _MenuItem(Icons.account_balance, 'Contas Bancárias', () => context.push('/bank-accounts')),
            _MenuItem(Icons.credit_card, 'Cartões', () => context.push('/cards')),
          ]),
          _buildSection(context, 'Organização', [
            _MenuItem(Icons.category_outlined, 'Categorias', () => context.push('/categories')),
            _MenuItem(Icons.notifications_outlined, 'Notificações', () => context.push('/notifications')),
            _MenuItem(Icons.bar_chart, 'Relatórios', () => context.push('/reports')),
          ]),
          _buildSection(context, 'Conta', [
            _MenuItem(Icons.person_outline, 'Perfil', () => context.push('/profile')),
            _MenuItem(Icons.settings_outlined, 'Configurações', () => context.push('/settings')),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Financialite v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_MenuItem> items) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items.map((item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: item.onTap,
            )),
        const Divider(height: 1),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _MenuItem(this.icon, this.label, this.onTap);
}
