import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final int? id;
  final double monthlyLimit;
  final String monthYear;
  final int userId;
  final double? totalSpent;
  final double? remaining;
  final double? percentage;
  final List<BudgetCategory>? categories;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Budget({
    this.id,
    required this.monthlyLimit,
    required this.monthYear,
    required this.userId,
    this.totalSpent,
    this.remaining,
    this.percentage,
    this.categories,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOverBudget => (percentage ?? 0) > 100;
  bool get isNearLimit => (percentage ?? 0) >= 90;

  @override
  List<Object?> get props => [id, monthlyLimit, monthYear, userId];
}

class BudgetCategory extends Equatable {
  final int? id;
  final int budgetId;
  final int categoryId;
  final double limitAmount;
  final double? spent;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  const BudgetCategory({
    this.id,
    required this.budgetId,
    required this.categoryId,
    required this.limitAmount,
    this.spent,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  double get percentage => limitAmount > 0 ? ((spent ?? 0) / limitAmount * 100) : 0;
  double get remaining => limitAmount - (spent ?? 0);

  @override
  List<Object?> get props => [id, budgetId, categoryId];
}
