import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/budget.dart';
import '../../../domain/repositories/budget_repository.dart';

part 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository _repository;

  BudgetCubit(this._repository) : super(const BudgetInitial());

  Future<void> loadBudgets({String? month}) async {
    emit(const BudgetLoading());
    try {
      final budgets = await _repository.getBudgets();
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> createBudget(Map<String, dynamic> data) async {
    try {
      await _repository.createBudget(data);
      loadBudgets();
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> updateBudget(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateBudget(id, data);
      loadBudgets();
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _repository.deleteBudget(id);
      if (state is BudgetLoaded) {
        final current = state as BudgetLoaded;
        emit(BudgetLoaded(
          budgets: current.budgets.where((b) => b.id != id).toList(),
        ));
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
