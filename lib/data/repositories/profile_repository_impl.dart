import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/security/input_sanitizer.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _api;

  ProfileRepositoryImpl(this._api);

  @override
  Future<User> getProfile() async {
    final response = await _api.get(ApiConstants.profile);
    return UserModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final sanitized = InputSanitizer.sanitizeMap(data);
    final response = await _api.patch(ApiConstants.profile, data: sanitized);
    return UserModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<void> updateTheme(String theme) async {
    await _api.patch(ApiConstants.profileTheme, data: {'theme': theme});
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _api.patch(ApiConstants.profilePassword, data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation,
    });
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    await _api.delete(ApiConstants.profile, data: {'password': password});
  }
}
