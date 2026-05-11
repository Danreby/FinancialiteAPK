import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/bank/bank_cubit.dart';
import '../../widgets/currency_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/bank_account.dart';
import '../../widgets/page_header.dart';

class BankTransferPage extends StatefulWidget {
  const BankTransferPage({super.key});

  @override
  State<BankTransferPage> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  int? _fromAccountId;
  int? _toAccountId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione as contas de origem e destino')),
      );
      return;
    }
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('As contas de origem e destino devem ser diferentes')),
      );
      return;
    }
    context.read<BankCubit>().transfer({
      'conta_origem_id': _fromAccountId,
      'conta_destino_id': _toAccountId,
      'valor': double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0,
    });
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocBuilder<BankCubit, BankState>(
        builder: (context, state) {
          final accounts =
              state is BankLoaded ? state.accounts : <BankAccount>[];
          return Column(
            children: [
              const PageHeader(
                  title: 'Transferência',
                  showBackButton: true,
                  bottomPadding: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.output,
                                    color: theme.colorScheme.error, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _fromAccountId,
                                  decoration: const InputDecoration(
                                    labelText: 'Conta de origem',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  items: accounts
                                      .map((a) => DropdownMenuItem(
                                            value: a.id,
                                            child: Text(a.displayName),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _fromAccountId = v),
                                  validator: (v) => v == null
                                      ? 'Selecione a conta de origem'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_downward,
                                color: theme.colorScheme.primary, size: 22),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.input,
                                    color: Colors.green, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _toAccountId,
                                  decoration: const InputDecoration(
                                    labelText: 'Conta de destino',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  items: accounts
                                      .map((a) => DropdownMenuItem(
                                            value: a.id,
                                            child: Text(a.displayName),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _toAccountId = v),
                                  validator: (v) => v == null
                                      ? 'Selecione a conta de destino'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.attach_money,
                                    color: theme.colorScheme.primary, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: CurrencyTextField(
                                  controller: _amountCtrl,
                                  label: 'Valor da transferência',
                                  validator: Validators.currency,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 56,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _submit,
                            child: Text(
                              'Transferir',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
