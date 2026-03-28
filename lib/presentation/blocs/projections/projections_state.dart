part of 'projections_cubit.dart';

abstract class ProjectionsState extends Equatable {
  const ProjectionsState();
  @override
  List<Object?> get props => [];
}

class ProjectionsInitial extends ProjectionsState {
  const ProjectionsInitial();
}

class ProjectionsLoading extends ProjectionsState {
  const ProjectionsLoading();
}

class ProjectionsLoaded extends ProjectionsState {
  final double currentMonthDebit;
  final double monthlyRecurringIncome;
  final List<Map<String, dynamic>> projectedMonths;
  final List<Map<String, dynamic>> transactions;

  const ProjectionsLoaded({
    required this.currentMonthDebit,
    required this.monthlyRecurringIncome,
    required this.projectedMonths,
    required this.transactions,
  });

  @override
  List<Object?> get props => [
        currentMonthDebit,
        monthlyRecurringIncome,
        projectedMonths,
        transactions,
      ];
}

class ProjectionsError extends ProjectionsState {
  final String message;
  const ProjectionsError(this.message);
  @override
  List<Object?> get props => [message];
}
