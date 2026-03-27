import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/dashboard.dart';
import '../../../domain/repositories/dashboard_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  DashboardCubit(this._repository) : super(const DashboardInitial());

  Future<void> load({String? month}) async {
    emit(const DashboardLoading());
    try {
      final data = await _repository.getDashboardData(filters: month != null ? {'month': month} : null);
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> refresh({String? month}) async {
    try {
      final data = await _repository.getDashboardData(filters: month != null ? {'month': month} : null);
      emit(DashboardLoaded(data));
    } catch (e) {
      if (state is! DashboardLoaded) {
        emit(DashboardError(e.toString()));
      }
    }
  }
}
