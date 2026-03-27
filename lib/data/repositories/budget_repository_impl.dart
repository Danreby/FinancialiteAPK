import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../models/budget_model.dart';
import 'base_offline_repository.dart';

class BudgetRepositoryImpl extends BaseOfflineRepository implements BudgetRepository {
  BudgetRepositoryImpl(ApiClient api, NetworkInfo networkInfo) : super(api, networkInfo);

  @override
  Future<List<Budget>> getBudgets() async {
    try {
      if (await isOnline) {
        final response = await api.get(ApiConstants.budgets);
        final list = (response.data['data'] as List? ?? response.data as List)
            .map((j) => BudgetModel.fromJson(j)).toList();
        final database = await db;
        final batch = database.batch();
        for (final item in list) {
          batch.insert('budgets', (item as BudgetModel).toDbMap(), conflictAlgorithm: ConflictAlgorithm.replace);
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
    final response = await api.post(ApiConstants.budgets, data: data);
    return BudgetModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<Budget> updateBudget(int id, Map<String, dynamic> data) async {
    final response = await api.put('${ApiConstants.budgets}/$id', data: data);
    return BudgetModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<void> deleteBudget(int id) async {
    await api.delete('${ApiConstants.budgets}/$id');
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
