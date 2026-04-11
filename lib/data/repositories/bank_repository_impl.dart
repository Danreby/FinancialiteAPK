import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/security/input_sanitizer.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/repositories/bank_repository.dart';
import '../models/bank_model.dart';
import 'base_offline_repository.dart';

class BankRepositoryImpl extends BaseOfflineRepository
    implements BankRepository {
  BankRepositoryImpl(ApiClient api, NetworkInfo networkInfo)
      : super(api, networkInfo);

  @override
  Future<List<BankAccount>> getAccounts() async {
    try {
      if (await isOnline) {
        final response = await api.get(ApiConstants.bankAccounts);
        final list = safeList(response.data)
            .map((j) => BankAccountModel.fromJson(j))
            .toList();
        final database = await db;
        final batch = database.batch();
        for (final item in list) {
          batch.insert('bank_users', (item as BankAccountModel).toDbMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
        return list;
      }
    } catch (_) {}
    final database = await db;
    final results =
        await database.query('bank_users', orderBy: 'created_at DESC');
    return results.map((r) => BankAccountModel.fromDb(r)).toList();
  }

  @override
  Future<BankAccount> getAccount(int id) async {
    final response = await api.get('${ApiConstants.bankAccounts}/$id');
    return BankAccountModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<BankAccount> createAccount(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    final response = await api.post(ApiConstants.bankAccounts, data: sanitized);
    return BankAccountModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<BankAccount> updateAccount(int id, Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    final response =
        await api.put('${ApiConstants.bankAccounts}/$id', data: sanitized);
    return BankAccountModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<void> deleteAccount(int id) async {
    await api.delete('${ApiConstants.bankAccounts}/$id');
    final database = await db;
    await database.delete('bank_users', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<BankStats> getStats() async {
    final response = await api.get(ApiConstants.bankAccountsStats);
    return BankStatsModel.fromJson(response.data is Map ? response.data : {});
  }

  @override
  Future<List<Bank>> getAvailableBanks() async {
    final response = await api.get(ApiConstants.bankAccountsBanks);
    return safeList(response.data).map((j) => BankModel.fromJson(j)).toList();
  }

  @override
  Future<List<BankTransfer>> getTransfers() async {
    final response = await api.get(ApiConstants.bankTransfers);
    return safeList(response.data)
        .map((j) => BankTransferModel.fromJson(j))
        .toList();
  }

  @override
  Future<BankTransfer> createTransfer(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    final response =
        await api.post(ApiConstants.bankTransfers, data: sanitized);
    return BankTransferModel.fromJson(response.data['data'] ?? response.data);
  }
}
