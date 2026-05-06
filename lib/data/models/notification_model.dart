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

  static String _cleanText(dynamic value) {
    if (value == null) return '';
    var raw = value.toString();
    // If the value looks like a JSON object/array, try to extract a message key
    if (raw.trimLeft().startsWith('{') || raw.trimLeft().startsWith('[')) {
      try {
        // Attempt to find common message keys in JSON-like strings
        final msgMatch = RegExp(r'"(?:message|body|text|msg)"\s*:\s*"([^"]+)"')
            .firstMatch(raw);
        if (msgMatch != null) raw = msgMatch.group(1)!;
      } catch (_) {}
    }
    return raw
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String? _message(dynamic value) {
    final text = _cleanText(value);
    return text.isEmpty ? null : text;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      title: _cleanText(json['title']).isEmpty
          ? 'Notificação'
          : _cleanText(json['title']),
      message: _message(json['message']),
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
      title: _cleanText(map['title']).isEmpty
          ? 'Notificação'
          : _cleanText(map['title']),
      message: _message(map['message']),
      type: map['type'] as String? ?? 'info',
      isRead: map['is_read'] == 1,
      userId: map['user_id'] as int,
      createdAt: map.dateTime('created_at'),
    );
  }
}
