import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  static const _months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildArrowButton(
            context,
            icon: Icons.chevron_left_rounded,
            onPressed: () => onChanged(DateTime(selectedMonth.year, selectedMonth.month - 1)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showPicker(context),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  '${_months[selectedMonth.month - 1]} ${selectedMonth.year}',
                  key: ValueKey('${selectedMonth.month}_${selectedMonth.year}'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
          _buildArrowButton(
            context,
            icon: Icons.chevron_right_rounded,
            onPressed: () => onChanged(DateTime(selectedMonth.year, selectedMonth.month + 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 22, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      onChanged(DateTime(picked.year, picked.month));
    }
  }
}
