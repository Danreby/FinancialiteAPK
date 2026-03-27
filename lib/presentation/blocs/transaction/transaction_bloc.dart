import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;

  TransactionBloc(this._repository) : super(const TransactionInitial()) {
    on<TransactionsFetched>(_onFetched);
    on<TransactionCreated>(_onCreated);
    on<TransactionUpdated>(_onUpdated);
    on<TransactionDeleted>(_onDeleted);
    on<TransactionRefreshed>(_onRefreshed);
  }

  int _currentPage = 1;
  bool _hasMore = true;
  Map<String, dynamic> _filters = {};

  Future<void> _onFetched(TransactionsFetched event, Emitter<TransactionState> emit) async {
    if (event.reset) {
      _currentPage = 1;
      _hasMore = true;
      _filters = event.filters ?? {};
      emit(const TransactionLoading());
    } else if (!_hasMore) {
      return;
    }

    try {
      final transactions = await _repository.getTransactions(
        page: _currentPage,
        filters: _filters,
      );
      _hasMore = transactions.length >= 20;

      if (_currentPage == 1) {
        emit(TransactionLoaded(
          transactions: transactions,
          hasMore: _hasMore,
        ));
      } else {
        final current = state as TransactionLoaded;
        emit(TransactionLoaded(
          transactions: [...current.transactions, ...transactions],
          hasMore: _hasMore,
        ));
      }
      _currentPage++;
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onCreated(TransactionCreated event, Emitter<TransactionState> emit) async {
    try {
      await _repository.createTransaction(event.data);
      add(TransactionsFetched(reset: true, filters: _filters));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdated(TransactionUpdated event, Emitter<TransactionState> emit) async {
    try {
      await _repository.updateTransaction(event.id, event.data);
      add(TransactionsFetched(reset: true, filters: _filters));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleted(TransactionDeleted event, Emitter<TransactionState> emit) async {
    try {
      await _repository.deleteTransaction(event.id);
      if (state is TransactionLoaded) {
        final current = state as TransactionLoaded;
        emit(TransactionLoaded(
          transactions: current.transactions.where((t) => t.id != event.id).toList(),
          hasMore: current.hasMore,
        ));
      }
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onRefreshed(TransactionRefreshed event, Emitter<TransactionState> emit) async {
    add(TransactionsFetched(reset: true, filters: _filters));
  }
}
