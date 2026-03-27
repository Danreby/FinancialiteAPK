import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(const CategoryInitial());

  Future<void> loadCategories({String? type}) async {
    emit(const CategoryLoading());
    try {
      final categories = await _repository.getCategories(type: type);
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    try {
      await _repository.createCategory(data);
      loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateCategory(id, data);
      loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.deleteCategory(id);
      if (state is CategoryLoaded) {
        final current = state as CategoryLoaded;
        emit(CategoryLoaded(
          categories: current.categories.where((c) => c.id != id).toList(),
        ));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
