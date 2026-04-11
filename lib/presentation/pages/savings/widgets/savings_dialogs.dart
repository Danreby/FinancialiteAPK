import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/savings/savings_cubit.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/currency_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/savings_goal.dart';

void showGoalDialog(BuildContext context, {SavingsGoal? editing}) {
  final nameCtrl = TextEditingController(text: editing?.title ?? '');
  final targetCtrl = TextEditingController(
    text: editing != null ? editing.targetAmount.toStringAsFixed(2) : '',
  );
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              editing != null ? 'Editar Meta' : 'Nova Meta',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: nameCtrl,
              label: 'Nome da meta',
              prefixIcon: Icons.flag,
              validator: Validators.required,
            ),
            const SizedBox(height: 12),
            CurrencyTextField(
                controller: targetCtrl,
                label: 'Valor alvo',
                validator: Validators.currency),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'title': nameCtrl.text.trim(),
                  'target_amount':
                      double.tryParse(targetCtrl.text.replaceAll(',', '.')) ??
                          0,
                };
                if (editing != null) {
                  context.read<SavingsCubit>().updateGoal(editing.id!, data);
                } else {
                  context.read<SavingsCubit>().createGoal(data);
                }
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

void showDepositDialog(BuildContext context, int goalId) {
  final amountCtrl = TextEditingController();
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Adicionar Depósito', style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 16),
          CurrencyTextField(
              controller: amountCtrl, validator: Validators.currency),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.read<SavingsCubit>().addDeposit(goalId, {
                'amount':
                    double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0,
              });
              Navigator.pop(ctx);
            },
            child: const Text('Depositar'),
          ),
        ],
      ),
    ),
  );
}
