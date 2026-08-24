import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/category/category_cubit.dart';
import '../../../../domain/entities/category.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../../core/utils/category_icons.dart';
import '../../../widgets/ledger_row.dart';
import '../../../../core/theme/app_theme.dart';
import 'category_form_dialog.dart';

class CategoryList extends StatelessWidget {
  final List<dynamic> categories;

  const CategoryList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;
    if (categories.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.category,
        title: 'Nenhuma categoria',
        subtitle: 'Crie categorias para organizar suas finanças',
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<CategoryCubit>().loadCategories(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Dismissible(
            key: Key('cat_${cat.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 4),
              color: theme.colorScheme.error,
              child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
            ),
            confirmDismiss: (_) => ConfirmDialog.show(
              context,
              title: 'Excluir categoria',
              message: 'Deseja excluir "${cat.name}"?',
              confirmText: 'Excluir',
              confirmColor: theme.colorScheme.error,
            ),
            onDismissed: (_) =>
                context.read<CategoryCubit>().deleteCategory(cat.id),
            child: LedgerRow(
              title: cat.name,
              subtitle: _typeLabel(cat.type),
              leadingIcon:
                  iconDataForCategoryIcon(cat.icon) ?? iconFromName(cat.icon),
              leadingIconColor: colorFromHex(cat.color),
              trailing: IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 18, color: appColors.onSurfaceVariant),
                onPressed: () =>
                    showCategoryDialog(context, editing: cat as Category),
                constraints:
                    const BoxConstraints(maxWidth: 36, maxHeight: 36),
                padding: EdgeInsets.zero,
              ),
            ),
          );
        },
      ),
    );
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'expense':
        return 'Despesa';
      case 'income':
        return 'Receita';
      default:
        return type;
    }
  }
}
