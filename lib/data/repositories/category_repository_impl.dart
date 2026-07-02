import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/security/input_sanitizer.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';
import 'base_offline_repository.dart';

class CategoryRepositoryImpl extends BaseOfflineRepository
    implements CategoryRepository {
  CategoryRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<Category>> getCategories({String? type}) async {
    try {
      if (await isOnline) {
        final params = type != null ? {'type': type} : null;
        final response =
            await api.get(ApiConstants.categories, queryParameters: params);
        final list = safeList(response.data)
            .map((j) => CategoryModel.fromJson(j))
            .toList();
        final database = await db;
        final batch = database.batch();
        for (final item in list) {
          batch.insert('categories', item.toDbMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
        return list;
      }
    } catch (_) {}
    final database = await db;
    final where = type != null ? 'type = ?' : null;
    final whereArgs = type != null ? [type] : null;
    final results = await database.query('categories',
        where: where, whereArgs: whereArgs, orderBy: 'name ASC');
    return results.map((r) => CategoryModel.fromDb(r)).toList();
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response = await api.post(ApiConstants.categories, data: sanitized);
      final category =
          CategoryModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.insert('categories', category.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return category;
    }
    final database = await db;
    sanitized['created_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    final id = await database.insert('categories', sanitized);
    await addToSyncQueue('categories', id, 'create', sanitized);
    sanitized['id'] = id;
    return CategoryModel.fromDb(sanitized);
  }

  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    if (await isOnline) {
      final response =
          await api.put('${ApiConstants.categories}/$id', data: sanitized);
      final category =
          CategoryModel.fromJson(response.data['data'] ?? response.data);
      final database = await db;
      await database.update('categories', category.toDbMap(),
          where: 'id = ?', whereArgs: [id]);
      return category;
    }
    final database = await db;
    sanitized['updated_at'] = DateTime.now().toIso8601String();
    sanitized['synced'] = 0;
    await database
        .update('categories', sanitized, where: 'id = ?', whereArgs: [id]);
    await addToSyncQueue('categories', id, 'update', sanitized);
    final results =
        await database.query('categories', where: 'id = ?', whereArgs: [id]);
    return CategoryModel.fromDb(results.first);
  }

  @override
  Future<void> deleteCategory(int id) async {
    if (await isOnline) {
      await api.delete('${ApiConstants.categories}/$id');
    } else {
      await addToSyncQueue('categories', id, 'delete', null);
    }
    final database = await db;
    await database.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
