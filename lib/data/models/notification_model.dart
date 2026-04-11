import '../../core/utils/json_helpers.dart';
import '../../domain/entities/notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    super.id,
    required super.title,
    super.message,
    super.type,
    super.isRead,
    required super.userId,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      message: json['message'] as String?,
      type: json['type'] as String? ?? 'info',
      isRead: json.toBool('is_read'),
      userId: json['user_id'] as int,
      createdAt: json.dateTime('created_at'),
    );
  }

  Map<String, dynamic> toDbMap() => {
    if (id != null) 'id': id,
    'title': title,
    'message': message,
    'type': type,
    'is_read': isRead ? 1 : 0,
    'user_id': userId,
    'created_at': createdAt?.toIso8601String(),
  };

  factory NotificationModel.fromDb(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      message: map['message'] as String?,
      type: map['type'] as String? ?? 'info',
      isRead: map['is_read'] == 1,
      userId: map['user_id'] as int,
      createdAt: map.dateTime('created_at'),
    );
  }
}
