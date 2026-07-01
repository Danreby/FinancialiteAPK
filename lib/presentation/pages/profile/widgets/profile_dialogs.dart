import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/profile/profile_cubit.dart';
import '../../../widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_tokens.dart';

void showEditProfileDialog(BuildContext context, String currentName) {
  final nameCtrl = TextEditingController(text: currentName);
  final formKey = GlobalKey<FormState>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
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
                context
                    .read<ProfileCubit>()
                    .updateProfile({'name': nameCtrl.text.trim()});
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

void showChangePasswordDialog(BuildContext context) {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
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
            AppTextField(
                controller: currentCtrl,
                label: 'Senha atual',
                obscureText: true,
                validator: Validators.required),
            const SizedBox(height: 12),
            AppTextField(
                controller: newCtrl,
                label: 'Nova senha',
                obscureText: true,
                validator: Validators.password),
            const SizedBox(height: 12),
            AppTextField(
              controller: confirmCtrl,
              label: 'Confirmar nova senha',
              obscureText: true,
              validator: (v) =>
                  v != newCtrl.text ? 'As senhas não coincidem' : null,
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

void showDeleteAccountDialog(BuildContext context) {
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl)),
      title: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
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
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error),
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
