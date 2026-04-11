import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/bill/bill_cubit.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/currency_text_field.dart';
import '../../../../core/utils/validators.dart';

void showBillCreateDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dueDayCtrl = TextEditingController();
  String recurrenceType = 'monthly';
  final formKey = GlobalKey<FormState>();

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
              Text('Nova Conta', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: titleCtrl,
                label: 'Título',
                prefixIcon: Icons.description,
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
              CurrencyTextField(
                  controller: amountCtrl,
                  label: 'Valor',
                  validator: Validators.currency),
              const SizedBox(height: 12),
              AppTextField(
                controller: dueDayCtrl,
                label: 'Dia do vencimento (1-31)',
                prefixIcon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: Validators.dayOfMonth,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: recurrenceType,
                decoration: const InputDecoration(
                  labelText: 'Recorrência',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Mensal')),
                  DropdownMenuItem(value: 'yearly', child: Text('Anual')),
                  DropdownMenuItem(
                      value: 'none', child: Text('Sem recorrência')),
                ],
                onChanged: (v) =>
                    setLocalState(() => recurrenceType = v ?? 'monthly'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  ctx.read<BillCubit>().createBill({
                    'title': titleCtrl.text.trim(),
                    'amount': CurrencyTextField.parseValue(amountCtrl.text),
                    'due_day': int.tryParse(dueDayCtrl.text) ?? 1,
                    'recurrence_type': recurrenceType,
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

void showBillPayDialog(BuildContext context, int billId, double amount) {
  final amountCtrl = TextEditingController(text: amount.toStringAsFixed(2));
  showModalBottomSheet(
    context: context,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pagar Conta', style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 16),
          CurrencyTextField(
              controller: amountCtrl, label: 'Valor do pagamento'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ctx.read<BillCubit>().payBill(billId, {
                'valor_pago':
                    double.tryParse(amountCtrl.text.replaceAll(',', '.')) ??
                        amount,
                'data_pagamento':
                    DateTime.now().toIso8601String().substring(0, 10),
              });
              Navigator.pop(ctx);
            },
            child: const Text('Confirmar Pagamento'),
          ),
        ],
      ),
    ),
  );
}
