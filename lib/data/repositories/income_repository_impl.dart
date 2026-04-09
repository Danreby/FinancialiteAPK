import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/security/input_sanitizer.dart';
import '../../domain/entities/income.dart';
import '../../domain/repositories/income_repository.dart';
import '../models/income_model.dart';
import 'base_offline_repository.dart';

class IncomeRepositoryImpl extends BaseOfflineRepository
    implements IncomeRepository {
  IncomeRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<Income>> getIncomes({Map<String, dynamic>? filters}) async {
    try {
      if (await isOnline) {
        final response =
            await api.get(ApiConstants.incomes, queryParameters: filters);
        final list = safeList(response.data)
            .map((j) => IncomeModel.fromJson(j))
            .toList();
        try {
          final database = await db;
          final batch = database.batch();
          for (final item in list) {
            batch.insert('incomes', (item as IncomeModel).toDbMap(),
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
          await batch.commit(noResult: true);
        } catch (_) {}
        return list;
      }
    } catch (_) {}
    final database = await db;
    final results = await database.query('incomes',
        where: 'deleted_at IS NULL', orderBy: 'created_at DESC');
    return results.map((r) => IncomeModel.fromDb(r)).toList();
  }

  @override
  Future<Income> createIncome(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response = await api.post(ApiConstants.incomes, data: sanitized);
      return IncomeModel.fromJson(response.data['data'] ?? response.data);
    }
    final database = await db;
    sanitized['created_at'] = DateTime.now().toIso8601String();
    final id = await database.insert('incomes', sanitized);
    await addToSyncQueue('incomes', id, 'create', sanitized);
    sanitized['id'] = id;
    return IncomeModel.fromDb(sanitized);
  }

  @override
  Future<Income> updateIncome(int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response =
          await api.put('${ApiConstants.incomes}/$id', data: sanitized);
      return IncomeModel.fromJson(response.data['data'] ?? response.data);
    }
    final database = await db;
    await database
        .update('incomes', sanitized, where: 'id = ?', whereArgs: [id]);
    await addToSyncQueue('incomes', id, 'update', sanitized);
    final results =
        await database.query('incomes', where: 'id = ?', whereArgs: [id]);
    return IncomeModel.fromDb(results.first);
  }

  @override
  Future<void> deleteIncome(int id) async {
    if (await isOnline) {
      await api.delete('${ApiConstants.incomes}/$id');
    } else {
      await addToSyncQueue('incomes', id, 'delete', null);
    }
    final database = await db;
    await database.update(
        'incomes', {'deleted_at': DateTime.now().toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> toggleActive(int id) async {
    await api.patch('${ApiConstants.incomes}/$id/toggle');
  }

  @override
  Future<IncomeSummary> getSummary() async {
    final response = await api.get(ApiConstants.incomeSummary);
    final data = response.data is Map && response.data['data'] != null
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;
    return IncomeSummaryModel.fromJson(data);
  }
}
