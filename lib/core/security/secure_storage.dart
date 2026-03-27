import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_constants.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
        );

  Future<String?> getAccessToken() => _storage.read(key: StorageConstants.accessToken);
  Future<void> setAccessToken(String token) => _storage.write(key: StorageConstants.accessToken, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: StorageConstants.refreshTokenKey);
  Future<void> setRefreshToken(String token) => _storage.write(key: StorageConstants.refreshTokenKey, value: token);

  Future<String?> getUserId() => _storage.read(key: StorageConstants.userId);
  Future<void> setUserId(String id) => _storage.write(key: StorageConstants.userId, value: id);

  Future<String?> getUserName() => _storage.read(key: StorageConstants.userName);
  Future<void> setUserName(String name) => _storage.write(key: StorageConstants.userName, value: name);

  Future<String?> getUserEmail() => _storage.read(key: StorageConstants.userEmail);
  Future<void> setUserEmail(String email) => _storage.write(key: StorageConstants.userEmail, value: email);

  Future<void> clearAll() => _storage.deleteAll();

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
