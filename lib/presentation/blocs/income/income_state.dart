part of 'income_cubit.dart';

abstract class IncomeState extends Equatable {
  const IncomeState();
  @override
  List<Object?> get props => [];
}

class IncomeInitial extends IncomeState {
  const IncomeInitial();
}

class IncomeLoading extends IncomeState {
  const IncomeLoading();
}

class IncomeLoaded extends IncomeState {
  final List<Income> incomes;
  final IncomeSummary? summary;
  const IncomeLoaded({required this.incomes, this.summary});
  @override
  List<Object?> get props => [incomes, summary];
}

class IncomeError extends IncomeState {
  final String message;
  const IncomeError(this.message);
  @override
  List<Object?> get props => [message];
}
