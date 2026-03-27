import '../entities/income.dart';

abstract class IncomeRepository {
  Future<List<Income>> getIncomes({Map<String, dynamic>? filters});
  Future<Income> createIncome(Map<String, dynamic> data);
  Future<Income> updateIncome(int id, Map<String, dynamic> data);
  Future<void> deleteIncome(int id);
  Future<void> toggleActive(int id);
  Future<IncomeSummary> getSummary();
}
