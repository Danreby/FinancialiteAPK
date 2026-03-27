import '../entities/user.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile(Map<String, dynamic> data);
  Future<void> updateTheme(String theme);
  Future<void> updatePassword({required String currentPassword, required String newPassword, required String newPasswordConfirmation});
  Future<void> deleteAccount();
}
