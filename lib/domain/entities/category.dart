import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final int userId;
  final DateTime? createdAt;

  const Category({
    this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.userId,
    this.createdAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  @override
  List<Object?> get props => [id, name, type, userId];
}
