import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/bank/bank_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/stat_card.dart';
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
  }

  void _loadData() => context.read<BankCubit>().loadAccounts();

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    String accountType = 'corrente';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setLocalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nova Conta Bancária', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                AppTextField(
                  controller: nameCtrl,
                  label: 'Nome da conta',
                  prefixIcon: Icons.account_balance,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                CurrencyTextField(controller: balanceCtrl, label: 'Saldo inicial'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: accountType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'corrente', child: Text('Corrente')),
                    DropdownMenuItem(value: 'poupanca', child: Text('Poupança')),
                    DropdownMenuItem(value: 'investimento', child: Text('Investimento')),
                    DropdownMenuItem(value: 'carteira', child: Text('Carteira')),
                  ],
                  onChanged: (v) => setLocalState(() => accountType = v ?? 'corrente'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    context.read<BankCubit>().createAccount({
                      'nome': nameCtrl.text.trim(),
                      'saldo': double.tryParse(balanceCtrl.text.replaceAll(',', '.')) ?? 0,
                      'tipo': accountType,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas Bancárias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Transferir',
            onPressed: () => context.push('/bank-transfer'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<BankCubit, BankState>(
        builder: (context, state) {
          if (state is BankLoading) return const AppLoadingIndicator();
          if (state is BankError) return AppErrorWidget(message: state.message, onRetry: _loadData);
          if (state is BankLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.stats != null) ...[
                    StatCard(
                      title: 'Saldo Total',
                      value: CurrencyFormatter.format(state.stats!.totalBalance),
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (state.accounts.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.account_balance,
                      title: 'Nenhuma conta',
                      subtitle: 'Adicione sua conta bancária',
                    )
                  else
                    ...state.accounts.map((account) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key('bank_${account.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: theme.colorScheme.error,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => ConfirmDialog.show(
                          context,
                          title: 'Excluir conta',
                          message: 'Deseja excluir "${account.displayName}"?',
                          confirmText: 'Excluir',
                          confirmColor: theme.colorScheme.error,
                        ),
                        onDismissed: (_) => context.read<BankCubit>().deleteAccount(account.id!),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.account_balance, color: theme.colorScheme.primary, size: 20),
                          ),
                          title: Text(account.displayName),
                          subtitle: Text(_typeLabel(account.accountType ?? 'corrente')),
                          trailing: Text(
                            CurrencyFormatter.format(account.balance),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: account.balance >= 0 ? Colors.green : theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
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
