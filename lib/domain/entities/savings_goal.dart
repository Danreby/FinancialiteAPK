import 'package:equatable/equatable.dart';

class SavingsGoal extends Equatable {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String? icon;
  final String? color;
  final DateTime? deadline;
  final bool isCompleted;
  final int userId;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    this.icon,
    this.color,
    this.deadline,
    this.isCompleted = false,
    required this.userId,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;
  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);
  bool get isReached => currentAmount >= targetAmount;

  @override
  List<Object?> get props => [id, title, targetAmount, userId];
}

class SavingsSummary extends Equatable {
  final double totalSaved;
  final double totalTarget;
  final double overallProgress;
  final int completedCount;
  final int activeCount;

  const SavingsSummary({
    required this.totalSaved,
    required this.totalTarget,
    required this.overallProgress,
    required this.completedCount,
    required this.activeCount,
  });

  @override
  List<Object?> get props => [totalSaved, totalTarget, overallProgress];
}
