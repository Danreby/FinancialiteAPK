import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../datasources/local/app_database.dart';

/// Drains the `sync_queue` table populated by [BaseOfflineRepository]'s
/// `addToSyncQueue`, pushing offline-made create/update/delete changes to
/// the backend once connectivity returns. Without this, queued changes sat
/// in local SQLite forever -- this is the missing "come back online" half
/// of the app's offline-first design.
class SyncService {
  final ApiClient api;
  final NetworkInfo networkInfo;

  SyncService(this.api, this.networkInfo);

  bool _isSyncing = false;

  /// Maps a `sync_queue.table_name` (== local SQLite table name) to the
  /// API endpoint used for that entity's create/update/delete requests.
  static const Map<String, String> _endpoints = {
    'transactions': ApiConstants.transactions,
    'bills': ApiConstants.bills,
    'incomes': ApiConstants.incomes,
    'budgets': ApiConstants.budgets,
    'savings_goals': ApiConstants.savings,
    'bank_users': ApiConstants.bankAccounts,
    'card_users': ApiConstants.cards,
    'categories': ApiConstants.categories,
  };

  static const int _maxAttempts = 3;

  /// Processes every pending queue entry once, in the order it was written.
  /// Safe to call repeatedly (e.g. on every reconnect) -- re-entrant calls
  /// while one is already running are no-ops.
  Future<void> processQueue() async {
    if (_isSyncing) return;
    if (!await networkInfo.isConnected) return;
    _isSyncing = true;
    try {
      final db = await AppDatabase.database;
      final rows = await db.query(
        'sync_queue',
        where: 'processed_at IS NULL AND attempts < ?',
        whereArgs: [_maxAttempts],
        orderBy: 'id ASC',
      );
      if (rows.isEmpty) return;

      // A queued 'create' happens under a temporary local id; if the same
      // batch later updates/deletes that same record, those entries must be
      // redirected to the id the server actually assigned.
      final idRemap = <String, Map<int, int>>{};

      for (final row in rows) {
        final queueId = row['id'] as int;
        final tableName = row['table_name'] as String;
        final recordId = row['record_id'] as int;
        final action = row['action'] as String;
        final rawData = row['data'] as String?;
        final data =
            rawData != null ? jsonDecode(rawData) as Map<String, dynamic> : null;

        final endpoint = _endpoints[tableName];
        if (endpoint == null) {
          await _markProcessed(db, queueId);
          continue;
        }

        final effectiveId = idRemap[tableName]?[recordId] ?? recordId;

        try {
          switch (action) {
            case 'create':
              final response = await api.post(endpoint, data: data);
              final serverEntity = _extractEntity(response.data);
              final serverId = serverEntity?['id'] as int?;
              if (serverId != null && serverId != recordId) {
                idRemap.putIfAbsent(tableName, () => {})[recordId] = serverId;
                // Drop the temp-id row -- the next online list fetch for
                // this feature repopulates it correctly via the entity's
                // own fromJson/toDbMap, which this generic service doesn't
                // duplicate.
                await db.delete(tableName, where: 'id = ?', whereArgs: [recordId]);
              } else {
                await db.update(tableName, {'synced': 1},
                    where: 'id = ?', whereArgs: [recordId]);
              }
              break;
            case 'update':
              await api.put('$endpoint/$effectiveId', data: data);
              await db.update(tableName, {'synced': 1},
                  where: 'id = ?', whereArgs: [effectiveId]);
              break;
            case 'delete':
              await api.delete('$endpoint/$effectiveId');
              break;
          }
          await _markProcessed(db, queueId);
        } catch (e) {
          debugPrint(
              '[SyncService] Failed to sync $tableName#$recordId ($action): $e');
          await db.rawUpdate(
              'UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?',
              [queueId]);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _markProcessed(Database db, int queueId) async {
    await db.update(
      'sync_queue',
      {'processed_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [queueId],
    );
  }

  Map<String, dynamic>? _extractEntity(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final nested = responseData['data'];
      if (nested is Map<String, dynamic>) return nested;
      return responseData;
    }
    return null;
  }
}
