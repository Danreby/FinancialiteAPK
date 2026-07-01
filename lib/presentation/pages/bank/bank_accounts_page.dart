import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/bank/bank_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/page_header.dart';
import '../../widgets/shadowed_fab.dart';
import 'widgets/bank_account_card.dart';
import 'widgets/bank_dialogs.dart';
import '../../../core/theme/app_tokens.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton:
          ShadowedFab(onPressed: () => showBankCreateDialog(context)),
      body: BlocBuilder<BankCubit, BankState>(
        builder: (context, state) {
          return Column(
            children: [
              PageHeader(
                title: 'Contas Bancárias',
                bottomPadding: 16,
                trailing: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
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
              const EmptyStateWidget(
                icon: Icons.account_balance,
                title: 'Nenhuma conta',
                subtitle: 'Adicione sua conta bancária',
              )
            else
              ...state.accounts.map((account) => BankAccountCard(
                    account: account,
                    onConfirmDismiss: () => ConfirmDialog.show(
                      context,
                      title: 'Excluir conta',
                      message: 'Deseja excluir "${account.displayName}"?',
                      confirmText: 'Excluir',
                      confirmColor: theme.colorScheme.error,
                    ),
                    onDismissed: () =>
                        context.read<BankCubit>().deleteAccount(account.id!),
                    onEdit: () => showBankEditDialog(context, account),
                  )),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
