import '../entities/savings_goal.dart';

abstract class SavingsRepository {
  Future<List<SavingsGoal>> getGoals();
  Future<SavingsGoal> createGoal(Map<String, dynamic> data);
  Future<SavingsGoal> updateGoal(int id, Map<String, dynamic> data);
  Future<void> deleteGoal(int id);
  Future<SavingsGoal> deposit(int id, double amount);
  Future<SavingsGoal> withdraw(int id, double amount);
  Future<SavingsSummary> getSummary();
}
