import '../entities/card_entity.dart';

abstract class CardRepository {
  Future<List<CardUser>> getCards();
  Future<CardUser> createCard(Map<String, dynamic> data);
  Future<CardUser> updateCard(int id, Map<String, dynamic> data);
  Future<void> deleteCard(int id);
  Future<List<CardEntity>> getAvailableCards();
}
