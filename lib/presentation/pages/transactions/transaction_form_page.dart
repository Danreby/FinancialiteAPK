import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/category/category_cubit.dart';
import '../../blocs/card/card_cubit.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/currency_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/card_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../widgets/page_header.dart';
import '../../widgets/responsive_content.dart';
import '../../widgets/form_section_card.dart';
import 'widgets/transaction_type_selector.dart';
import '../../../core/theme/app_tokens.dart';

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
  int? _cardUserId;
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  final _installmentsController = TextEditingController(text: '1');
  bool _isLoadingTransaction = false;
  bool get _isEditing => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategories();
    context.read<CardCubit>().loadCards();
    if (_isEditing) {
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    setState(() => _isLoadingTransaction = true);
    try {
      final repo = sl<TransactionRepository>();
      final tx = await repo.getTransaction(widget.transactionId!);
      if (!mounted) return;
      setState(() {
        _type = tx.type;
        _descriptionController.text = tx.title;
        _amountController.text =
            tx.amount.toStringAsFixed(2).replaceAll('.', ',');
        _categoryId = tx.categoryId;
        _cardUserId = tx.cardUserId;
        _isRecurring = tx.isRecurring;
        _installmentsController.text = tx.installments.toString();
        if (tx.date != null) _date = tx.date!;
        _notesController.text = tx.description ?? '';
        _isLoadingTransaction = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingTransaction = false);
      debugPrint('[TransactionForm] Error loading transaction: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _installmentsController.dispose();
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
      'total_installments': _type == 'debit'
          ? 1
          : _isRecurring
              ? 1
              : int.tryParse(_installmentsController.text) ?? 1,
      'is_recurring': _type == 'debit' ? false : _isRecurring,
      'description': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      if (_cardUserId != null) 'bank_user_id': _cardUserId,
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
          PageHeader(
              title: _isEditing ? 'Editar Transação' : 'Nova Transação',
              showBackButton: true,
              bottomPadding: 24),
          Expanded(
            child: _isLoadingTransaction
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: ResponsiveContent(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TransactionTypeSelector(
                              type: _type,
                              onChanged: (t) => setState(() => _type = t),
                            ),
                            const SizedBox(height: 20),
                            FormSectionCard(
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
                                  Opacity(
                                    opacity: _type != 'debit' && !_isRecurring
                                        ? 1.0
                                        : 0.5,
                                    child: IgnorePointer(
                                      ignoring:
                                          _type == 'debit' || _isRecurring,
                                      child: AppTextField(
                                        controller: _installmentsController,
                                        label: 'Parcelas',
                                        prefixIcon: Icons.format_list_numbered,
                                        keyboardType: TextInputType.number,
                                        readOnly:
                                            _type == 'debit' || _isRecurring,
                                        validator: (v) {
                                          if (_type == 'debit' || _isRecurring)
                                            return null;
                                          final n = int.tryParse(v ?? '');
                                          if (n == null || n < 1)
                                            return 'Mínimo 1';
                                          if (n > 360) return 'Máximo 360';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Transação recorrente',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Switch(
                                        value: _isRecurring,
                                        onChanged: _type == 'debit'
                                            ? null
                                            : (v) {
                                                setState(() {
                                                  _isRecurring = v;
                                                  if (v)
                                                    _installmentsController
                                                        .text = '1';
                                                });
                                              },
                                      ),
                                    ],
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
                                  BlocBuilder<CardCubit, CardState>(
                                    builder: (context, state) {
                                      final cards = state is CardLoaded
                                          ? state.cards
                                          : <CardUser>[];
                                      return DropdownButtonFormField<int>(
                                        value: _cardUserId,
                                        decoration: const InputDecoration(
                                          labelText: 'Cartão (opcional)',
                                          prefixIcon: Icon(Icons.credit_card),
                                        ),
                                        items: [
                                          const DropdownMenuItem<int>(
                                            value: null,
                                            child: Text('Nenhum'),
                                          ),
                                          ...cards.map((c) => DropdownMenuItem(
                                                value: c.id,
                                                child: Text(c.cardName ??
                                                    'Cartão #${c.id}'),
                                              )),
                                        ],
                                        onChanged: (v) =>
                                            setState(() => _cardUserId = v),
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
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.lg),
                                      ),
                                      child: Icon(
                                        Icons.calendar_month,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
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
                                borderRadius:
                                    BorderRadius.circular(AppRadius.xxl),
                                boxShadow: AppShadows.buttonPrimary(
                                    theme.colorScheme.primary),
                              ),
                              child: SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _submit,
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.xxl),
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
          ),
        ],
      ),
    );
  }
}
