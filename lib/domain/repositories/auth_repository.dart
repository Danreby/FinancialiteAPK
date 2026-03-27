import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> register({required String name, required String email, required String password, required String passwordConfirmation});
  Future<User> googleLogin({required String idToken});
  Future<void> logout();
  Future<User> getUser();
  Future<String?> refreshToken();
  Future<bool> isAuthenticated();
}
