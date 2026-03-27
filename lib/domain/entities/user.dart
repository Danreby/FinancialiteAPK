import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? theme;
  final String? avatar;
  final String? googleId;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.theme,
    this.avatar,
    this.googleId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email];
}
