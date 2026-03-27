part of 'savings_cubit.dart';

abstract class SavingsState extends Equatable {
  const SavingsState();
  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {
  const SavingsInitial();
}

class SavingsLoading extends SavingsState {
  const SavingsLoading();
}

class SavingsLoaded extends SavingsState {
  final List<SavingsGoal> goals;
  final SavingsSummary? summary;
  const SavingsLoaded({required this.goals, this.summary});
  @override
  List<Object?> get props => [goals, summary];
}

class SavingsError extends SavingsState {
  final String message;
  const SavingsError(this.message);
  @override
  List<Object?> get props => [message];
}
