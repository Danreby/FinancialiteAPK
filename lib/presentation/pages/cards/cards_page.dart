import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/card/card_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/section_header.dart';
import '../../widgets/page_header.dart';
import '../../widgets/shadowed_fab.dart';
import 'widgets/card_list_item.dart';
import 'widgets/card_dialogs.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  static const _cardGradients = [
    [Color(0xFF1A1A2E), Color(0xFF16213E)],
    [Color(0xFF0F3460), Color(0xFF533483)],
    [Color(0xFF2C3E50), Color(0xFF3498DB)],
    [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    [Color(0xFF1B5E20), Color(0xFF388E3C)],
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() => context.read<CardCubit>().loadCards();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton:
          ShadowedFab(onPressed: () => showCardCreateDialog(context)),
      body: BlocBuilder<CardCubit, CardState>(
        builder: (context, state) {
          return Column(
            children: [
              const PageHeader(title: 'Cartões', bottomPadding: 16),
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
        return EmptyStateWidget(
          icon: Icons.credit_card,
          title: 'Nenhum cartão',
          subtitle: 'Adicione seu primeiro cartão',
          actionLabel: 'Novo cartão',
          onAction: () => showCardCreateDialog(context),
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
            final gradient = _cardGradients[cardIndex % _cardGradients.length];

            return CardListItem(
              card: card,
              gradient: gradient,
              onEdit: () => showCardEditDialog(context, card),
              onConfirmDismiss: () => ConfirmDialog.show(
                context,
                title: 'Excluir cartão',
                message: 'Deseja excluir "${card.displayName}"?',
                confirmText: 'Excluir',
                confirmColor: theme.colorScheme.error,
              ),
              onDismissed: () => context.read<CardCubit>().deleteCard(card.id!),
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
