import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/confirm_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            children: [
              const _SectionHeader('Aparência'),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Modo escuro'),
                value: themeState.isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggleThemeMode(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Tema de cores'),
                subtitle: Text(themeState.colorSchemeName == 'rose' ? 'Rose' : 'Forest'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => _showColorSchemeDialog(context, themeState.colorSchemeName),
              ),
              const _SectionHeader('Dados'),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sincronizar dados'),
                subtitle: const Text('Enviar dados pendentes para o servidor'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sincronização iniciada...')),
                  );
                },
              ),
              const _SectionHeader('Conta'),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text('Sair'),
                onTap: () async {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: 'Sair',
                    message: 'Deseja realmente sair?',
                    confirmText: 'Sair',
                  );
                  if (confirmed == true) {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Financialite v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  void _showColorSchemeDialog(BuildContext context, String current) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Tema de cores'),
        children: [
          RadioListTile<String>(
            title: const Text('Rose'),
            value: 'rose',
            groupValue: current,
            onChanged: (v) {
              context.read<ThemeCubit>().setColorScheme(v!);
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<String>(
            title: const Text('Forest'),
            value: 'forest',
            groupValue: current,
            onChanged: (v) {
              context.read<ThemeCubit>().setColorScheme(v!);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
