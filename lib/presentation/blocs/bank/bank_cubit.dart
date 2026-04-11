import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/bank_account.dart';
import '../../../domain/repositories/bank_repository.dart';
import '../../../core/utils/error_message.dart';

part 'bank_state.dart';

class BankCubit extends Cubit<BankState> {
  final BankRepository _repository;

  BankCubit(this._repository) : super(const BankInitial());

  Future<void> loadAccounts() async {
    emit(const BankLoading());
    try {
      final accounts = await _repository.getAccounts();
      BankStats? stats;
      try {
        stats = await _repository.getStats();
      } catch (_) {}
      emit(BankLoaded(accounts: accounts, stats: stats));
    } catch (e) {
      emit(BankError(extractErrorMessage(e)));
    }
  }

  Future<void> loadBanks() async {
    try {
      final banks = await _repository.getAvailableBanks();
      if (state is BankLoaded) {
        final current = state as BankLoaded;
        emit(BankLoaded(
          accounts: current.accounts,
          stats: current.stats,
          availableBanks: banks,
        ));
      }
    } catch (_) {}
  }

  Future<void> createAccount(Map<String, dynamic> data) async {
    try {
      await _repository.createAccount(data);
      loadAccounts();
    } catch (e) {
      emit(BankError(extractErrorMessage(e)));
    }
  }

  Future<void> updateAccount(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateAccount(id, data);
      loadAccounts();
    } catch (e) {
      emit(BankError(extractErrorMessage(e)));
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _repository.deleteAccount(id);
      if (state is BankLoaded) {
        final current = state as BankLoaded;
        emit(BankLoaded(
          accounts: current.accounts.where((a) => a.id != id).toList(),
          stats: current.stats,
          availableBanks: current.availableBanks,
        ));
      }
    } catch (e) {
      emit(BankError(extractErrorMessage(e)));
    }
  }

  Future<void> transfer(Map<String, dynamic> data) async {
    try {
      await _repository.createTransfer(data);
      loadAccounts();
    } catch (e) {
      emit(BankError(extractErrorMessage(e)));
    }
  }
}
