import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/category/category_cubit.dart';
import '../../../../domain/entities/category.dart';
import '../../../widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../../core/theme/app_tokens.dart';

void showCategoryDialog(BuildContext context, {Category? editing}) {
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
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
                      borderRadius: BorderRadius.circular(AppRadius.xs),
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
                    DropdownMenuItem(value: 'expense', child: Text('Despesa')),
                    DropdownMenuItem(value: 'income', child: Text('Receita')),
                  ],
                  onChanged: (v) => setLocalState(() => type = v ?? 'expense'),
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
                                ? colorFromHex(selectedColor)
                                    .withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: sel
                                ? Border.all(
                                    color: colorFromHex(selectedColor),
                                    width: 2)
                                : null,
                          ),
                          child: Icon(iconFromName(ic),
                              size: 22,
                              color: sel
                                  ? colorFromHex(selectedColor)
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
                            color: colorFromHex(col),
                            shape: BoxShape.circle,
                            border: sel
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                            boxShadow: sel ? AppShadows.sm : null,
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
                        context
                            .read<CategoryCubit>()
                            .updateCategory(editing.id!, data);
                      } else {
                        context.read<CategoryCubit>().createCategory(data);
                      }
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.xxl)),
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
