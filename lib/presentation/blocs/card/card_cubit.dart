import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/card_entity.dart';
import '../../../domain/repositories/card_repository.dart';

part 'card_state.dart';

class CardCubit extends Cubit<CardState> {
  final CardRepository _repository;

  CardCubit(this._repository) : super(const CardInitial());

  Future<void> loadCards() async {
    emit(const CardLoading());
    try {
      final cards = await _repository.getCards();
      final available = await _repository.getAvailableCards().catchError((_) => <CardEntity>[]);
      emit(CardLoaded(cards: cards, availableCards: available));
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> loadInvoice(int cardId, {String? month}) async {
    try {
      final invoice = await _repository.getInvoice(cardId, month: month);
      if (state is CardLoaded) {
        final current = state as CardLoaded;
        emit(CardLoaded(
          cards: current.cards,
          currentInvoice: invoice,
          availableCards: current.availableCards,
        ));
      }
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> createCard(Map<String, dynamic> data) async {
    try {
      await _repository.createCard(data);
      loadCards();
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> updateCard(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateCard(id, data);
      loadCards();
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> deleteCard(int id) async {
    try {
      await _repository.deleteCard(id);
      if (state is CardLoaded) {
        final current = state as CardLoaded;
        emit(CardLoaded(
          cards: current.cards.where((c) => c.id != id).toList(),
          availableCards: current.availableCards,
        ));
      }
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }

  Future<void> payInvoice(int cardId, Map<String, dynamic> data) async {
    try {
      await _repository.payInvoice(cardId, data);
      loadCards();
    } catch (e) {
      emit(CardError(e.toString()));
    }
  }
}
