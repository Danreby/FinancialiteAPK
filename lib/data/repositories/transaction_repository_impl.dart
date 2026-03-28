import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/security/input_sanitizer.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';
import 'base_offline_repository.dart';

class TransactionRepositoryImpl extends BaseOfflineRepository
    implements TransactionRepository {
  TransactionRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<Transaction>> getTransactions(
      {Map<String, dynamic>? filters, int page = 1, int perPage = 20}) async {
    try {
      if (await isOnline) {
        final params = <String, dynamic>{'page': page, 'per_page': perPage};
        if (filters != null) params.addAll(filters);
        final response =
            await api.get(ApiConstants.transactions, queryParameters: params);
        final rawList = safeList(response.data);
        final list = rawList
            .map((json) =>
                TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache to local DB (non-critical — don't let caching failures lose data)
        try {
          final database = await db;
          final batch = database.batch();
          for (final item in list) {
            batch.insert('transactions', (item as TransactionModel).toDbMap(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
          await batch.commit(noResult: true);
        } catch (cacheError) {
          debugPrint('[TransactionRepo] Cache error: $cacheError');
        }
        return list;
      }
    } catch (e) {
      debugPrint('[TransactionRepo] getTransactions error: $e');
    }

    final database = await db;
    final results = await database.query(
      'transactions',
      where: 'deleted_at IS NULL',
      orderBy: 'date DESC',
      limit: perPage,
      offset: (page - 1) * perPage,
    );
    return results.map((r) => TransactionModel.fromDb(r)).toList();
  }

  @override
  Future<Transaction> getTransaction(int id) async {
    try {
      if (await isOnline) {
        final response = await api.get('${ApiConstants.transactions}/$id');
        final data = response.data is Map<String, dynamic>
            ? response.data
            : response.data['data'];
        return TransactionModel.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[TransactionRepo] getTransaction error: $e');
    }

    final database = await db;
    final results =
        await database.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) return TransactionModel.fromDb(results.first);
    throw const ServerException(message: 'Transação não encontrada');
  }

  @override
  Future<Transaction> createTransaction(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);

    if (await isOnline) {
      final response =
          await api.post(ApiConstants.transactions, data: sanitized);
      final transaction =
          TransactionModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.insert(
          'transactions', (transaction as TransactionModel).toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return transaction;
    }

    final database = await db;
    sanitized['created_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    final id = await database.insert('transactions', sanitized);
    await addToSyncQueue('transactions', id, 'create', sanitized);
    sanitized['id'] = id;
    return TransactionModel.fromDb(sanitized);
  }

  @override
  Future<Transaction> updateTransaction(
      int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);

    if (await isOnline) {
      final response =
          await api.put('${ApiConstants.transactions}/$id', data: sanitized);
      final transaction =
          TransactionModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.update(
          'transactions', (transaction as TransactionModel).toDbMap(),
          where: 'id = ?', whereArgs: [id]);
      return transaction;
    }

    final database = await db;
    sanitized['updated_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    await database
        .update('transactions', sanitized, where: 'id = ?', whereArgs: [id]);
    await addToSyncQueue('transactions', id, 'update', sanitized);
    final results =
        await database.query('transactions', where: 'id = ?', whereArgs: [id]);
    return TransactionModel.fromDb(results.first);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    if (await isOnline) {
      await api.delete('${ApiConstants.transactions}/$id');
    } else {
      await addToSyncQueue('transactions', id, 'delete', null);
    }
    final database = await db;
    await database.update(
        'transactions', {'deleted_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> restoreTransaction(int id) async {
    await api.post('${ApiConstants.transactions}/$id/restore');
    final database = await db;
    await database.update('transactions', {'deleted_at': null},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Map<String, dynamic>> getStats({Map<String, dynamic>? filters}) async {
    final response =
        await api.get(ApiConstants.transactionStats, queryParameters: filters);
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  @override
  Future<Map<String, dynamic>> getInsights(
      {Map<String, dynamic>? filters}) async {
    final response = await api.get(ApiConstants.transactionInsights,
        queryParameters: filters);
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  @override
  Future<List<Map<String, dynamic>>> getTopSpending(
      {Map<String, dynamic>? filters}) async {
    final response = await api.get(ApiConstants.transactionTopSpending,
        queryParameters: filters);
    return (response.data as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> payMonth({required String monthKey, int? bankUserId}) async {
    await api.post(ApiConstants.transactionPayMonth, data: {
      'month_key': monthKey,
      if (bankUserId != null) 'bank_user_id': bankUserId,
    });
  }

  @override
  Future<String> exportData({Map<String, dynamic>? filters}) async {
    final response =
        await api.get(ApiConstants.transactionExport, queryParameters: filters);
    return response.data.toString();
  }

  @override
  Future<Map<String, dynamic>> getFaturas(
      {required String month, int? bankUserId, int? categoryId}) async {
    final params = <String, dynamic>{'month': month};
    if (bankUserId != null) params['bank_user_id'] = bankUserId;
    if (categoryId != null) params['category_id'] = categoryId;
    final response =
        await api.get(ApiConstants.transactionFaturas, queryParameters: params);
    final data = response.data is Map<String, dynamic>
        ? response.data
        : (response.data['data'] ?? {});
    return data as Map<String, dynamic>;
  }
}
