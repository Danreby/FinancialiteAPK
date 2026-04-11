import '../../core/utils/json_helpers.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.theme,
    super.avatar,
    super.googleId,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      theme: json['theme'] as String?,
      avatar: json['avatar'] as String?,
      googleId: json['google_id'] as String?,
      createdAt: json.dateTime('created_at'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'theme': theme,
        'avatar': avatar,
        'google_id': googleId,
      };

  Map<String, dynamic> toDbMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'theme': theme,
        'avatar': avatar,
        'google_id': googleId,
        'created_at': createdAt?.toIso8601String(),
      };

  factory UserModel.fromDb(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      theme: map['theme'] as String?,
      avatar: map['avatar'] as String?,
      googleId: map['google_id'] as String?,
      createdAt: map.dateTime('created_at'),
    );
  }
}
