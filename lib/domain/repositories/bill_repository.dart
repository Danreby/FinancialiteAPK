import '../entities/bill.dart';

abstract class BillRepository {
  Future<List<Bill>> getBills({Map<String, dynamic>? filters});
  Future<Bill> createBill(Map<String, dynamic> data);
  Future<Bill> updateBill(int id, Map<String, dynamic> data);
  Future<void> deleteBill(int id);
  Future<List<Bill>> getUpcoming();
  Future<void> markAsPaid(int id);
  Future<void> toggleStatus(int id);
}
