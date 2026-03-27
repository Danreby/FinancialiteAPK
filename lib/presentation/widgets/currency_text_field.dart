import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
