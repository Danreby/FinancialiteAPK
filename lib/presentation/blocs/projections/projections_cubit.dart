import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/projections_repository.dart';
import '../../../core/utils/error_message.dart';

part 'projections_state.dart';

class ProjectionsCubit extends Cubit<ProjectionsState> {
  final ProjectionsRepository _repository;

  ProjectionsCubit(this._repository) : super(const ProjectionsInitial());

  Future<void> load() async {
    emit(const ProjectionsLoading());
    try {
      final data = await _repository.getProjections();
      emit(ProjectionsLoaded(
        currentMonthDebit:
            (data['current_month_debit'] as num?)?.toDouble() ?? 0,
        monthlyRecurringIncome:
            (data['monthly_recurring_income'] as num?)?.toDouble() ?? 0,
        projectedMonths:
            List<Map<String, dynamic>>.from(data['projected_months'] ?? []),
        transactions:
            List<Map<String, dynamic>>.from(data['transactions'] ?? []),
      ));
    } catch (e) {
      emit(ProjectionsError(extractErrorMessage(e)));
    }
  }
}
