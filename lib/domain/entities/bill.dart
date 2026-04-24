import 'package:equatable/equatable.dart';

class Bill extends Equatable {
  final int? id;
  final String title;
  final double amount;
  final int dueDay;
  final String recurrenceType;
  final bool isActive;
  final int? categoryId;
  final int userId;
  final String? description;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final BillPayment? lastPayment;
  final bool isPaidThisPeriod;
  final DateTime? nextDueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Bill({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDay,
    this.recurrenceType = 'monthly',
    this.isActive = true,
    this.categoryId,
    required this.userId,
    this.description,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.lastPayment,
    this.isPaidThisPeriod = false,
    this.nextDueDate,
    this.createdAt,
    this.updatedAt,
  });

  bool get isMonthly => recurrenceType == 'monthly';
  bool get isYearly => recurrenceType == 'yearly';

  @override
  List<Object?> get props => [id, title, amount, userId];
}

class BillPayment extends Equatable {
  final int? id;
  final int billId;
  final double amount;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String status;

  const BillPayment({
    this.id,
    required this.billId,
    required this.amount,
    this.dueDate,
    this.paidDate,
    this.status = 'pending',
  });

  bool get isPaid => status == 'paid';

  @override
  List<Object?> get props => [id, billId];
}
