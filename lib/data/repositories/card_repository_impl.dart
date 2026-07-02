import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../models/card_model.dart';
import '../../core/security/input_sanitizer.dart';
import 'base_offline_repository.dart';

class CardRepositoryImpl extends BaseOfflineRepository
    implements CardRepository {
  CardRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<CardUser>> getCards() async {
    try {
      if (await isOnline) {
        final response = await api.get(ApiConstants.cards);
        return safeList(response.data)
            .map((j) => CardUserModel.fromJson(j))
            .toList();
      }
    } catch (_) {}
    final database = await db;
    final results =
        await database.query('card_users', orderBy: 'created_at DESC');
    return results
        .map((r) => CardUserModel(
              id: r['id'] as int?,
              userId: r['user_id'] as int,
              cardId: r['card_id'] as int,
              dueDay: r['due_day'] as int? ?? 10,
              closingDay: r['closing_day'] as int? ?? 3,
              creditLimit: (r['credit_limit'] as num? ?? 0).toDouble(),
              nickname: r['nickname'] as String?,
            ))
        .toList();
  }

  @override
  Future<CardUser> createCard(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response = await api.post(ApiConstants.cards, data: sanitized);
      final card = CardUserModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.insert('card_users', card.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return card;
    }
    final database = await db;
    sanitized['created_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    final id = await database.insert('card_users', sanitized);
    await addToSyncQueue('card_users', id, 'create', sanitized);
    return CardUserModel(
      id: id,
      userId: sanitized['user_id'] as int? ?? 0,
      cardId: sanitized['card_id'] as int,
      dueDay: sanitized['due_day'] as int? ?? 10,
      closingDay: sanitized['closing_day'] as int? ?? 3,
      creditLimit: (sanitized['credit_limit'] as num? ?? 0).toDouble(),
      nickname: sanitized['nickname'] as String?,
    );
  }

  @override
  Future<CardUser> updateCard(int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response =
          await api.put('${ApiConstants.cards}/$id', data: sanitized);
      final card = CardUserModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.update('card_users', card.toDbMap(),
          where: 'id = ?', whereArgs: [id]);
      return card;
    }
    final database = await db;
    sanitized['updated_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    await database
        .update('card_users', sanitized, where: 'id = ?', whereArgs: [id]);
    await addToSyncQueue('card_users', id, 'update', sanitized);
    final results =
        await database.query('card_users', where: 'id = ?', whereArgs: [id]);
    final r = results.first;
    return CardUserModel(
      id: r['id'] as int?,
      userId: r['user_id'] as int,
      cardId: r['card_id'] as int,
      dueDay: r['due_day'] as int? ?? 10,
      closingDay: r['closing_day'] as int? ?? 3,
      creditLimit: (r['credit_limit'] as num? ?? 0).toDouble(),
      nickname: r['nickname'] as String?,
    );
  }

  @override
  Future<void> deleteCard(int id) async {
    if (await isOnline) {
      await api.delete('${ApiConstants.cards}/$id');
    } else {
      await addToSyncQueue('card_users', id, 'delete', null);
    }
    final database = await db;
    await database.delete('card_users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<CardEntity>> getAvailableCards() async {
    final response = await api.get(ApiConstants.cardsAvailable);
    return (response.data['data'] as List? ?? response.data as List)
        .map((j) => CardEntityModel.fromJson(j))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> getInvoice(int cardId, {String? month}) async {
    final params = <String, dynamic>{};
    if (month != null) params['month'] = month;
    final response = await api.get('${ApiConstants.cards}/$cardId/invoice',
        queryParameters: params);
    return response.data is Map
        ? Map<String, dynamic>.from(response.data)
        : null;
  }

  @override
  Future<void> payInvoice(int cardId, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    await api.post('${ApiConstants.cards}/$cardId/pay-invoice',
        data: sanitized);
  }
}
