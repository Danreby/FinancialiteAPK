import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/category/category_cubit.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/category.dart';

class TransactionFormPage extends StatefulWidget {
  final int? transactionId;
  const TransactionFormPage({super.key, this.transactionId});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'debit';
  int? _categoryId;
  DateTime _date = DateTime.now();
  bool get _isEditing => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategories();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _descriptionController.text.trim(),
      'amount': CurrencyTextField.parseValue(_amountController.text),
      'type': _type,
      'category_id': _categoryId,
      'date': _date.toIso8601String().substring(0, 10),
      'description': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    };
    if (_isEditing) {
      context
          .read<TransactionBloc>()
          .add(TransactionUpdated(widget.transactionId!, data));
    } else {
      context.read<TransactionBloc>().add(TransactionCreated(data));
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _isEditing ? 'Editar Transação' : 'Nova Transação',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = 'debit'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 56,
                              decoration: BoxDecoration(
                                color: _type == 'debit'
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    color: _type == 'debit'
                                        ? Colors.white
                                        : theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Despesa',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _type == 'debit'
                                          ? Colors.white
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = 'credit'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 56,
                              decoration: BoxDecoration(
                                color: _type == 'credit'
                                    ? const Color(0xFF10B981)
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: _type == 'credit'
                                        ? Colors.white
                                        : theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Receita',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _type == 'credit'
                                          ? Colors.white
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _descriptionController,
                            label: 'Título',
                            prefixIcon: Icons.description,
                            validator: Validators.required,
                            textInputAction: TextInputAction.next,
                            maxLength: 100,
                          ),
                          const SizedBox(height: 16),
                          CurrencyTextField(
                            controller: _amountController,
                            label: 'Valor',
                            validator: Validators.currency,
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<CategoryCubit, CategoryState>(
                            builder: (context, state) {
                              final categories = state is CategoryLoaded
                                  ? state.categories
                                  : <Category>[];
                              return DropdownButtonFormField<int>(
                                value: _categoryId,
                                decoration: const InputDecoration(
                                  labelText: 'Categoria',
                                  prefixIcon: Icon(Icons.category),
                                ),
                                items: categories
                                    .map((c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _categoryId = v),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Data',
                            prefixIcon: Icons.calendar_today,
                            readOnly: true,
                            controller: TextEditingController(
                              text:
                                  '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                            ),
                            suffix: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_month,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null)
                                setState(() => _date = picked);
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _notesController,
                            label: 'Observações',
                            prefixIcon: Icons.notes,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _isEditing ? 'Atualizar' : 'Salvar',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
