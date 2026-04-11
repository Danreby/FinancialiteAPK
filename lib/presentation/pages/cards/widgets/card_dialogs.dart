import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/card/card_cubit.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/currency_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/card_entity.dart';

void showCardCreateDialog(BuildContext context) {
  int? selectedCardId;
  final limitCtrl = TextEditingController();
  final closingDayCtrl = TextEditingController();
  final dueDayCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final cardState = context.read<CardCubit>().state;
  final availableCards =
      cardState is CardLoaded ? cardState.availableCards : <CardEntity>[];

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
              Text('Novo Cartão', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedCardId,
                decoration: const InputDecoration(
                  labelText: 'Selecione o cartão',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                items: availableCards
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                validator: (v) => v == null ? 'Selecione um cartão' : null,
                onChanged: (v) => setLocalState(() => selectedCardId = v),
              ),
              const SizedBox(height: 12),
              CurrencyTextField(
                  controller: limitCtrl,
                  label: 'Limite',
                  validator: Validators.currency),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: closingDayCtrl,
                      label: 'Dia do fechamento',
                      keyboardType: TextInputType.number,
                      validator: Validators.dayOfMonth,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: dueDayCtrl,
                      label: 'Dia do vencimento',
                      keyboardType: TextInputType.number,
                      validator: Validators.dayOfMonth,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  ctx.read<CardCubit>().createCard({
                    'card_id': selectedCardId,
                    'credit_limit':
                        CurrencyTextField.parseValue(limitCtrl.text),
                    'closing_day': int.tryParse(closingDayCtrl.text) ?? 1,
                    'due_day': int.tryParse(dueDayCtrl.text) ?? 10,
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

void showCardEditDialog(BuildContext context, CardUser card) {
  final limitCtrl =
      TextEditingController(text: card.creditLimit.toStringAsFixed(2));
  final closingDayCtrl =
      TextEditingController(text: card.closingDay.toString());
  final dueDayCtrl = TextEditingController(text: card.dueDay.toString());
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
            Text('Editar Cartão', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              card.displayName,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            CurrencyTextField(
                controller: limitCtrl,
                label: 'Limite',
                validator: Validators.currency),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: closingDayCtrl,
                    label: 'Dia do fechamento',
                    keyboardType: TextInputType.number,
                    validator: Validators.dayOfMonth,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: dueDayCtrl,
                    label: 'Dia do vencimento',
                    keyboardType: TextInputType.number,
                    validator: Validators.dayOfMonth,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                ctx.read<CardCubit>().updateCard(card.id!, {
                  'credit_limit': CurrencyTextField.parseValue(limitCtrl.text),
                  'closing_day':
                      int.tryParse(closingDayCtrl.text) ?? card.closingDay,
                  'due_day': int.tryParse(dueDayCtrl.text) ?? card.dueDay,
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
