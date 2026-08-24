import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../widgets/form_section_card.dart';
import '../../../widgets/pressable_scale.dart';

/// Débito/Crédito type toggle -- wrapped in the same labeled-section shell
/// as the income form's "Tipo de renda" picker (`income_form_page.dart`)
/// so both forms present their type selector identically.
class TransactionTypeSelector extends StatelessWidget {
  final String type;
  final ValueChanged<String> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.type,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de transação',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TypeButton(
                  selected: type == 'debit',
                  color: theme.appColors.expense,
                  icon: Icons.arrow_downward_rounded,
                  label: 'Débito',
                  onTap: () => onChanged('debit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeButton(
                  selected: type == 'credit',
                  color: theme.appColors.income,
                  icon: Icons.arrow_upward_rounded,
                  label: 'Crédito',
                  onTap: () => onChanged('credit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final bool selected;
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TypeButton({
    required this.selected,
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Selected state is a soft tint + colored border, never a solid fill
    // with a glow -- a colored ambient shadow is reserved for the single
    // primary brand button per screen (AppShadows' own documented rule),
    // not for a semantic status color like income/expense.
    final fg = selected ? color : theme.colorScheme.onSurfaceVariant;
    return PressableScale(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 64,
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: AppRadius.cardCut(open: 16, tight: 4),
            border: selected
                ? Border.all(color: color, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
