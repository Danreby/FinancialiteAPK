import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final int? id;
  final String title;
  final String? message;
  final String type;
  final bool isRead;
  final int userId;
  final DateTime? createdAt;

  const AppNotification({
    this.id,
    required this.title,
    this.message,
    this.type = 'info',
    this.isRead = false,
    required this.userId,
    this.createdAt,
  });

  bool get isSuccess => type == 'success';
  bool get isWarning => type == 'warning';
  bool get isError => type == 'error';
  bool get isInfo => type == 'info';

  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    int? userId,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, userId];
}
