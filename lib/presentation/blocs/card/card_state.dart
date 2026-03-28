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
  final List<CardEntity> availableCards;
  const CardLoaded({
    required this.cards,
    this.currentInvoice,
    this.availableCards = const [],
  });
  @override
  List<Object?> get props => [cards, currentInvoice, availableCards];
}

class CardError extends CardState {
  final String message;
  const CardError(this.message);
  @override
  List<Object?> get props => [message];
}
