class Validators {
  Validators._();

  static String? required(String? value, [String field = 'Campo']) {
    if (value == null || value.trim().isEmpty) return '$field é obrigatório';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Deve conter letra maiúscula';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Deve conter letra minúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Deve conter número';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirmação é obrigatória';
    if (value != password) return 'As senhas não coincidem';
    return null;
  }

  static String? currency(String? value) {
    if (value == null || value.trim().isEmpty) return 'Valor é obrigatório';
    final cleaned = value.replaceAll('R\$', '').replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.');
    final number = double.tryParse(cleaned);
    if (number == null) return 'Valor inválido';
    if (number <= 0) return 'Valor deve ser maior que zero';
    if (number > 999999999) return 'Valor muito alto';
    return null;
  }

  static String? minLength(String? value, int min, [String field = 'Campo']) {
    if (value == null || value.length < min) return '$field deve ter no mínimo $min caracteres';
    return null;
  }

  static String? maxLength(String? value, int max, [String field = 'Campo']) {
    if (value != null && value.length > max) return '$field deve ter no máximo $max caracteres';
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Valor']) {
    if (value == null || value.trim().isEmpty) return '$field é obrigatório';
    final number = double.tryParse(value);
    if (number == null || number <= 0) return '$field deve ser positivo';
    return null;
  }

  static String? dayOfMonth(String? value) {
    if (value == null || value.trim().isEmpty) return 'Dia é obrigatório';
    final day = int.tryParse(value);
    if (day == null || day < 1 || day > 31) return 'Dia inválido (1-31)';
    return null;
  }
}
