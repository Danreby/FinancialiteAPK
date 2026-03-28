import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';

class FaturasPage extends StatelessWidget {
  const FaturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionBloc(sl<TransactionRepository>()),
      child: const _FaturasView(),
    );
  }
}

class _FaturasView extends StatefulWidget {
  const _FaturasView();

  @override
  State<_FaturasView> createState() => _FaturasViewState();
}

class _FaturasViewState extends State<_FaturasView> {
  DateTime _selectedMonth = DateTime.now();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<TransactionBloc>().add(TransactionsFetched(
          reset: true,
          filters: {
            'month': DateFormatter.monthKey(_selectedMonth),
            'type': 'credit',
          },
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(const TransactionsFetched());
    }
  }

  String _monthKey() => DateFormatter.monthKey(_selectedMonth);

  /// Find the parcela matching this month for a given transaction
  TransactionParcela? _parcelaForMonth(Transaction t) {
    final mk = _monthKey();
    return t.parcelas?.cast<TransactionParcela?>().firstWhere(
          (p) => p!.monthKey == mk,
          orElse: () => null,
        );
  }

  /// Get per-installment amount
  double _installmentAmount(Transaction t) {
    final parcela = _parcelaForMonth(t);
    if (parcela != null && parcela.amount > 0) return parcela.amount;
    if (t.installments > 1) return t.amount / t.installments;
    return t.amount;
  }

  /// Get the display installment number for this month
  int? _currentInstallment(Transaction t) {
    final parcela = _parcelaForMonth(t);
    if (parcela != null) return parcela.parcelaNumber;
    return null;
  }

  /// Get installment status for this month
  String _installmentStatus(Transaction t) {
    final parcela = _parcelaForMonth(t);
    if (parcela != null) {
      if (parcela.paidAt != null || parcela.status == 'paid') return 'paid';
      if (parcela.dueDate != null &&
          parcela.dueDate!.isBefore(DateTime.now())) {
        return 'overdue';
      }
      return 'pending';
    }
    // Fallback to transaction status
    return t.status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 8,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 18, color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Faturas',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: MonthSelector(
              selectedMonth: _selectedMonth,
              onChanged: (date) {
                setState(() => _selectedMonth = date);
                _loadData();
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 6);
                }
                if (state is TransactionError) {
                  return AppErrorWidget(
                      message: state.message, onRetry: _loadData);
                }
                if (state is TransactionLoaded) {
                  final credits = state.transactions
                      .where((t) => t.type == 'credit')
                      .toList();
                  if (credits.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.receipt_long,
                      title: 'Nenhuma fatura',
                      subtitle: 'Não há faturas registradas neste mês',
                    );
                  }

                  final total =
                      credits.fold(0.0, (s, t) => s + _installmentAmount(t));
                  final paidCount = credits
                      .where((t) => _installmentStatus(t) == 'paid')
                      .length;

                  return Column(
                    children: [
                      // Summary card
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.error,
                                theme.colorScheme.error.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.credit_card,
                                    color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total do Mês',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(total),
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$paidCount/${credits.length}',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'pagas',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 32),
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            indent: 74,
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                          itemCount: credits.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i >= credits.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              );
                            }
                            final t = credits[i];
                            return _FaturaItemTile(
                              transaction: t,
                              installmentAmount: _installmentAmount(t),
                              currentInstallment: _currentInstallment(t),
                              status: _installmentStatus(t),
                              onTap: () =>
                                  context.push('/transactions/${t.id}'),
                            );
                          },
                        ),
                      ),
                    ],
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

class _FaturaItemTile extends StatelessWidget {
  final Transaction transaction;
  final double installmentAmount;
  final int? currentInstallment;
  final String status;
  final VoidCallback? onTap;

  const _FaturaItemTile({
    required this.transaction,
    required this.installmentAmount,
    this.currentInstallment,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasInstallments = transaction.installments > 1;
    final isRecurring = transaction.isRecurring;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (colorFromHex(transaction.categoryColor) ??
                        theme.colorScheme.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconFromName(transaction.categoryIcon),
                size: 22,
                color: colorFromHex(transaction.categoryColor) ??
                    theme.colorScheme.error,
              ),
            ),
            const SizedBox(width: 14),
            // Title, subtitle, badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Installment badge
                      if (hasInstallments) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF7C3AED).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${currentInstallment ?? '?'}/${transaction.installments}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      // Recurring badge
                      if (isRecurring) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF3B82F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Recorrente',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      // Status badge
                      _statusBadge(theme),
                      // Card name
                      if (transaction.cardName != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            transaction.cardName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount
            Text(
              '- ${CurrencyFormatter.format(installmentAmount)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.error,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(ThemeData theme) {
    Color color;
    String label;

    switch (status) {
      case 'paid':
        color = const Color(0xFF10B981);
        label = 'Pago';
        break;
      case 'overdue':
        color = theme.colorScheme.error;
        label = 'Vencido';
        break;
      default:
        color = theme.colorScheme.onSurfaceVariant;
        label = 'Em aberto';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
