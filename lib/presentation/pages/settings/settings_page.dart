import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/section_header.dart';
import '../../widgets/page_header.dart';
import 'widgets/color_scheme_sheet.dart';
import 'widgets/settings_item.dart';
import '../../../core/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // Custom header
              const PageHeader(
                  title: 'Configurações',
                  showBackButton: true,
                  bottomPadding: 20),

              const SizedBox(height: 8),

              // Aparência section
              const SectionHeader(title: 'Aparência'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SettingsItem(
                      icon: Icons.dark_mode,
                      iconColor: const Color(0xFF5C6BC0),
                      title: 'Modo escuro',
                      trailing: Switch.adaptive(
                        value: themeState.isDark,
                        onChanged: (_) =>
                            context.read<ThemeCubit>().toggleThemeMode(),
                      ),
                    ),
                    SettingsItem(
                      icon: Icons.palette,
                      iconColor: theme.colorScheme.primary,
                      title: 'Tema de cores',
                      subtitle: _themeLabel(themeState.colorSchemeName),
                      onTap: () => showColorSchemeSheet(
                          context, themeState.colorSchemeName),
                      showDivider: false,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Dados section
              const SectionHeader(title: 'Dados'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SettingsItem(
                  icon: Icons.sync,
                  iconColor: const Color(0xFF26A69A),
                  title: 'Sincronizar dados',
                  subtitle: 'Enviar dados pendentes para o servidor',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Sincronização iniciada...')),
                    );
                  },
                  showDivider: false,
                  trailing: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Conta section
              const SectionHeader(title: 'Conta'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SettingsItem(
                  icon: Icons.logout,
                  iconColor: theme.appColors.warning,
                  title: 'Sair',
                  showDivider: false,
                  onTap: () async {
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: 'Sair',
                      message: 'Deseja realmente sair?',
                      confirmText: 'Sair',
                    );
                    if (confirmed == true) {
                      context
                          .read<AuthBloc>()
                          .add(const AuthLogoutRequested());
                      context.go('/login');
                    }
                  },
                ),
              ),

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
          );
        },
      ),
    );
  }

  String _themeLabel(String name) {
    const labels = {
      'rose': 'Rosé',
      'forest': 'Floresta',
      'black': 'Preto',
      'gold': 'Ouro',
      'lavender': 'Lavanda',
      'midnight': 'Meia-noite',
    };
    return labels[name] ?? name;
  }
}
