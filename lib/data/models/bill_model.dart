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
      amount: (json['amount'] as num).toDouble(),
      dueDay: json['due_day'] as int,
      recurrenceType: json['recurrence_type'] as String? ?? 'monthly',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      categoryId: json['category_id'] as int?,
      userId: json['user_id'] as int,
      description: json['description'] as String?,
      categoryName: json['category']?['name'] as String?,
      categoryIcon: json['category']?['icon'] as String?,
      categoryColor: json['category']?['color'] as String?,
      lastPayment: lastPayment,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
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
      amount: (map['amount'] as num).toDouble(),
      dueDay: map['due_day'] as int,
      recurrenceType: map['recurrence_type'] as String? ?? 'monthly',
      isActive: map['is_active'] == 1,
      categoryId: map['category_id'] as int?,
      userId: map['user_id'] as int,
      description: map['description'] as String?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
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
      amount: (json['amount'] as num).toDouble(),
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'].toString()) : null,
      paidDate: json['paid_date'] != null ? DateTime.tryParse(json['paid_date'].toString()) : null,
      status: json['status'] as String? ?? 'pending',
    );
  }
}
