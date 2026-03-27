part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class TransactionsFetched extends TransactionEvent {
  final bool reset;
  final Map<String, dynamic>? filters;
  const TransactionsFetched({this.reset = false, this.filters});
  @override
  List<Object?> get props => [reset, filters];
}

class TransactionCreated extends TransactionEvent {
  final Map<String, dynamic> data;
  const TransactionCreated(this.data);
  @override
  List<Object?> get props => [data];
}

class TransactionUpdated extends TransactionEvent {
  final int id;
  final Map<String, dynamic> data;
  const TransactionUpdated(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class TransactionDeleted extends TransactionEvent {
  final int id;
  const TransactionDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class TransactionRefreshed extends TransactionEvent {
  const TransactionRefreshed();
}
