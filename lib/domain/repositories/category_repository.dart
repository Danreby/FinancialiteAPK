import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories({String? type});
  Future<Category> createCategory(Map<String, dynamic> data);
  Future<Category> updateCategory(int id, Map<String, dynamic> data);
  Future<void> deleteCategory(int id);
}
