import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    super.id,
    required super.monthlyLimit,
    required super.monthYear,
    required super.userId,
    super.totalSpent,
    super.remaining,
    super.percentage,
    super.categories,
    super.createdAt,
    super.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    List<BudgetCategory>? categories;
    if (json['categories'] != null) {
      categories = (json['categories'] as List)
          .map((c) => BudgetCategoryModel.fromJson(c))
          .toList();
    }
    return BudgetModel(
      id: json['id'] as int?,
      monthlyLimit: double.tryParse(json['monthly_limit'].toString()) ?? 0.0,
      monthYear: json['month_year'] as String,
      userId: json['user_id'] as int,
      totalSpent: (json['total_spent'] as num?)?.toDouble(),
      remaining: (json['remaining'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      categories: categories,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'monthly_limit': monthlyLimit,
        'month_year': monthYear,
      };

  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'monthly_limit': monthlyLimit,
        'month_year': monthYear,
        'user_id': userId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced': 0,
      };

  factory BudgetModel.fromDb(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      monthlyLimit: (map['monthly_limit'] as num).toDouble(),
      monthYear: map['month_year'] as String,
      userId: map['user_id'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }
}

class BudgetCategoryModel extends BudgetCategory {
  const BudgetCategoryModel({
    super.id,
    required super.budgetId,
    required super.categoryId,
    required super.limitAmount,
    super.spent,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
  });

  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryModel(
      id: json['id'] as int?,
      budgetId: json['budget_id'] as int,
      categoryId: json['category_id'] as int,
      limitAmount: (json['limit_amount'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble(),
      categoryName: json['category']?['name'] as String?,
      categoryIcon: json['category']?['icon'] as String?,
      categoryColor: json['category']?['color'] as String?,
    );
  }
}
