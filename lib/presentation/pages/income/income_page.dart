import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/income/income_cubit.dart';
import '../../blocs/card/card_cubit.dart';
import '../../blocs/bank/bank_cubit.dart';
import '../../../domain/entities/income.dart';
import '../../../domain/entities/card_entity.dart';
import '../../../domain/entities/bank_account.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';

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
  {'value': 'salary', 'label': 'Sal\u00e1rio', 'icon': 'work'},
  {'value': 'freelance', 'label': 'Freelance', 'icon': 'computer'},
  {'value': 'investment', 'label': 'Investimento', 'icon': 'trending_up'},
  {'value': 'rental', 'label': 'Aluguel', 'icon': 'home'},
  {'value': 'benefit', 'label': 'Benef\u00edcio', 'icon': 'card_giftcard'},
  {'value': 'pix', 'label': 'Pix', 'icon': 'flash_on'},
  {'value': 'other', 'label': 'Outro', 'icon': 'attach_money'},
];

const _oneTimeTypes = ['pix', 'other'];

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context
        .read<IncomeCubit>()
        .loadIncomes(month: DateFormatter.monthKey(_selectedMonth));
  }

  void _showIncomeDialog({Income? editing}) {
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
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.1)
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
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
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
                              : 'Renda \u00fanica (avulsa)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: isRecurring,
                          onChanged: (v) =>
                              setLocalState(() => isRecurring = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: titleCtrl,
                      label: 'T\u00edtulo',
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
                              value: 'fixed',
                              child: Text('Dia fixo do m\u00eas')),
                          DropdownMenuItem(
                              value: 'business_day',
                              child: Text('Dia \u00fatil do m\u00eas')),
                        ],
                        onChanged: (v) =>
                            setLocalState(() => paymentDayType = v ?? 'fixed'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: paymentDayCtrl,
                        label: paymentDayType == 'fixed'
                            ? 'Dia do m\u00eas'
                            : 'N\u00ba do dia \u00fatil',
                        prefixIcon: Icons.today,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1) return 'M\u00ednimo 1';
                          final max = paymentDayType == 'fixed' ? 31 : 25;
                          if (n > max) return 'M\u00e1ximo $max';
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
                      label: 'Descri\u00e7\u00e3o (opcional)',
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
                            labelText: 'Cart\u00e3o vinculado (opcional)',
                            prefixIcon: Icon(Icons.credit_card),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Nenhum'),
                            ),
                            ...cards.map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                      c.cardName ?? 'Cart\u00e3o #${c.id}'),
                                )),
                          ],
                          onChanged: (v) =>
                              setLocalState(() => cardUserId = v),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<BankCubit, BankState>(
                      builder: (context, state) {
                        final accounts = state is BankLoaded
                            ? state.accounts
                            : <BankAccount>[];
                        return DropdownButtonFormField<int>(
                          value: bankAccountId,
                          decoration: const InputDecoration(
                            labelText: 'Conta banc\u00e1ria (opcional)',
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
                            'amount':
                                CurrencyTextField.parseValue(amountCtrl.text),
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
                            data['received_at'] = receivedAt
                                .toIso8601String()
                                .substring(0, 10);
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

  void _showCreateDialog() => _showIncomeDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: _showCreateDialog,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Receitas',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          MonthSelector(
            selectedMonth: _selectedMonth,
            onChanged: (date) {
              setState(() => _selectedMonth = date);
              _loadData();
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<IncomeCubit, IncomeState>(
              builder: (context, state) {
                if (state is IncomeLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 6);
                }
                if (state is IncomeError)
                  return AppErrorWidget(
                      message: state.message, onRetry: _loadData);
                if (state is IncomeLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (state.summary != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: 'Total Mensal',
                                  value: CurrencyFormatter.format(
                                      state.summary!.totalMonthly),
                                  icon: Icons.trending_up,
                                  iconColor: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: StatCard(
                                  title: 'Ativas',
                                  value: '${state.summary!.activeCount}',
                                  icon: Icons.check_circle,
                                  iconColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (state.incomes.isEmpty)
                          const EmptyStateWidget(
                            icon: Icons.trending_up,
                            title: 'Nenhuma receita',
                            subtitle: 'Adicione sua primeira receita',
                          )
                        else ...[
                          SectionHeader(
                            title: 'Suas Receitas',
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 12),
                          ...state.incomes.map((income) {
                            final isReceived = income.isActive;
                            final iconColor =
                                isReceived ? Colors.green : Colors.orange;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Dismissible(
                                key: Key('income_${income.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                confirmDismiss: (_) => ConfirmDialog.show(
                                  context,
                                  title: 'Excluir receita',
                                  message:
                                      'Deseja excluir "${income.title}"?',
                                  confirmText: 'Excluir',
                                  confirmColor: theme.colorScheme.error,
                                ),
                                onDismissed: (_) => context
                                    .read<IncomeCubit>()
                                    .deleteIncome(income.id!),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.colorScheme.outlineVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color:
                                              iconColor.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isReceived
                                              ? Icons.check_circle
                                              : Icons.schedule,
                                          color: iconColor,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              income.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Text(
                                                  income.typeLabel,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                if (income.isRecurring) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 6,
                                                            vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFF3B82F6)
                                                          .withValues(
                                                              alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: const Text(
                                                      'Recorrente',
                                                      style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            Color(0xFF3B82F6),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            CurrencyFormatter.format(
                                                income.amount),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green,
                                            ),
                                          ),
                                          if (!isReceived) ...[
                                            const SizedBox(height: 4),
                                            GestureDetector(
                                              onTap: () => context
                                                  .read<IncomeCubit>()
                                                  .markAsReceived(income.id!),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  'Receber',
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined,
                                            size: 18,
                                            color: theme
                                                .colorScheme.onSurfaceVariant),
                                        onPressed: () =>
                                            _showIncomeDialog(editing: income),
                                        constraints: const BoxConstraints(
                                            maxWidth: 32, maxHeight: 32),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
