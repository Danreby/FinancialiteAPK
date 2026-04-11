import '../../core/utils/json_helpers.dart';
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
      targetAmount: json.toDouble('target_amount'),
      currentAmount: json.toDouble('current_amount'),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      deadline: json.dateTime('deadline'),
      isCompleted: json.toBool('is_completed'),
      userId: json['user_id'] as int,
      description: json['description'] as String?,
      createdAt: json.dateTime('created_at'),
      updatedAt: json.dateTime('updated_at'),
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
      targetAmount: map.toDouble('target_amount'),
      currentAmount: map.toDouble('current_amount'),
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      deadline: map.dateTime('deadline'),
      isCompleted: map['is_completed'] == 1,
      userId: map['user_id'] as int,
      description: map['description'] as String?,
      createdAt: map.dateTime('created_at'),
      updatedAt: map.dateTime('updated_at'),
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
