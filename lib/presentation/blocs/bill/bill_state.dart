part of 'bill_cubit.dart';

abstract class BillState extends Equatable {
  const BillState();
  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {
  const BillInitial();
}

class BillLoading extends BillState {
  const BillLoading();
}

class BillLoaded extends BillState {
  final List<Bill> bills;
  const BillLoaded({required this.bills});
  @override
  List<Object?> get props => [bills];
}

class BillError extends BillState {
  final String message;
  const BillError(this.message);
  @override
  List<Object?> get props => [message];
}
