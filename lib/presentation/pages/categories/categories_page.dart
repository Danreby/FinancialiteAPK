import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/category/category_cubit.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() => context.read<CategoryCubit>().loadCategories();

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    String type = 'despesa';
    String? icon;
    String? color;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setLocalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Nova Categoria',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: nameCtrl,
                  label: 'Nome',
                  prefixIcon: Icons.label,
                  validator: Validators.required,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'despesa', child: Text('Despesa')),
                    DropdownMenuItem(value: 'receita', child: Text('Receita')),
                    DropdownMenuItem(value: 'ambos', child: Text('Ambos')),
                  ],
                  onChanged: (v) => setLocalState(() => type = v ?? 'despesa'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      context.read<CategoryCubit>().createCategory({
                        'nome': nameCtrl.text.trim(),
                        'tipo': type,
                        if (icon != null) 'icone': icon,
                        if (color != null) 'cor': color,
                      });
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showCreateDialog,
          child: const Icon(Icons.add),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categorias',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(3, (index) {
                final labels = ['Todas', 'Despesas', 'Receitas'];
                final isSelected = _tabController.index == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _tabController.animateTo(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const AppLoadingIndicator(useShimmer: true, shimmerLines: 5);
                }
                if (state is CategoryError) {
                  return AppErrorWidget(message: state.message, onRetry: _loadData);
                }
                if (state is CategoryLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCategoryList(state.categories, theme),
                      _buildCategoryList(
                        state.categories.where((c) => c.type == 'despesa' || c.type == 'ambos').toList(),
                        theme,
                      ),
                      _buildCategoryList(
                        state.categories.where((c) => c.type == 'receita' || c.type == 'ambos').toList(),
                        theme,
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

  Widget _buildCategoryList(List categories, ThemeData theme) {
    if (categories.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.category,
        title: 'Nenhuma categoria',
        subtitle: 'Crie categorias para organizar suas finanças',
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
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
                onDismissed: (_) => context.read<CategoryCubit>().deleteCategory(cat.id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          cat.icon != null
                              ? IconData(int.tryParse(cat.icon!) ?? 0xe14f, fontFamily: 'MaterialIcons')
                              : Icons.category,
                          color: theme.colorScheme.primary,
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
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
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

  String _typeLabel(String type) {
    switch (type) {
      case 'despesa':
        return 'Despesa';
      case 'receita':
        return 'Receita';
      case 'ambos':
        return 'Ambos';
      default:
        return type;
    }
  }
}
