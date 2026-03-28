import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions(
      {Map<String, dynamic>? filters, int page = 1, int perPage = 20});
  Future<Transaction> getTransaction(int id);
  Future<Transaction> createTransaction(Map<String, dynamic> data);
  Future<Transaction> updateTransaction(int id, Map<String, dynamic> data);
  Future<void> deleteTransaction(int id);
  Future<void> restoreTransaction(int id);
  Future<Map<String, dynamic>> getStats({Map<String, dynamic>? filters});
  Future<Map<String, dynamic>> getInsights({Map<String, dynamic>? filters});
  Future<List<Map<String, dynamic>>> getTopSpending(
      {Map<String, dynamic>? filters});
  Future<void> payMonth({required String monthKey, int? bankUserId});
  Future<String> exportData({Map<String, dynamic>? filters});
  Future<Map<String, dynamic>> getFaturas(
      {required String month, int? bankUserId, int? categoryId});
}
