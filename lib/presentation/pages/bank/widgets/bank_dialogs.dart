import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/bank/bank_cubit.dart';
import '../../../widgets/currency_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/bank_account.dart';

void showBankCreateDialog(BuildContext context) {
  int? selectedBankId;
  final balanceCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final bankState = context.read<BankCubit>().state;
  final availableBanks = bankState is BankLoaded
      ? (bankState.availableBanks ?? <Bank>[])
      : <Bank>[];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setLocalState) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nova Conta Bancária',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedBankId,
                decoration: const InputDecoration(
                  labelText: 'Banco',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: availableBanks
                    .map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name),
                        ))
                    .toList(),
                validator: (v) => v == null ? 'Selecione um banco' : null,
                onChanged: (v) => setLocalState(() => selectedBankId = v),
              ),
              const SizedBox(height: 12),
              CurrencyTextField(
                  controller: balanceCtrl, label: 'Saldo inicial'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  context.read<BankCubit>().createAccount({
                    'bank_id': selectedBankId,
                    'balance': double.tryParse(
                            balanceCtrl.text.replaceAll(',', '.')) ??
                        0,
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showBankEditDialog(BuildContext context, BankAccount account) {
  final balanceCtrl =
      TextEditingController(text: account.balance.toStringAsFixed(2));
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
            Text('Editar Saldo', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              account.displayName,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            CurrencyTextField(
                controller: balanceCtrl,
                label: 'Saldo atual',
                validator: Validators.currency),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context.read<BankCubit>().updateAccount(account.id!, {
                  'balance':
                      double.tryParse(balanceCtrl.text.replaceAll(',', '.')) ??
                          0,
                });
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
