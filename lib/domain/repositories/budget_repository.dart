import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getBudgets();
  Future<Budget> createBudget(Map<String, dynamic> data);
  Future<Budget> updateBudget(int id, Map<String, dynamic> data);
  Future<void> deleteBudget(int id);
  Future<Budget?> getCurrent();
  Future<Budget> getOrCreateCurrent();
}
