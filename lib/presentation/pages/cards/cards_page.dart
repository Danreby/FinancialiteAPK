import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/card/card_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/card_entity.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() => context.read<CardCubit>().loadCards();

  void _showCreateDialog() {
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
                Text('Novo Cartão',
                    style: Theme.of(ctx).textTheme.titleLarge),
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
                  validator: (v) =>
                      v == null ? 'Selecione um cartão' : null,
                  onChanged: (v) =>
                      setLocalState(() => selectedCardId = v),
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
                    context.read<CardCubit>().createCard({
                      'card_id': selectedCardId,
                      'credit_limit': CurrencyTextField.parseValue(limitCtrl.text),
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

  void _showEditDialog(CardUser card) {
    final limitCtrl = TextEditingController(text: card.creditLimit.toStringAsFixed(2));
    final closingDayCtrl = TextEditingController(text: card.closingDay.toString());
    final dueDayCtrl = TextEditingController(text: card.dueDay.toString());
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
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
              CurrencyTextField(controller: limitCtrl, label: 'Limite', validator: Validators.currency),
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
                  context.read<CardCubit>().updateCard(card.id!, {
                    'credit_limit': CurrencyTextField.parseValue(limitCtrl.text),
                    'closing_day': int.tryParse(closingDayCtrl.text) ?? card.closingDay,
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

  static const _cardGradients = [
    [Color(0xFF1A1A2E), Color(0xFF16213E)],
    [Color(0xFF0F3460), Color(0xFF533483)],
    [Color(0xFF2C3E50), Color(0xFF3498DB)],
    [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    [Color(0xFF1B5E20), Color(0xFF388E3C)],
  ];

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
          borderRadius: BorderRadius.circular(16),
        ),
        child: FloatingActionButton(
          onPressed: _showCreateDialog,
          child: const Icon(Icons.add),
        ),
      ),
      body: BlocBuilder<CardCubit, CardState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Cartões',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody(context, state, theme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CardState state, ThemeData theme) {
    if (state is CardLoading) {
      return const AppLoadingIndicator(useShimmer: true, shimmerLines: 4);
    }
    if (state is CardError) {
      return AppErrorWidget(message: state.message, onRetry: _loadData);
    }
    if (state is CardLoaded) {
      if (state.cards.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.credit_card, size: 40, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum cartão',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Adicione seu primeiro cartão',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: _showCreateDialog,
                child: const Text('Novo cartão'),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: state.cards.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SectionHeader(title: 'Seus Cartões'),
              );
            }
            final cardIndex = index - 1;
            final card = state.cards[cardIndex];
            final spending = card.currentSpending ?? 0;
            final usedPercent = card.creditLimit > 0
                ? (spending / card.creditLimit * 100).clamp(0.0, 100.0)
                : 0.0;
            final gradient = _cardGradients[cardIndex % _cardGradients.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Dismissible(
                key: Key('card_${card.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => ConfirmDialog.show(
                  context,
                  title: 'Excluir cartão',
                  message: 'Deseja excluir "${card.displayName}"?',
                  confirmText: 'Excluir',
                  confirmColor: theme.colorScheme.error,
                ),
                onDismissed: (_) => context.read<CardCubit>().deleteCard(card.id!),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [gradient[0], gradient[1]],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                card.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                              onPressed: () => _showEditDialog(card),
                              constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 40,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fatura atual',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(spending),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Limite',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.format(card.creditLimit),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: usedPercent / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            color: usedPercent > 80
                                ? Colors.redAccent.shade100
                                : Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fecha dia ${card.closingDay} • Vence dia ${card.dueDay}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '${usedPercent.toStringAsFixed(0)}% usado',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
