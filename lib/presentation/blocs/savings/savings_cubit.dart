import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/savings_goal.dart';
import '../../../domain/repositories/savings_repository.dart';

part 'savings_state.dart';

class SavingsCubit extends Cubit<SavingsState> {
  final SavingsRepository _repository;

  SavingsCubit(this._repository) : super(const SavingsInitial());

  Future<void> loadGoals() async {
    emit(const SavingsLoading());
    try {
      final goals = await _repository.getGoals();
      SavingsSummary? summary;
      try { summary = await _repository.getSummary(); } catch (_) {}
      emit(SavingsLoaded(goals: goals, summary: summary));
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> createGoal(Map<String, dynamic> data) async {
    try {
      await _repository.createGoal(data);
      loadGoals();
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> updateGoal(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateGoal(id, data);
      loadGoals();
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _repository.deleteGoal(id);
      if (state is SavingsLoaded) {
        final current = state as SavingsLoaded;
        emit(SavingsLoaded(
          goals: current.goals.where((g) => g.id != id).toList(),
          summary: current.summary,
        ));
      }
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> addDeposit(int id, Map<String, dynamic> data) async {
    try {
      await _repository.deposit(id, (data['amount'] as num).toDouble());
      loadGoals();
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> withdraw(int id, Map<String, dynamic> data) async {
    try {
      await _repository.withdraw(id, (data['amount'] as num).toDouble());
      loadGoals();
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }
}
