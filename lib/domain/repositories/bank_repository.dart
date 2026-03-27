import '../entities/bank_account.dart';

abstract class BankRepository {
  Future<List<BankAccount>> getAccounts();
  Future<BankAccount> getAccount(int id);
  Future<BankAccount> createAccount(Map<String, dynamic> data);
  Future<BankAccount> updateAccount(int id, Map<String, dynamic> data);
  Future<void> deleteAccount(int id);
  Future<BankStats> getStats();
  Future<List<Bank>> getAvailableBanks();
  Future<List<BankTransfer>> getTransfers();
  Future<BankTransfer> createTransfer(Map<String, dynamic> data);
}
