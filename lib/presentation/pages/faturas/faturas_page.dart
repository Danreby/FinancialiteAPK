import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/page_header.dart';
import 'widgets/fatura_summary_card.dart';
import 'widgets/fatura_item_tile.dart';

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
          FaturaSummaryCard(
            totalSpent: totalSpent,
            totalPaid: totalPaid,
            isPaid: isPaid,
            isPartiallyPaid: isPartiallyPaid,
            paidItems: paidItems,
            totalItems: _items.length,
          ),
          Expanded(
            child: ListView.builder(
              // LedgerRow already draws its own hairline divider -- a
              // separatorBuilder here would double it up.
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return FaturaItemTile(
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
