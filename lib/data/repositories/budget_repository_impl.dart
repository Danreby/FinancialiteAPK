import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';
import '../../core/security/input_sanitizer.dart';
import 'base_offline_repository.dart';

class BudgetRepositoryImpl extends BaseOfflineRepository
    implements BudgetRepository {
  BudgetRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<Budget>> getBudgets() async {
    try {
      if (await isOnline) {
        final response = await api.get(ApiConstants.budgets);
        final list = safeList(response.data)
            .map((j) => BudgetModel.fromJson(j))
            .toList();
        final database = await db;
        final batch = database.batch();
        for (final item in list) {
          batch.insert('budgets', item.toDbMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
        return list;
      }
    } catch (_) {}
    final database = await db;
    final results = await database.query('budgets', orderBy: 'month_year DESC');
    return results.map((r) => BudgetModel.fromDb(r)).toList();
  }

  @override
  Future<Budget> createBudget(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response = await api.post(ApiConstants.budgets, data: sanitized);
      final budget = BudgetModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.insert('budgets', budget.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return budget;
    }
    final database = await db;
    sanitized['created_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    final id = await database.insert('budgets', sanitized);
    await addToSyncQueue('budgets', id, 'create', sanitized);
    sanitized['id'] = id;
    return BudgetModel.fromDb(sanitized);
  }

  @override
  Future<Budget> updateBudget(int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response =
          await api.put('${ApiConstants.budgets}/$id', data: sanitized);
      final budget = BudgetModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.update('budgets', budget.toDbMap(),
          where: 'id = ?', whereArgs: [id]);
      return budget;
    }
    final database = await db;
    sanitized['updated_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    await database.update('budgets', sanitized, where: 'id = ?', whereArgs: [id]);
    await addToSyncQueue('budgets', id, 'update', sanitized);
    final results =
        await database.query('budgets', where: 'id = ?', whereArgs: [id]);
    return BudgetModel.fromDb(results.first);
  }

  @override
  Future<void> deleteBudget(int id) async {
    if (await isOnline) {
      await api.delete('${ApiConstants.budgets}/$id');
    } else {
      await addToSyncQueue('budgets', id, 'delete', null);
    }
    final database = await db;
    await database.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Budget?> getCurrent() async {
    try {
      final response = await api.get(ApiConstants.budgetsCurrent);
      if (response.data != null && response.data is Map) {
        return BudgetModel.fromJson(response.data['data'] ?? response.data);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<Budget> getOrCreateCurrent() async {
    final response = await api.post(ApiConstants.budgetsGetOrCreate);
    return BudgetModel.fromJson(response.data['data'] ?? response.data);
  }
}
