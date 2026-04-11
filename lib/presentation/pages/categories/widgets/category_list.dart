import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/category/category_cubit.dart';
import '../../../../domain/entities/category.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../../core/utils/icon_utils.dart';
import 'category_form_dialog.dart';

class CategoryList extends StatelessWidget {
  final List<dynamic> categories;

  const CategoryList({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        padding: const EdgeInsets.only(top: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Dismissible(
                key: Key('cat_${cat.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: theme.colorScheme.error,
                  child: const Icon(Icons.delete, color: Colors.white),
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
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color:
                              colorFromHex(cat.color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          iconFromName(cat.icon),
                          color: colorFromHex(cat.color),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _typeLabel(cat.type),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant),
                        onPressed: () => showCategoryDialog(context,
                            editing: cat as Category),
                        constraints:
                            const BoxConstraints(maxWidth: 36, maxHeight: 36),
                        padding: EdgeInsets.zero,
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
