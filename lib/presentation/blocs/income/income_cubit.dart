import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/income.dart';
import '../../../domain/repositories/income_repository.dart';

part 'income_state.dart';

class IncomeCubit extends Cubit<IncomeState> {
  final IncomeRepository _repository;

  IncomeCubit(this._repository) : super(const IncomeInitial());

  Future<void> loadIncomes({String? month}) async {
    emit(const IncomeLoading());
    try {
      final result = await _repository.getIncomes(month: month);
      final incomes = result['data'] as List<Income>;
      final summary = result['summary'] as IncomeSummary?;
      emit(IncomeLoaded(incomes: incomes, summary: summary));
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> createIncome(Map<String, dynamic> data) async {
    try {
      await _repository.createIncome(data);
      loadIncomes();
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> updateIncome(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateIncome(id, data);
      loadIncomes();
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await _repository.deleteIncome(id);
      if (state is IncomeLoaded) {
        final current = state as IncomeLoaded;
        emit(IncomeLoaded(
          incomes: current.incomes.where((i) => i.id != id).toList(),
          summary: current.summary,
        ));
      }
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> markAsReceived(int id) async {
    try {
      await _repository.markAsReceived(id);
      loadIncomes();
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }
}
