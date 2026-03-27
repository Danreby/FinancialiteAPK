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

  @override
  List<Object?> get props => [id, title, userId];
}
