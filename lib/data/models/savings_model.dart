import '../../domain/entities/savings_goal.dart';

class SavingsGoalModel extends SavingsGoal {
  const SavingsGoalModel({
    super.id,
    required super.title,
    required super.targetAmount,
    super.currentAmount,
    super.icon,
    super.color,
    super.deadline,
    super.isCompleted,
    required super.userId,
    super.description,
    super.createdAt,
    super.updatedAt,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num? ?? 0).toDouble(),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline'].toString()) : null,
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      userId: json['user_id'] as int,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'target_amount': targetAmount,
    'icon': icon,
    'color': color,
    'deadline': deadline?.toIso8601String().split('T').first,
    'description': description,
  };

  Map<String, dynamic> toDbMap() => {
    if (id != null) 'id': id,
    'title': title,
    'target_amount': targetAmount,
    'current_amount': currentAmount,
    'icon': icon,
    'color': color,
    'deadline': deadline?.toIso8601String().split('T').first,
    'is_completed': isCompleted ? 1 : 0,
    'user_id': userId,
    'description': description,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'synced': 0,
  };

  factory SavingsGoalModel.fromDb(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num? ?? 0).toDouble(),
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      deadline: map['deadline'] != null ? DateTime.tryParse(map['deadline'].toString()) : null,
      isCompleted: map['is_completed'] == 1,
      userId: map['user_id'] as int,
      description: map['description'] as String?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }
}

class SavingsSummaryModel extends SavingsSummary {
  const SavingsSummaryModel({
    required super.totalSaved,
    required super.totalTarget,
    required super.overallProgress,
    required super.completedCount,
    required super.activeCount,
  });

  factory SavingsSummaryModel.fromJson(Map<String, dynamic> json) {
    return SavingsSummaryModel(
      totalSaved: (json['total_saved'] as num? ?? 0).toDouble(),
      totalTarget: (json['total_target'] as num? ?? 0).toDouble(),
      overallProgress: (json['overall_progress'] as num? ?? 0).toDouble(),
      completedCount: json['completed_count'] as int? ?? 0,
      activeCount: json['active_count'] as int? ?? 0,
    );
  }
}
