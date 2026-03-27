import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Relatórios')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          MonthSelector(
            selectedMonth: _selectedMonth,
            onChanged: (date) => setState(() => _selectedMonth = date),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _ReportCard(
                  icon: Icons.pie_chart,
                  title: 'Gastos por Categoria',
                  subtitle: 'Veja como seus gastos estão distribuídos',
                  onTap: () {},
                ),
                _ReportCard(
                  icon: Icons.bar_chart,
                  title: 'Comparativo Mensal',
                  subtitle: 'Compare receitas e despesas ao longo dos meses',
                  onTap: () {},
                ),
                _ReportCard(
                  icon: Icons.trending_up,
                  title: 'Evolução Patrimonial',
                  subtitle: 'Acompanhe a evolução do seu patrimônio',
                  onTap: () {},
                ),
                _ReportCard(
                  icon: Icons.receipt_long,
                  title: 'Contas a Pagar',
                  subtitle: 'Resumo das contas pendentes e pagas',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
