import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/income/income_cubit.dart';
import '../../blocs/card/card_cubit.dart';
import '../../blocs/bank/bank_cubit.dart';
import '../../../domain/entities/card_entity.dart';
import '../../../domain/entities/bank_account.dart';
import '../../../domain/repositories/income_repository.dart';
import '../../../core/di/injection_container.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/form_section_card.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/pressable_scale.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/theme/app_tokens.dart';

const _incomeTypeIcons = <String, IconData>{
  'salary': Icons.work_rounded,
  'freelance': Icons.computer_rounded,
  'investment': Icons.trending_up_rounded,
  'rental': Icons.home_rounded,
  'benefit': Icons.card_giftcard_rounded,
  'pix': Icons.flash_on_rounded,
  'other': Icons.attach_money_rounded,
};

const _incomeTypes = [
  {'value': 'salary', 'label': 'Salário'},
  {'value': 'freelance', 'label': 'Freelance'},
  {'value': 'investment', 'label': 'Investimento'},
  {'value': 'rental', 'label': 'Aluguel'},
  {'value': 'benefit', 'label': 'Benefício'},
  {'value': 'pix', 'label': 'Pix'},
  {'value': 'other', 'label': 'Outro'},
];

const _oneTimeTypes = ['pix', 'other'];

/// "Nova Receita"/"Editar Receita" -- structurally mirrors
/// `TransactionFormPage` 1:1 (same `PageHeader`, spacing rhythm, submit
/// button treatment, page-push transition) so the income and
/// debit/credit forms behave and animate identically, per design.
class IncomeFormPage extends StatefulWidget {
  final int? incomeId;
  const IncomeFormPage({super.key, this.incomeId});

  @override
  State<IncomeFormPage> createState() => _IncomeFormPageState();
}

class _IncomeFormPageState extends State<IncomeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _paymentDayController = TextEditingController(text: '1');
  late TextEditingController _dateController;

  String _incomeType = 'salary';
  bool _isRecurring = true;
  String _paymentDayType = 'fixed';
  DateTime _receivedAt = DateTime.now();
  int? _cardUserId;
  int? _bankAccountId;
  bool _isActive = true;
  bool _isLoadingIncome = false;
  bool get _isEditing => widget.incomeId != null;

  @override
  void initState() {
    super.initState();
    _dateController =
        TextEditingController(text: DateFormatter.shortDate(_receivedAt));
    context.read<CardCubit>().loadCards();
    context.read<BankCubit>().loadAccounts();
    if (_isEditing) _loadIncome();
  }

  Future<void> _loadIncome() async {
    setState(() => _isLoadingIncome = true);
    try {
      final repo = sl<IncomeRepository>();
      final incomes = await repo.getIncomes();
      final income = incomes.firstWhere((i) => i.id == widget.incomeId);
      if (!mounted) return;
      setState(() {
        _titleController.text = income.title;
        _amountController.text =
            income.amount.toStringAsFixed(2).replaceAll('.', ',');
        _descController.text = income.description ?? '';
        _incomeType = income.type;
        _isRecurring = income.isRecurring;
        _paymentDayType = income.paymentDayType ?? 'fixed';
        _paymentDayController.text =
            income.paymentDayValue?.toString() ?? '1';
        _receivedAt = income.receivedAt ?? DateTime.now();
        _dateController.text = DateFormatter.shortDate(_receivedAt);
        _cardUserId = income.bankUserId;
        _bankAccountId = income.bankAccountId;
        _isActive = income.isActive;
        _isLoadingIncome = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingIncome = false);
      debugPrint('[IncomeForm] Error loading income: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    _paymentDayController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'amount': CurrencyTextField.parseValue(_amountController.text),
      'type': _incomeType,
      'is_recurring': _isRecurring,
      'is_active': _isActive,
      'description':
          _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      if (_cardUserId != null) 'bank_user_id': _cardUserId,
      if (_bankAccountId != null) 'bank_account_id': _bankAccountId,
    };
    if (_isRecurring) {
      data['payment_day_type'] = _paymentDayType;
      data['payment_day_value'] = int.tryParse(_paymentDayController.text) ?? 1;
    } else {
      data['received_at'] = _receivedAt.toIso8601String().substring(0, 10);
      data['payment_day_type'] = 'fixed';
      data['payment_day_value'] = 1;
    }
    if (_isEditing) {
      context.read<IncomeCubit>().updateIncome(widget.incomeId!, data);
    } else {
      context.read<IncomeCubit>().createIncome(data);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          PageHeader(
              title: _isEditing ? 'Editar Receita' : 'Nova Receita',
              showBackButton: true,
              bottomPadding: 24),
          Expanded(
            child: _isLoadingIncome
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: ResponsiveContent(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FormSectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tipo de renda',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GridView.count(
                                    crossAxisCount: 4,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 1.0,
                                    children: _incomeTypes.map((t) {
                                      final value = t['value']!;
                                      final isSelected = _incomeType == value;
                                      final icon = _incomeTypeIcons[value] ??
                                          Icons.attach_money_rounded;
                                      return PressableScale(
                                        child: GestureDetector(
                                          onTap: () => setState(() {
                                            _incomeType = value;
                                            _isRecurring =
                                                !_oneTimeTypes.contains(value);
                                          }),
                                          child: AnimatedContainer(
                                            duration:
                                                const Duration(milliseconds: 200),
                                            curve: Curves.easeOutCubic,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                      .withValues(alpha: 0.12)
                                                  : theme.colorScheme
                                                      .surfaceContainerHighest
                                                      .withValues(alpha: 0.5),
                                              borderRadius: AppRadius.cardCut(
                                                  open: 14, tight: 4),
                                              border: Border.all(
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme
                                                        .outlineVariant
                                                        .withValues(alpha: 0.3),
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  icon,
                                                  color: isSelected
                                                      ? theme.colorScheme.primary
                                                      : theme.colorScheme
                                                          .onSurfaceVariant,
                                                  size: 22,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  t['label']!,
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: isSelected
                                                        ? theme
                                                            .colorScheme.primary
                                                        : theme.colorScheme
                                                            .onSurfaceVariant,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _isRecurring
                                            ? 'Renda recorrente (mensal)'
                                            : 'Renda única (avulsa)',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Switch(
                                        value: _isRecurring,
                                        onChanged: (v) =>
                                            setState(() => _isRecurring = v),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            FormSectionCard(
                              child: Column(
                                children: [
                                  AppTextField(
                                    controller: _titleController,
                                    label: 'Título',
                                    prefixIcon: Icons.description,
                                    validator: Validators.required,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 16),
                                  CurrencyTextField(
                                    controller: _amountController,
                                    label: 'Valor',
                                    validator: Validators.currency,
                                  ),
                                  const SizedBox(height: 16),
                                  if (_isRecurring) ...[
                                    DropdownButtonFormField<String>(
                                      initialValue: _paymentDayType,
                                      decoration: const InputDecoration(
                                        labelText: 'Tipo de dia',
                                        prefixIcon: Icon(Icons.calendar_today),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'fixed',
                                            child: Text('Dia fixo do mês')),
                                        DropdownMenuItem(
                                            value: 'business_day',
                                            child: Text('Dia útil do mês')),
                                      ],
                                      onChanged: (v) => setState(
                                          () => _paymentDayType = v ?? 'fixed'),
                                    ),
                                    const SizedBox(height: 16),
                                    AppTextField(
                                      controller: _paymentDayController,
                                      label: _paymentDayType == 'fixed'
                                          ? 'Dia do mês'
                                          : 'Nº do dia útil',
                                      prefixIcon: Icons.today,
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        final n = int.tryParse(v ?? '');
                                        if (n == null || n < 1) return 'Mínimo 1';
                                        final max =
                                            _paymentDayType == 'fixed' ? 31 : 25;
                                        if (n > max) return 'Máximo $max';
                                        return null;
                                      },
                                    ),
                                  ] else ...[
                                    AppTextField(
                                      label: 'Data de recebimento',
                                      prefixIcon: Icons.calendar_today,
                                      readOnly: true,
                                      controller: _dateController,
                                      suffix: Container(
                                        width: 40,
                                        height: 40,
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.lg),
                                        ),
                                        child: Icon(
                                          Icons.calendar_month,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ),
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: _receivedAt,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _receivedAt = picked;
                                            _dateController.text =
                                                DateFormatter.shortDate(picked);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    controller: _descController,
                                    label: 'Observações',
                                    prefixIcon: Icons.notes,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  BlocBuilder<CardCubit, CardState>(
                                    builder: (context, state) {
                                      final cards = state is CardLoaded
                                          ? state.cards
                                          : <CardUser>[];
                                      return DropdownButtonFormField<int>(
                                        initialValue: _cardUserId,
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Cartão vinculado (opcional)',
                                          prefixIcon: Icon(Icons.credit_card),
                                        ),
                                        items: [
                                          const DropdownMenuItem<int>(
                                            value: null,
                                            child: Text('Nenhum'),
                                          ),
                                          ...cards.map((c) => DropdownMenuItem(
                                                value: c.id,
                                                child: Text(c.cardName ??
                                                    'Cartão #${c.id}'),
                                              )),
                                        ],
                                        onChanged: (v) =>
                                            setState(() => _cardUserId = v),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  BlocBuilder<BankCubit, BankState>(
                                    builder: (context, state) {
                                      final accounts = state is BankLoaded
                                          ? state.accounts
                                          : <BankAccount>[];
                                      return DropdownButtonFormField<int>(
                                        initialValue: _bankAccountId,
                                        decoration: const InputDecoration(
                                          labelText: 'Conta bancária (opcional)',
                                          prefixIcon:
                                              Icon(Icons.account_balance),
                                        ),
                                        items: [
                                          const DropdownMenuItem<int>(
                                            value: null,
                                            child: Text('Nenhuma'),
                                          ),
                                          ...accounts
                                              .map((a) => DropdownMenuItem(
                                                    value: a.id,
                                                    child: Text(a.displayName),
                                                  )),
                                        ],
                                        onChanged: (v) =>
                                            setState(() => _bankAccountId = v),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isActive,
                                        onChanged: (v) =>
                                            setState(() => _isActive = v ?? true),
                                      ),
                                      Text('Renda ativa',
                                          style: theme.textTheme.bodyMedium),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.xxl),
                                boxShadow: AppShadows.buttonPrimary(
                                    theme.colorScheme.primary),
                              ),
                              child: PressableScale(
                                child: SizedBox(
                                  height: 56,
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: _submit,
                                    style: FilledButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.xxl),
                                      ),
                                    ),
                                    child: Text(
                                      _isEditing ? 'Atualizar' : 'Salvar',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
