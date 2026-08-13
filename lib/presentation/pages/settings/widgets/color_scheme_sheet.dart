import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/theme/theme_cubit.dart';
import '../../../../core/theme/app_tokens.dart';

void showColorSchemeSheet(BuildContext context, String current) {
  final theme = Theme.of(context);
  final schemes = [
    ('rose', 'Rosé', const Color(0xFFE11D48)),
    ('forest', 'Floresta', const Color(0xFF059669)),
    ('black', 'Preto', const Color(0xFF1F2937)),
    ('gold', 'Ouro', const Color(0xFFD97706)),
    ('lavender', 'Lavanda', const Color(0xFF7C3AED)),
    ('midnight', 'Meia-noite', const Color(0xFF1E40AF)),
  ];
  showModalBottomSheet(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tema de cores',
            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          ...schemes.map((entry) {
            final (key, label, color) = entry;
            final isSelected = key == current;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Material(
                color: isSelected
                    ? color.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () {
                    context.read<ThemeCubit>().setColorScheme(key);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.fromBorderSide(
                        AppBorders.hairline(
                          isSelected
                              ? color.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              AppBorders.hairline(
                                isSelected
                                    ? color
                                    : theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            label,
                            style:
                                Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                        Radio<String>(
                          value: key,
                          groupValue: current,
                          onChanged: (v) {
                            context.read<ThemeCubit>().setColorScheme(v!);
                            Navigator.pop(ctx);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );
}

String themeLabel(String name) {
  const labels = {
    'rose': 'Rosé',
    'forest': 'Floresta',
    'black': 'Preto',
    'gold': 'Ouro',
    'lavender': 'Lavanda',
    'midnight': 'Meia-noite',
  };
  return labels[name] ?? name;
}
