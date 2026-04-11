import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/page_header.dart';

class FaturasPage extends StatefulWidget {
  const FaturasPage({super.key});

  @override
  State<FaturasPage> createState() => _FaturasPageState();
}

class _FaturasPageState extends State<FaturasPage> {
  DateTime _selectedMonth = DateTime.now();
  final _scrollController = ScrollController();
  final _repo = sl<TransactionRepository>();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _monthData = {};
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _repo.getFaturas(
        month: DateFormatter.monthKey(_selectedMonth),
      );
      if (!mounted) return;
      final items = (data['items'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      setState(() {
        _monthData = data;
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const PageHeader(title: 'Faturas', showBackButton: true),
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
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const AppLoadingIndicator(useShimmer: true, shimmerLines: 6);
    }
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _loadData);
    }
    if (_items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long,
        title: 'Nenhuma fatura',
        subtitle: 'Nao ha faturas registradas neste mes',
      );
    }

    final totalSpent = (_monthData['total_spent'] as num?)?.toDouble() ?? 0.0;
    final totalPaid = (_monthData['total_paid'] as num?)?.toDouble() ?? 0.0;
    final isPaid = _monthData['is_paid'] == true;
    final isPartiallyPaid = _monthData['is_partially_paid'] == true;
    final paidItems = _items.where((i) => i['status'] == 'paid').length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isPaid ? const Color(0xFF10B981) : theme.colorScheme.error,
                    (isPaid ? const Color(0xFF10B981) : theme.colorScheme.error)
                        .withValues(alpha: 0.8),
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
                          'Total do Mes',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        Text(
                          CurrencyFormatter.format(totalSpent),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (isPartiallyPaid || (totalPaid > 0 && !isPaid))
                          Text(
                            'Pago: ${CurrencyFormatter.format(totalPaid)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$paidItems/${_items.length}',
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
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return _FaturaItemTile(
                  item: item,
                  onTap: () {
                    final txId = item['transacao_id'];
                    if (txId != null) context.push('/transactions/$txId');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FaturaItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const _FaturaItemTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = item['title'] as String? ?? '';
    final installmentAmount =
        (item['installment_amount'] as num?)?.toDouble() ?? 0.0;
    final totalInstallments =
        (item['total_installments'] as num?)?.toInt() ?? 1;
    final displayInstallment =
        (item['display_installment'] as num?)?.toInt() ?? 1;
    final isRecurring = item['is_recurring'] == true;
    final status = item['status'] as String? ?? 'pending';
    final hasInstallments = totalInstallments > 1;
    final categoryIcon = item['category_icon'] as String?;
    final categoryColor = item['category_color'] as String?;
    final bankName = item['bank_name'] as String?;
    final iconColor = colorFromHex(categoryColor) ?? theme.colorScheme.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconFromName(categoryIcon),
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (hasInstallments)
                        _badge('$displayInstallment/$totalInstallments',
                            const Color(0xFF7C3AED)),
                      if (isRecurring)
                        _badge('Recorrente', const Color(0xFF3B82F6)),
                      _statusBadge(status, theme),
                      if (bankName != null)
                        Text(
                          bankName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
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

  Widget _badge(String label, Color color) {
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

  Widget _statusBadge(String status, ThemeData theme) {
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
    return _badge(label, color);
  }
}
