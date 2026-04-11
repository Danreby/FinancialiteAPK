import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../datasources/local/app_database.dart';

abstract class BaseOfflineRepository {
  final ApiClient api;
  final NetworkInfo networkInfo;

  BaseOfflineRepository(this.api, this.networkInfo);

  Future<Database> get db => AppDatabase.database;

  Future<void> addToSyncQueue(String tableName, int recordId, String action,
      Map<String, dynamic>? data) async {
    final database = await db;
    await database.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': data != null ? jsonEncode(data) : null,
      'attempts': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> get isOnline => networkInfo.isConnected;

  List<dynamic> safeList(dynamic data) {
    if (data is List) return data;
    if (data is Map) return (data['data'] as List?) ?? const [];
    return const [];
  }

  Map<String, dynamic> extractData(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('data')) {
      return responseData['data'] as Map<String, dynamic>;
    }
    return responseData as Map<String, dynamic>;
  }

  Future<void> batchCache(
    String table,
    List<dynamic> items,
    Map<String, dynamic> Function(dynamic) toDbMap,
  ) async {
    try {
      final database = await db;
      final batch = database.batch();
      for (final item in items) {
        batch.insert(table, toDbMap(item),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }
}
