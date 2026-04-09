import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/income/income_cubit.dart';
import '../blocs/card/card_cubit.dart';
import '../blocs/bank/bank_cubit.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/bank_account.dart';
import 'app_text_field.dart';
import 'currency_text_field.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';

const _iconMap = <String, IconData>{
  'work': Icons.work,
  'computer': Icons.computer,
  'trending_up': Icons.trending_up,
  'home': Icons.home,
  'card_giftcard': Icons.card_giftcard,
  'flash_on': Icons.flash_on,
  'attach_money': Icons.attach_money,
};

const _incomeTypes = [
  {'value': 'salary', 'label': 'Salário', 'icon': 'work'},
  {'value': 'freelance', 'label': 'Freelance', 'icon': 'computer'},
  {'value': 'investment', 'label': 'Investimento', 'icon': 'trending_up'},
  {'value': 'rental', 'label': 'Aluguel', 'icon': 'home'},
  {'value': 'benefit', 'label': 'Benefício', 'icon': 'card_giftcard'},
  {'value': 'pix', 'label': 'Pix', 'icon': 'flash_on'},
  {'value': 'other', 'label': 'Outro', 'icon': 'attach_money'},
];

const _oneTimeTypes = ['pix', 'other'];

void showIncomeFormDialog(BuildContext context, {Income? editing}) {
  final titleCtrl = TextEditingController(text: editing?.title ?? '');
  final amountCtrl = TextEditingController(
    text: editing != null
        ? editing.amount.toStringAsFixed(2).replaceAll('.', ',')
        : '',
  );
  final descCtrl = TextEditingController(text: editing?.description ?? '');
  final paymentDayCtrl = TextEditingController(
    text: editing?.paymentDayValue?.toString() ?? '1',
  );
  String incomeType = editing?.type ?? 'salary';
  bool isRecurring = editing?.isRecurring ?? true;
  String paymentDayType = editing?.paymentDayType ?? 'fixed';
  DateTime receivedAt = editing?.receivedAt ?? DateTime.now();
  int? cardUserId = editing?.bankUserId;
  int? bankAccountId = editing?.bankAccountId;
  bool isActive = editing?.isActive ?? true;
  final formKey = GlobalKey<FormState>();

  context.read<CardCubit>().loadCards();
  context.read<BankCubit>().loadAccounts();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              final theme = Theme.of(context);
              return ListView(
                controller: scrollCtrl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editing != null ? 'Editar Receita' : 'Nova Receita',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tipo de renda',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.0,
                    children: _incomeTypes.map((t) {
                      final isSelected = incomeType == t['value'];
                      final iconKey = t['icon'] as String;
                      final icon = _iconMap[iconKey] ?? Icons.attach_money;
                      return GestureDetector(
                        onTap: () => setLocalState(() {
                          incomeType = t['value'] as String;
                          if (_oneTimeTypes.contains(incomeType)) {
                            isRecurring = false;
                          } else {
                            isRecurring = true;
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t['label'] as String,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight:
                                      isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isRecurring
                            ? 'Renda recorrente (mensal)'
                            : 'Renda única (avulsa)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: isRecurring,
                        onChanged: (v) => setLocalState(() => isRecurring = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: titleCtrl,
                    label: 'Título',
                    prefixIcon: Icons.description,
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  CurrencyTextField(
                    controller: amountCtrl,
                    label: 'Valor',
                    validator: Validators.currency,
                  ),
                  const SizedBox(height: 12),
                  if (isRecurring) ...[
                    DropdownButtonFormField<String>(
                      value: paymentDayType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de dia',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'fixed', child: Text('Dia fixo do mês')),
                        DropdownMenuItem(
                            value: 'business_day',
                            child: Text('Dia útil do mês')),
                      ],
                      onChanged: (v) =>
                          setLocalState(() => paymentDayType = v ?? 'fixed'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: paymentDayCtrl,
                      label: paymentDayType == 'fixed'
                          ? 'Dia do mês'
                          : 'Nº do dia útil',
                      prefixIcon: Icons.today,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Mínimo 1';
                        final max = paymentDayType == 'fixed' ? 31 : 25;
                        if (n > max) return 'Máximo $max';
                        return null;
                      },
                    ),
                  ] else ...[
                    AppTextField(
                      label: 'Data de recebimento',
                      prefixIcon: Icons.calendar_today,
                      readOnly: true,
                      controller: TextEditingController(
                        text: DateFormatter.shortDate(receivedAt),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: receivedAt,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setLocalState(() => receivedAt = picked);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: descCtrl,
                    label: 'Descrição (opcional)',
                    prefixIcon: Icons.notes,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<CardCubit, CardState>(
                    builder: (context, state) {
                      final cards =
                          state is CardLoaded ? state.cards : <CardUser>[];
                      return DropdownButtonFormField<int>(
                        value: cardUserId,
                        decoration: const InputDecoration(
                          labelText: 'Cartão vinculado (opcional)',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Nenhum'),
                          ),
                          ...cards.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.cardName ?? 'Cartão #${c.id}'),
                              )),
                        ],
                        onChanged: (v) => setLocalState(() => cardUserId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<BankCubit, BankState>(
                    builder: (context, state) {
                      final accounts =
                          state is BankLoaded ? state.accounts : <BankAccount>[];
                      return DropdownButtonFormField<int>(
                        value: bankAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Conta bancária (opcional)',
                          prefixIcon: Icon(Icons.account_balance),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Nenhuma'),
                          ),
                          ...accounts.map((a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.displayName),
                              )),
                        ],
                        onChanged: (v) =>
                            setLocalState(() => bankAccountId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        onChanged: (v) =>
                            setLocalState(() => isActive = v ?? true),
                      ),
                      Text(
                        'Renda ativa',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final data = <String, dynamic>{
                          'title': titleCtrl.text.trim(),
                          'amount': CurrencyTextField.parseValue(amountCtrl.text),
                          'type': incomeType,
                          'is_recurring': isRecurring,
                          'is_active': isActive,
                          'description': descCtrl.text.trim().isEmpty
                              ? null
                              : descCtrl.text.trim(),
                          if (cardUserId != null) 'bank_user_id': cardUserId,
                          if (bankAccountId != null)
                            'bank_account_id': bankAccountId,
                        };
                        if (isRecurring) {
                          data['payment_day_type'] = paymentDayType;
                          data['payment_day_value'] =
                              int.tryParse(paymentDayCtrl.text) ?? 1;
                        } else {
                          data['received_at'] =
                              receivedAt.toIso8601String().substring(0, 10);
                          data['payment_day_type'] = 'fixed';
                          data['payment_day_value'] = 1;
                        }
                        if (editing != null) {
                          context
                              .read<IncomeCubit>()
                              .updateIncome(editing.id!, data);
                        } else {
                          context.read<IncomeCubit>().createIncome(data);
                        }
                        Navigator.pop(ctx);
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        editing != null ? 'Atualizar' : 'Cadastrar',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
