import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/budget/budget_cubit.dart';
import '../../../widgets/currency_text_field.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';

void showBudgetCreateDialog(BuildContext context, DateTime selectedMonth) {
  final amountCtrl = TextEditingController();
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
            Text('Novo Orçamento', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            CurrencyTextField(
                controller: amountCtrl,
                label: 'Limite mensal',
                validator: Validators.currency),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context.read<BudgetCubit>().createBudget({
                  'monthly_limit':
                      CurrencyTextField.parseValue(amountCtrl.text),
                  'month_year': DateFormatter.monthKey(selectedMonth),
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
