import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/card/card_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';

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
    final nameCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    final closingDayCtrl = TextEditingController();
    final dueDayCtrl = TextEditingController();
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
              Text('Novo Cartão', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: nameCtrl,
                label: 'Nome do cartão',
                prefixIcon: Icons.credit_card,
                validator: Validators.required,
              ),
              const SizedBox(height: 12),
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
                  context.read<CardCubit>().createCard({
                    'nome': nameCtrl.text.trim(),
                    'limite': double.tryParse(limitCtrl.text.replaceAll(',', '.')) ?? 0,
                    'dia_fechamento': int.tryParse(closingDayCtrl.text) ?? 1,
                    'dia_vencimento': int.tryParse(dueDayCtrl.text) ?? 10,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cartões')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<CardCubit, CardState>(
        builder: (context, state) {
          if (state is CardLoading) return const AppLoadingIndicator();
          if (state is CardError) return AppErrorWidget(message: state.message, onRetry: _loadData);
          if (state is CardLoaded) {
            if (state.cards.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.credit_card,
                title: 'Nenhum cartão',
                subtitle: 'Adicione seu primeiro cartão',
                actionLabel: 'Novo cartão',
                onAction: _showCreateDialog,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.cards.length,
                itemBuilder: (context, index) {
                  final card = state.cards[index];
                  final spending = card.currentSpending ?? 0;
                  final usedPercent = card.creditLimit > 0
                      ? (spending / card.creditLimit * 100).clamp(0.0, 100.0)
                      : 0.0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: Key('card_${card.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: theme.colorScheme.error,
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
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.credit_card, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(card.displayName,
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Fatura atual', style: theme.textTheme.bodySmall),
                                    Text(CurrencyFormatter.format(spending),
                                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Limite', style: theme.textTheme.bodySmall),
                                    Text(CurrencyFormatter.format(card.creditLimit),
                                        style: theme.textTheme.titleSmall),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: usedPercent / 100,
                                minHeight: 6,
                                color: usedPercent > 80 ? theme.colorScheme.error : theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha dia ${card.closingDay} • Vence dia ${card.dueDay}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
