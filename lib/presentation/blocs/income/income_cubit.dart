import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/income.dart';
import '../../../domain/repositories/income_repository.dart';
import '../../../core/utils/error_message.dart';

part 'income_state.dart';

class IncomeCubit extends Cubit<IncomeState> {
  final IncomeRepository _repository;

  IncomeCubit(this._repository) : super(const IncomeInitial());

  Future<void> loadIncomes({String? month}) async {
    emit(const IncomeLoading());
    try {
      final incomes = await _repository.getIncomes(filters: month != null ? {'month': month} : null);
      IncomeSummary? summary;
      try { summary = await _repository.getSummary(); } catch (_) {}
      emit(IncomeLoaded(incomes: incomes, summary: summary));
    } catch (e) {
      emit(IncomeError(extractErrorMessage(e)));
    }
  }

  Future<void> createIncome(Map<String, dynamic> data) async {
    try {
      await _repository.createIncome(data);
      loadIncomes();
    } catch (e) {
      emit(IncomeError(extractErrorMessage(e)));
    }
  }

  Future<void> updateIncome(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateIncome(id, data);
      loadIncomes();
    } catch (e) {
      emit(IncomeError(extractErrorMessage(e)));
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
      emit(IncomeError(extractErrorMessage(e)));
    }
  }

  Future<void> markAsReceived(int id) async {
    try {
      await _repository.toggleActive(id);
      loadIncomes();
    } catch (e) {
      emit(IncomeError(extractErrorMessage(e)));
    }
  }
}
