import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/constants/api_constants.dart';
import '../datasources/local/app_database.dart';

class SyncService {
  final ApiClient _api;
  final NetworkInfo _networkInfo;
  bool _isSyncing = false;

  SyncService(this._api, this._networkInfo);

  Future<void> syncPendingChanges() async {
    if (_isSyncing) return;
    if (!await _networkInfo.isConnected) return;

    _isSyncing = true;
    try {
      final db = await AppDatabase.database;
      final pending = await db.query(
        'sync_queue',
        where: 'processed_at IS NULL AND attempts < 3',
        orderBy: 'created_at ASC',
        limit: 50,
      );

      for (final item in pending) {
        try {
          await _processQueueItem(item);
          await db.update(
            'sync_queue',
            {'processed_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } catch (_) {
          await db.rawUpdate(
            'UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?',
            [item['id']],
          );
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processQueueItem(Map<String, dynamic> item) async {
    final tableName = item['table_name'] as String;
    final action = item['action'] as String;
    final data = item['data'] != null ? jsonDecode(item['data'] as String) as Map<String, dynamic> : null;
    final recordId = item['record_id'] as int;

    final endpoint = _getEndpoint(tableName);
    if (endpoint == null) return;

    switch (action) {
      case 'create':
        if (data != null) await _api.post(endpoint, data: data);
        break;
      case 'update':
        if (data != null) await _api.put('$endpoint/$recordId', data: data);
        break;
      case 'delete':
        await _api.delete('$endpoint/$recordId');
        break;
    }
  }

  String? _getEndpoint(String tableName) {
    switch (tableName) {
      case 'transactions': return ApiConstants.transactions;
      case 'bills': return ApiConstants.bills;
      case 'incomes': return ApiConstants.incomes;
      case 'budgets': return ApiConstants.budgets;
      case 'savings_goals': return ApiConstants.savings;
      case 'categories': return ApiConstants.categories;
      default: return null;
    }
  }
}
