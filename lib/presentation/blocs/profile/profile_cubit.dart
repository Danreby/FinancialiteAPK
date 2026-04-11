import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../core/utils/error_message.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final user = await _repository.getProfile();
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(extractErrorMessage(e)));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = await _repository.updateProfile(data);
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(extractErrorMessage(e)));
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    try {
      await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmation,
      );
      if (state is ProfileLoaded) {
        emit(ProfilePasswordChanged((state as ProfileLoaded).user));
      }
    } catch (e) {
      emit(ProfileError(extractErrorMessage(e)));
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      await _repository.deleteAccount(password: password);
      emit(const ProfileDeleted());
    } catch (e) {
      emit(ProfileError(extractErrorMessage(e)));
    }
  }
}
