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
          batch.insert('categories', (item as CategoryModel).toDbMap(),
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
    final response = await api.post(ApiConstants.categories, data: sanitized);
    return CategoryModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    final response =
        await api.put('${ApiConstants.categories}/$id', data: sanitized);
    return CategoryModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await api.delete('${ApiConstants.categories}/$id');
    final database = await db;
    await database.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
