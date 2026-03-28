import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/category/category_cubit.dart';
import '../../../domain/entities/category.dart';
import '../../widgets/app_loading_indicator.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';

IconData _iconFromName(String? name) {
  const map = <String, IconData>{
    'shopping_cart': Icons.shopping_cart,
    'restaurant': Icons.restaurant,
    'home': Icons.home,
    'directions_car': Icons.directions_car,
    'local_gas_station': Icons.local_gas_station,
    'credit_card': Icons.credit_card,
    'health_and_safety': Icons.health_and_safety,
    'sports_esports': Icons.sports_esports,
    'school': Icons.school,
    'commute': Icons.commute,
    'lightbulb': Icons.lightbulb,
    'phone': Icons.phone,
    'smartphone': Icons.smartphone,
    'wifi': Icons.wifi,
    'local_hospital': Icons.local_hospital,
    'fitness_center': Icons.fitness_center,
    'movie': Icons.movie,
    'work': Icons.work,
    'business': Icons.business,
    'travel_explore': Icons.travel_explore,
    'savings': Icons.savings,
    'money': Icons.money,
    'account_balance': Icons.account_balance,
    'fastfood': Icons.fastfood,
    'coffee': Icons.coffee,
    'flight': Icons.flight,
    'hotel': Icons.hotel,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'subscriptions': Icons.subscriptions,
    'music_note': Icons.music_note,
    'book': Icons.book,
    'sports': Icons.sports,
    'local_pharmacy': Icons.local_pharmacy,
    'local_laundry_service': Icons.local_laundry_service,
    'cleaning_services': Icons.cleaning_services,
    'construction': Icons.construction,
    'attach_money': Icons.attach_money,
  };
  return map[name] ?? Icons.category;
}

Color _colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return Colors.grey;
  try {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  } catch (_) {
    return Colors.grey;
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
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

  void _showCategoryDialog({Category? editing}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    String type = editing?.type ?? 'expense';
    String selectedIcon = editing?.icon ?? 'category';
    String selectedColor = editing?.color ?? '#6B7280';
    final formKey = GlobalKey<FormState>();

    final iconOptions = <String>[
      'shopping_cart',
      'restaurant',
      'home',
      'directions_car',
      'local_gas_station',
      'credit_card',
      'health_and_safety',
      'sports_esports',
      'school',
      'commute',
      'lightbulb',
      'smartphone',
      'fitness_center',
      'movie',
      'work',
      'travel_explore',
      'savings',
      'account_balance',
      'fastfood',
      'coffee',
      'flight',
      'hotel',
      'pets',
      'subscriptions',
      'music_note',
      'book',
      'local_pharmacy',
      'cleaning_services',
      'attach_money',
    ];
    final colorOptions = <String>[
      '#E11D48',
      '#059669',
      '#3B82F6',
      '#F59E0B',
      '#7C3AED',
      '#1E40AF',
      '#EC4899',
      '#14B8A6',
      '#F97316',
      '#10B981',
      '#6B7280',
      '#EF4444',
      '#8B5CF6',
      '#06B6D4',
      '#84CC16',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
          child: StatefulBuilder(
            builder: (context, setLocalState) => SingleChildScrollView(
              child: Column(
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
                    editing != null ? 'Editar Categoria' : 'Nova Categoria',
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
                    maxLength: 50,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'expense', child: Text('Despesa')),
                      DropdownMenuItem(value: 'income', child: Text('Receita')),
                    ],
                    onChanged: (v) =>
                        setLocalState(() => type = v ?? 'expense'),
                  ),
                  const SizedBox(height: 16),
                  Text('Ícone',
                      style: Theme.of(ctx)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 56,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: iconOptions.length,
                      itemBuilder: (_, i) {
                        final ic = iconOptions[i];
                        final sel = ic == selectedIcon;
                        return GestureDetector(
                          onTap: () => setLocalState(() => selectedIcon = ic),
                          child: Container(
                            width: 48,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? _colorFromHex(selectedColor)
                                      .withValues(alpha: 0.15)
                                  : Colors.grey.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: sel
                                  ? Border.all(
                                      color: _colorFromHex(selectedColor),
                                      width: 2)
                                  : null,
                            ),
                            child: Icon(_iconFromName(ic),
                                size: 22,
                                color: sel
                                    ? _colorFromHex(selectedColor)
                                    : Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Cor',
                      style: Theme.of(ctx)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: colorOptions.length,
                      itemBuilder: (_, i) {
                        final col = colorOptions[i];
                        final sel = col == selectedColor;
                        return GestureDetector(
                          onTap: () => setLocalState(() => selectedColor = col),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _colorFromHex(col),
                              shape: BoxShape.circle,
                              border: sel
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                          color: _colorFromHex(col)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 8)
                                    ]
                                  : null,
                            ),
                            child: sel
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final data = {
                          'name': nameCtrl.text.trim(),
                          'type': type,
                          'icon': selectedIcon,
                          'color': selectedColor,
                        };
                        if (editing != null) {
                          context.read<CategoryCubit>().updateCategory(editing.id!, data);
                        } else {
                          context.read<CategoryCubit>().createCategory(data);
                        }
                        Navigator.pop(ctx);
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Salvar',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog() => _showCategoryDialog();

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
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
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
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
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
                  return const AppLoadingIndicator(
                      useShimmer: true, shimmerLines: 5);
                }
                if (state is CategoryError) {
                  return AppErrorWidget(
                      message: state.message, onRetry: _loadData);
                }
                if (state is CategoryLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCategoryList(state.categories, theme),
                      _buildCategoryList(
                        state.categories
                            .where((c) => c.type == 'expense')
                            .toList(),
                        theme,
                      ),
                      _buildCategoryList(
                        state.categories
                            .where((c) => c.type == 'income')
                            .toList(),
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
                              _colorFromHex(cat.color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _iconFromName(cat.icon),
                          color: _colorFromHex(cat.color),
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
                        icon: Icon(Icons.edit_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: () => _showCategoryDialog(editing: cat as Category),
                        constraints: const BoxConstraints(maxWidth: 36, maxHeight: 36),
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

  String _typeLabel(String type) {
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
