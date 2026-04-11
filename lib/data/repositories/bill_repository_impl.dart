import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/security/input_sanitizer.dart';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../models/bill_model.dart';
import 'base_offline_repository.dart';

class BillRepositoryImpl extends BaseOfflineRepository
    implements BillRepository {
  BillRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<Bill>> getBills({Map<String, dynamic>? filters}) async {
    try {
      if (await isOnline) {
        final response =
            await api.get(ApiConstants.bills, queryParameters: filters);
        final list =
            safeList(response.data).map((j) => BillModel.fromJson(j)).toList();
        try {
          final database = await db;
          final batch = database.batch();
          for (final item in list) {
            batch.insert('bills', (item as BillModel).toDbMap(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
          await batch.commit(noResult: true);
        } catch (cacheError) {
          debugPrint('[BillRepo] Cache error: $cacheError');
        }
        return list;
      }
    } catch (e) {
      debugPrint('[BillRepo] getBills error: $e');
    }
    final database = await db;
    final results = await database.query('bills',
        where: 'deleted_at IS NULL', orderBy: 'due_day ASC');
    return results.map((r) => BillModel.fromDb(r)).toList();
  }

  @override
  Future<Bill> createBill(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response = await api.post(ApiConstants.bills, data: sanitized);
      final bill = BillModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.insert('bills', (bill as BillModel).toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return bill;
    }
    final database = await db;
    sanitized['created_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    final id = await database.insert('bills', sanitized);
    await addToSyncQueue('bills', id, 'create', sanitized);
    sanitized['id'] = id;
    return BillModel.fromDb(sanitized);
  }

  @override
  Future<Bill> updateBill(int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response =
          await api.put('${ApiConstants.bills}/$id', data: sanitized);
      return BillModel.fromJson(response.data['data'] ?? response.data);
    }
    final database = await db;
    await database.update('bills', sanitized, where: 'id = ?', whereArgs: [id]);
    await addToSyncQueue('bills', id, 'update', sanitized);
    final results =
        await database.query('bills', where: 'id = ?', whereArgs: [id]);
    return BillModel.fromDb(results.first);
  }

  @override
  Future<void> deleteBill(int id) async {
    if (await isOnline) {
      await api.delete('${ApiConstants.bills}/$id');
    } else {
      await addToSyncQueue('bills', id, 'delete', null);
    }
    final database = await db;
    await database.update(
        'bills', {'deleted_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Bill>> getUpcoming() async {
    final response = await api.get(ApiConstants.billsUpcoming);
    return safeList(response.data).map((j) => BillModel.fromJson(j)).toList();
  }

  @override
  Future<void> markAsPaid(int id, {Map<String, dynamic>? data}) async {
    await api.post('${ApiConstants.bills}/$id/pay', data: data);
  }

  @override
  Future<void> toggleStatus(int id) async {
    await api.patch('${ApiConstants.bills}/$id/toggle');
    final database = await db;
    final results =
        await database.query('bills', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      final current = results.first['is_active'] == 1 ? 0 : 1;
      await database.update('bills', {'is_active': current},
          where: 'id = ?', whereArgs: [id]);
    }
  }
}
