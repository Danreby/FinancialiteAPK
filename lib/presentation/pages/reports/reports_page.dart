import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/month_selector.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Relatórios',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          MonthSelector(
            selectedMonth: _selectedMonth,
            onChanged: (date) => setState(() => _selectedMonth = date),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildReportCard(
                  theme: theme,
                  icon: Icons.pie_chart,
                  color: theme.colorScheme.primary,
                  title: 'Gastos por Categoria',
                  subtitle: 'Veja como seus gastos estão distribuídos',
                  onTap: () => context.push('/reports/categories'),
                ),
                const SizedBox(height: 12),
                _buildReportCard(
                  theme: theme,
                  icon: Icons.bar_chart,
                  color: Colors.blue,
                  title: 'Comparativo Mensal',
                  subtitle: 'Compare receitas e despesas ao longo dos meses',
                  onTap: () => context.push('/reports/monthly'),
                ),
                const SizedBox(height: 12),
                _buildReportCard(
                  theme: theme,
                  icon: Icons.trending_up,
                  color: const Color(0xFF10B981),
                  title: 'Evolução Patrimonial',
                  subtitle: 'Acompanhe a evolução do seu patrimônio',
                  onTap: () => context.push('/reports/evolution'),
                ),
                const SizedBox(height: 12),
                _buildReportCard(
                  theme: theme,
                  icon: Icons.receipt_long,
                  color: Colors.amber,
                  title: 'Contas a Pagar',
                  subtitle: 'Resumo das contas pendentes e pagas',
                  onTap: () => context.push('/bills'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required ThemeData theme,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
