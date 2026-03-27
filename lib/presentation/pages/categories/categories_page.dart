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
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setLocalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nova Categoria', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                FilledButton(
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
        title: const Text('Categorias'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Despesas'),
            Tab(text: 'Receitas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) return const AppLoadingIndicator();
          if (state is CategoryError) return AppErrorWidget(message: state.message, onRetry: _loadData);
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
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Dismissible(
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
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  cat.icon != null ? IconData(int.tryParse(cat.icon!) ?? 0xe14f, fontFamily: 'MaterialIcons') : Icons.category,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(cat.name),
              subtitle: Text(_typeLabel(cat.type)),
              trailing: const Icon(Icons.chevron_right, size: 20),
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
