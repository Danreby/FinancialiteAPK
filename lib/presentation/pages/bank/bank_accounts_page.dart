import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/bank/bank_cubit.dart';
import '../../../domain/entities/bank_account.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';

class BankAccountsPage extends StatefulWidget {
  const BankAccountsPage({super.key});

  @override
  State<BankAccountsPage> createState() => _BankAccountsPageState();
}

class _BankAccountsPageState extends State<BankAccountsPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankCubit>().loadBanks();
    });
  }

  void _loadData() => context.read<BankCubit>().loadAccounts();

  void _showCreateDialog() {
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

  void _showEditDialog(BankAccount account) {
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
    );
  }

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
      body: BlocBuilder<BankCubit, BankState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Contas Bancárias',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.swap_horiz,
                            color: theme.colorScheme.primary, size: 20),
                        tooltip: 'Transferir',
                        onPressed: () => context.push('/bank-transfer'),
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

  Widget _buildBody(BuildContext context, BankState state, ThemeData theme) {
    if (state is BankLoading) {
      return const AppLoadingIndicator(useShimmer: true, shimmerLines: 5);
    }
    if (state is BankError) {
      return AppErrorWidget(message: state.message, onRetry: _loadData);
    }
    if (state is BankLoaded) {
      return RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            if (state.stats != null) ...[
              StatCard(
                title: 'Saldo Total',
                value: CurrencyFormatter.format(state.stats!.totalBalance),
                icon: Icons.account_balance_wallet,
                iconColor: Colors.green,
              ),
              const SizedBox(height: 20),
            ],
            if (state.accounts.isNotEmpty) ...[
              const SectionHeader(title: 'Suas Contas'),
              const SizedBox(height: 12),
            ],
            if (state.accounts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(Icons.account_balance,
                            size: 40, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma conta',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Adicione sua conta bancária',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...state.accounts.map((account) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: Key('bank_${account.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => ConfirmDialog.show(
                        context,
                        title: 'Excluir conta',
                        message: 'Deseja excluir "${account.displayName}"?',
                        confirmText: 'Excluir',
                        confirmColor: theme.colorScheme.error,
                      ),
                      onDismissed: (_) =>
                          context.read<BankCubit>().deleteAccount(account.id!),
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.account_balance,
                                  color: theme.colorScheme.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.displayName,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _typeLabel(
                                        account.accountType ?? 'corrente'),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(account.balance),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: account.balance >= 0
                                    ? Colors.green
                                    : theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant),
                              onPressed: () => _showEditDialog(account),
                              constraints: const BoxConstraints(
                                  maxWidth: 32, maxHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'corrente':
        return 'Conta Corrente';
      case 'poupanca':
        return 'Poupança';
      case 'investimento':
        return 'Investimento';
      case 'carteira':
        return 'Carteira';
      default:
        return type;
    }
  }
}
