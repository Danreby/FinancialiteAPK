part of 'bank_cubit.dart';

abstract class BankState extends Equatable {
  const BankState();
  @override
  List<Object?> get props => [];
}

class BankInitial extends BankState {
  const BankInitial();
}

class BankLoading extends BankState {
  const BankLoading();
}

class BankLoaded extends BankState {
  final List<BankAccount> accounts;
  final BankStats? stats;
  final List<Bank>? availableBanks;
  const BankLoaded({required this.accounts, this.stats, this.availableBanks});
  @override
  List<Object?> get props => [accounts, stats, availableBanks];
}

class BankError extends BankState {
  final String message;
  const BankError(this.message);
  @override
  List<Object?> get props => [message];
}
