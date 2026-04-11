import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirm_dialog.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/page_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfilePasswordChanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Senha alterada com sucesso')),
            );
          }
          if (state is ProfileDeleted) {
            context.read<AuthBloc>().add(const AuthLogoutRequested());
            context.go('/login');
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const AppLoadingIndicator(useShimmer: true, shimmerLines: 6);
          }
          if (state is ProfileError && state is! ProfileLoaded) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ProfileCubit>().loadProfile(),
            );
          }
          if (state is ProfileLoaded || state is ProfilePasswordChanged) {
            final user = state is ProfileLoaded
                ? state.user
                : (state as ProfilePasswordChanged).user;
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  const PageHeader(title: 'Perfil', showBackButton: true, bottomPadding: 20),

                  const SizedBox(height: 8),

                  // Instagram-style profile header with gradient ring
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 56,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Profile actions section
                  Padding(
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
                        children: [
                          _buildMenuItem(
                            context,
                            icon: Icons.person_outline,
                            title: 'Editar perfil',
                            color: theme.colorScheme.primary,
                            onTap: () => _showEditProfileDialog(user.name, user.email),
                          ),
                          Divider(
                            height: 1,
                            indent: 74,
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.lock_outline,
                            title: 'Alterar senha',
                            color: theme.colorScheme.primary,
                            onTap: _showChangePasswordDialog,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Danger zone section
                  Padding(
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
                        children: [
                          _buildMenuItem(
                            context,
                            icon: Icons.logout,
                            title: 'Sair',
                            color: Colors.orange,
                            onTap: () async {
                              final confirmed = await ConfirmDialog.show(
                                context,
                                title: 'Sair',
                                message: 'Deseja realmente sair da sua conta?',
                                confirmText: 'Sair',
                              );
                              if (confirmed == true) {
                                context.read<AuthBloc>().add(const AuthLogoutRequested());
                                context.go('/login');
                              }
                            },
                          ),
                          Divider(
                            height: 1,
                            indent: 74,
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                          _buildMenuItem(
                            context,
                            icon: Icons.delete_forever,
                            title: 'Excluir conta',
                            color: theme.colorScheme.error,
                            onTap: _showDeleteAccountDialog,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color == theme.colorScheme.error ? color : null,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(String currentName, String currentEmail) {
    final nameCtrl = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
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
                'Editar Perfil',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameCtrl,
                label: 'Nome',
                prefixIcon: Icons.person,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  context.read<ProfileCubit>().updateProfile({'name': nameCtrl.text.trim()});
                  Navigator.pop(ctx);
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
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
                'Alterar Senha',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(controller: currentCtrl, label: 'Senha atual', obscureText: true, validator: Validators.required),
              const SizedBox(height: 12),
              AppTextField(controller: newCtrl, label: 'Nova senha', obscureText: true, validator: Validators.password),
              const SizedBox(height: 12),
              AppTextField(
                controller: confirmCtrl,
                label: 'Confirmar nova senha',
                obscureText: true,
                validator: (v) => v != newCtrl.text ? 'As senhas não coincidem' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  context.read<ProfileCubit>().updatePassword(
                        currentPassword: currentCtrl.text,
                        newPassword: newCtrl.text,
                        confirmation: confirmCtrl.text,
                      );
                  Navigator.pop(ctx);
                },
                child: const Text('Alterar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(ctx).colorScheme.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Excluir Conta'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta ação é irreversível. Todos os seus dados serão excluídos permanentemente.',
                style: Theme.of(ctx).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: passwordCtrl,
                label: 'Digite sua senha para confirmar',
                obscureText: true,
                validator: Validators.required,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              context.read<ProfileCubit>().deleteAccount(passwordCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
