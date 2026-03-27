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
  String _type = 'despesa';
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
      'descricao': _descriptionController.text.trim(),
      'valor': double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0,
      'tipo': _type,
      'categoria_id': _categoryId,
      'data': _date.toIso8601String().substring(0, 10),
      'observacoes': _notesController.text.trim(),
    };
    if (_isEditing) {
      context.read<TransactionBloc>().add(TransactionUpdated(widget.transactionId!, data));
    } else {
      context.read<TransactionBloc>().add(TransactionCreated(data));
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Transação' : 'Nova Transação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'despesa', label: Text('Despesa'), icon: Icon(Icons.arrow_downward)),
                  ButtonSegment(value: 'receita', label: Text('Receita'), icon: Icon(Icons.arrow_upward)),
                ],
                selected: {_type},
                onSelectionChanged: (v) => setState(() => _type = v.first),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Descrição',
                prefixIcon: Icons.description,
                validator: Validators.required,
                textInputAction: TextInputAction.next,
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
                  final categories = state is CategoryLoaded ? state.categories : <Category>[];
                  return DropdownButtonFormField<int>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: categories.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )).toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                  );
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Data',
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                controller: TextEditingController(
                  text: '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _notesController,
                label: 'Observações',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Text(_isEditing ? 'Atualizar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
