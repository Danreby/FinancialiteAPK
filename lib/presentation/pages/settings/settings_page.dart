import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/section_header.dart';
import '../../widgets/page_header.dart';

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
              const PageHeader(title: 'Configurações', showBackButton: true, bottomPadding: 20),

              const SizedBox(height: 8),

              // Aparência section
              const SectionHeader(title: 'Aparência'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Dark mode toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5C6BC0)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.dark_mode,
                                  color: Color(0xFF5C6BC0), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Modo escuro',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: themeState.isDark,
                              onChanged: (_) =>
                                  context.read<ThemeCubit>().toggleThemeMode(),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 74,
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                      // Color scheme selector
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showColorSchemeSheet(
                              context, themeState.colorSchemeName),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.palette,
                                      color: theme.colorScheme.primary,
                                      size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tema de cores',
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _themeLabel(
                                                themeState.colorSchemeName),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dados section
              const SectionHeader(title: 'Dados'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Sincronização iniciada...')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF26A69A)
                                    .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.sync,
                                  color: Color(0xFF26A69A), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sincronizar dados',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Enviar dados pendentes para o servidor',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
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
                ),
              ),

              const SizedBox(height: 24),

              // Conta section
              const SectionHeader(title: 'Conta'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.logout,
                                  color: Colors.orange, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Sair',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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

  void _showColorSchemeSheet(BuildContext context, String current) {
    final theme = Theme.of(context);
    final schemes = [
      ('rose', '🌹 Rosé', const Color(0xFFE11D48)),
      ('forest', '🌿 Floresta', const Color(0xFF059669)),
      ('black', '🖤 Preto', const Color(0xFF1F2937)),
      ('gold', '✨ Ouro', const Color(0xFFD97706)),
      ('lavender', '💜 Lavanda', const Color(0xFF7C3AED)),
      ('midnight', '🌙 Meia-noite', const Color(0xFF1E40AF)),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tema de cores',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            ...schemes.asMap().entries.map((entry) {
              final i = entry.key;
              final (key, label, color) = entry.value;
              return Column(
                children: [
                  if (i > 0)
                    Divider(
                        height: 1,
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3)),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.read<ThemeCubit>().setColorScheme(key);
                        Navigator.pop(ctx);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                label,
                                style:
                                    Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            Radio<String>(
                              value: key,
                              groupValue: current,
                              onChanged: (v) {
                                context.read<ThemeCubit>().setColorScheme(v!);
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
