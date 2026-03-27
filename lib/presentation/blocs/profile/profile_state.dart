part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final User user;
  const ProfileLoaded({required this.user});
  @override
  List<Object?> get props => [user];
}

class ProfilePasswordChanged extends ProfileState {
  final User user;
  const ProfilePasswordChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileDeleted extends ProfileState {
  const ProfileDeleted();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
