part of 'card_cubit.dart';

abstract class CardState extends Equatable {
  const CardState();
  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {
  const CardInitial();
}

class CardLoading extends CardState {
  const CardLoading();
}

class CardLoaded extends CardState {
  final List<CardUser> cards;
  final Map<String, dynamic>? currentInvoice;
  const CardLoaded({required this.cards, this.currentInvoice});
  @override
  List<Object?> get props => [cards, currentInvoice];
}

class CardError extends CardState {
  final String message;
  const CardError(this.message);
  @override
  List<Object?> get props => [message];
}
