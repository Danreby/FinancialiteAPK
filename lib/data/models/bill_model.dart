import '../../core/utils/json_helpers.dart';
import '../../domain/entities/bill.dart';

class BillModel extends Bill {
  const BillModel({
    super.id,
    required super.title,
    required super.amount,
    required super.dueDay,
    super.recurrenceType,
    super.isActive,
    super.categoryId,
    required super.userId,
    super.description,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
    super.lastPayment,
    super.isPaidThisPeriod,
    super.nextDueDate,
    super.createdAt,
    super.updatedAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    BillPayment? lastPayment;
    if (json['last_payment'] != null) {
      lastPayment = BillPaymentModel.fromJson(json['last_payment']);
    }
    return BillModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      amount: json.toDouble('amount'),
      dueDay: json['due_day'] as int,
      recurrenceType: json['recurrence_type'] as String? ?? 'monthly',
      isActive: json.toBool('is_active'),
      categoryId: json['category_id'] as int?,
      userId: json['user_id'] as int,
      description: json['description'] as String?,
      categoryName: json['category']?['name'] as String?,
      categoryIcon: json['category']?['icon'] as String?,
      categoryColor: json['category']?['color'] as String?,
      lastPayment: lastPayment,
      isPaidThisPeriod: json.toBool('is_paid_this_period'),
      nextDueDate: json.dateTime('next_due_date') ?? json.dateTime('due_date'),
      createdAt: json.dateTime('created_at'),
      updatedAt: json.dateTime('updated_at'),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'due_day': dueDay,
        'recurrence_type': recurrenceType,
        'is_active': isActive,
        'category_id': categoryId,
        'description': description,
      };

  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'due_day': dueDay,
        'recurrence_type': recurrenceType,
        'is_active': isActive ? 1 : 0,
        'category_id': categoryId,
        'user_id': userId,
        'description': description,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced': 0,
      };

  factory BillModel.fromDb(Map<String, dynamic> map) {
    return BillModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map.toDouble('amount'),
      dueDay: map['due_day'] as int,
      recurrenceType: map['recurrence_type'] as String? ?? 'monthly',
      isActive: map['is_active'] == 1,
      categoryId: map['category_id'] as int?,
      userId: map['user_id'] as int,
      description: map['description'] as String?,
      isPaidThisPeriod: map['is_paid_this_period'] == 1,
      nextDueDate: map.dateTime('next_due_date'),
      createdAt: map.dateTime('created_at'),
      updatedAt: map.dateTime('updated_at'),
    );
  }
}

class BillPaymentModel extends BillPayment {
  const BillPaymentModel({
    super.id,
    required super.billId,
    required super.amount,
    super.dueDate,
    super.paidDate,
    super.status,
  });

  factory BillPaymentModel.fromJson(Map<String, dynamic> json) {
    return BillPaymentModel(
      id: json['id'] as int?,
      billId: json['bill_id'] as int,
      amount: json.toDouble('amount'),
      dueDate: json.dateTime('due_date'),
      paidDate: json.dateTime('paid_date'),
      status: json['status'] as String? ?? 'pending',
    );
  }
}
