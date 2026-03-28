import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Keep only digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Treat digits as cents (last 2 digits are cents)
    final cents = int.parse(digitsOnly);
    final intPart = cents ~/ 100;
    final fracPart = cents % 100;

    // Format integer part with dots
    final intStr = intPart.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intStr.length; i++) {
      if (i > 0 && (intStr.length - i) % 3 == 0) buffer.write('.');
      buffer.write(intStr[i]);
    }

    final formatted =
        '${buffer.toString()},${fracPart.toString().padLeft(2, '0')}';
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CurrencyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? errorText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CurrencyTextField({
    super.key,
    this.controller,
    this.label,
    this.errorText,
    this.validator,
    this.onChanged,
  });

  /// Returns the double value from the formatted string (e.g. "1.234,56" → 1234.56)
  static double parseValue(String text) {
    final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label ?? 'Valor',
        errorText: errorText,
        prefixText: 'R\$ ',
        prefixIcon: const Icon(Icons.attach_money),
      ),
    );
  }
}
