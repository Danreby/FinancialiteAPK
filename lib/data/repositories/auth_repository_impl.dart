import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/security/secure_storage.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/local/app_database.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _api;
  final SecureStorage _secureStorage;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(this._api, this._secureStorage, this._networkInfo);

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _api.post(ApiConstants.login, data: {'email': email, 'password': password});
      final data = response.data;
      final user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;

      await _secureStorage.setAccessToken(token);
      await _secureStorage.setUserId(user.id.toString());
      await _secureStorage.setUserName(user.name);
      await _secureStorage.setUserEmail(user.email);

      final db = await AppDatabase.database;
      await db.insert('users', user.toDbMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      return user;
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: 'Erro ao fazer login');
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _api.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      final data = response.data;
      final user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;

      await _secureStorage.setAccessToken(token);
      await _secureStorage.setUserId(user.id.toString());
      await _secureStorage.setUserName(user.name);
      await _secureStorage.setUserEmail(user.email);

      final db = await AppDatabase.database;
      await db.insert('users', user.toDbMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      return user;
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: 'Erro ao registrar');
    }
  }

  @override
  Future<User> googleLogin({required String idToken}) async {
    try {
      final response = await _api.post(ApiConstants.googleLogin, data: {'id_token': idToken});
      final data = response.data;
      final user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;

      await _secureStorage.setAccessToken(token);
      await _secureStorage.setUserId(user.id.toString());
      await _secureStorage.setUserName(user.name);
      await _secureStorage.setUserEmail(user.email);

      return user;
    } on DioException catch (e) {
      throw e.error ?? ServerException(message: 'Erro ao autenticar com Google');
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (await _networkInfo.isConnected) {
        await _api.post(ApiConstants.logout);
      }
    } catch (_) {}
    await _secureStorage.clearAll();
    await AppDatabase.clearAll();
  }

  @override
  Future<User> getUser() async {
    try {
      if (await _networkInfo.isConnected) {
        final response = await _api.get(ApiConstants.user);
        final user = UserModel.fromJson(response.data['user'] ?? response.data);
        final db = await AppDatabase.database;
        await db.insert('users', user.toDbMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        return user;
      }
    } catch (_) {}

    final db = await AppDatabase.database;
    final userId = await _secureStorage.getUserId();
    if (userId != null) {
      final results = await db.query('users', where: 'id = ?', whereArgs: [int.parse(userId)]);
      if (results.isNotEmpty) return UserModel.fromDb(results.first);
    }
    throw const AuthException();
  }

  @override
  Future<String?> refreshToken() async {
    try {
      final response = await _api.post(ApiConstants.refreshToken);
      final token = response.data['token'] as String?;
      if (token != null) await _secureStorage.setAccessToken(token);
      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasToken();
  }
}
