import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/profile/profile_cubit.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/page_header.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_dialogs.dart';

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
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error),
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
                  const PageHeader(
                      title: 'Perfil', showBackButton: true, bottomPadding: 20),
                  const SizedBox(height: 8),
                  _buildAvatar(theme, user.name),
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
                  _buildActionsSection(theme, user.name, user.email),
                  const SizedBox(height: 16),
                  _buildDangerSection(theme),
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

  Widget _buildAvatar(ThemeData theme, String name) {
    return Container(
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
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection(ThemeData theme, String name, String email) {
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
          children: [
            ProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Editar perfil',
              color: theme.colorScheme.primary,
              onTap: () => showEditProfileDialog(context, name),
            ),
            Divider(
              height: 1,
              indent: 74,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            ProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Alterar senha',
              color: theme.colorScheme.primary,
              onTap: () => showChangePasswordDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerSection(ThemeData theme) {
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
          children: [
            ProfileMenuItem(
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
            ProfileMenuItem(
              icon: Icons.delete_forever,
              title: 'Excluir conta',
              color: theme.colorScheme.error,
              onTap: () => showDeleteAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
