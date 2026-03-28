import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/security/input_sanitizer.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';
import '../models/savings_model.dart';
import 'base_offline_repository.dart';

class SavingsRepositoryImpl extends BaseOfflineRepository
    implements SavingsRepository {
  SavingsRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<SavingsGoal>> getGoals() async {
    try {
      if (await isOnline) {
        final response = await api.get(ApiConstants.savings);
        final list = safeList(response.data)
            .map((j) => SavingsGoalModel.fromJson(j))
            .toList();
        final database = await db;
        final batch = database.batch();
        for (final item in list) {
          batch.insert('savings_goals', (item as SavingsGoalModel).toDbMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
        return list;
      }
    } catch (_) {}
    final database = await db;
    final results = await database.query('savings_goals',
        where: 'deleted_at IS NULL', orderBy: 'created_at DESC');
    return results.map((r) => SavingsGoalModel.fromDb(r)).toList();
  }

  @override
  Future<SavingsGoal> createGoal(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    final response = await api.post(ApiConstants.savings, data: sanitized);
    return SavingsGoalModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<SavingsGoal> updateGoal(int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    final response =
        await api.put('${ApiConstants.savings}/$id', data: sanitized);
    return SavingsGoalModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<void> deleteGoal(int id) async {
    await api.delete('${ApiConstants.savings}/$id');
    final database = await db;
    await database.update(
        'savings_goals', {'deleted_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<SavingsGoal> deposit(int id, double amount) async {
    final response = await api
        .post('${ApiConstants.savings}/$id/deposit', data: {'amount': amount});
    return SavingsGoalModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<SavingsGoal> withdraw(int id, double amount) async {
    final response = await api
        .post('${ApiConstants.savings}/$id/withdraw', data: {'amount': amount});
    return SavingsGoalModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<SavingsSummary> getSummary() async {
    final response = await api.get(ApiConstants.savingsSummary);
    return SavingsSummaryModel.fromJson(
        response.data is Map ? response.data : {});
  }
}
