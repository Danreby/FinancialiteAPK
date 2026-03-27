import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/bill.dart';
import '../../../domain/repositories/bill_repository.dart';

part 'bill_state.dart';

class BillCubit extends Cubit<BillState> {
  final BillRepository _repository;

  BillCubit(this._repository) : super(const BillInitial());

  Future<void> loadBills({String? month, String? status}) async {
    emit(const BillLoading());
    try {
      final filters = <String, dynamic>{};
      if (month != null) filters['month'] = month;
      if (status != null) filters['status'] = status;
      final bills = await _repository.getBills(filters: filters.isNotEmpty ? filters : null);
      emit(BillLoaded(bills: bills));
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  Future<void> createBill(Map<String, dynamic> data) async {
    try {
      await _repository.createBill(data);
      loadBills();
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  Future<void> updateBill(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateBill(id, data);
      loadBills();
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  Future<void> deleteBill(int id) async {
    try {
      await _repository.deleteBill(id);
      if (state is BillLoaded) {
        final current = state as BillLoaded;
        emit(BillLoaded(
          bills: current.bills.where((b) => b.id != id).toList(),
        ));
      }
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }

  Future<void> payBill(int id, Map<String, dynamic> data) async {
    try {
      await _repository.markAsPaid(id);
      loadBills();
    } catch (e) {
      emit(BillError(e.toString()));
    }
  }
}
