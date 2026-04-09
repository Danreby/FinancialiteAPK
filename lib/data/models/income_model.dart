import '../../domain/entities/income.dart';

class IncomeModel extends Income {
  const IncomeModel({
    super.id,
    required super.title,
    required super.amount,
    required super.type,
    super.isRecurring,
    super.paymentDayType,
    super.paymentDayValue,
    super.isActive,
    super.bankUserId,
    super.bankAccountId,
    required super.userId,
    super.description,
    super.bankName,
    super.receivedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] as String,
      isRecurring: json['is_recurring'] == true || json['is_recurring'] == 1,
      paymentDayType: json['payment_day_type'] as String?,
      paymentDayValue:
          json['payment_day_value'] as int? ?? json['payment_day'] as int?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      bankUserId: json['bank_user_id'] as int?,
      bankAccountId: json['bank_account_id'] as int?,
      userId: json['user_id'] as int,
      description: json['description'] as String?,
      bankName: json['bank_user']?['bank']?['name'] as String? ??
          json['bank_name'] as String?,
      receivedAt: json['received_at'] != null
          ? DateTime.tryParse(json['received_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'type': type,
        'is_recurring': isRecurring,
        'is_active': isActive,
        'bank_user_id': bankUserId,
        'bank_account_id': bankAccountId,
        'description': description,
        if (isRecurring) 'payment_day_type': paymentDayType ?? 'fixed',
        if (isRecurring) 'payment_day_value': paymentDayValue ?? 1,
        if (!isRecurring)
          'received_at': receivedAt?.toIso8601String().split('T').first,
        if (!isRecurring) 'payment_day_type': 'fixed',
        if (!isRecurring) 'payment_day_value': 1,
      };

  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'is_recurring': isRecurring ? 1 : 0,
        'payment_day_type': paymentDayType,
        'payment_day_value': paymentDayValue,
        'is_active': isActive ? 1 : 0,
        'bank_user_id': bankUserId,
        'bank_account_id': bankAccountId,
        'user_id': userId,
        'description': description,
        'received_at': receivedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced': 0,
      };

  factory IncomeModel.fromDb(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      isRecurring: map['is_recurring'] == 1,
      paymentDayType: map['payment_day_type'] as String?,
      paymentDayValue: map['payment_day_value'] as int?,
      isActive: map['is_active'] == 1,
      bankUserId: map['bank_user_id'] as int?,
      bankAccountId: map['bank_account_id'] as int?,
      userId: map['user_id'] as int,
      description: map['description'] as String?,
      receivedAt: map['received_at'] != null
          ? DateTime.tryParse(map['received_at'].toString())
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }
}

class IncomeSummaryModel extends IncomeSummary {
  const IncomeSummaryModel({
    required super.totalMonthly,
    required super.activeCount,
    required super.inactiveCount,
  });

  factory IncomeSummaryModel.fromJson(Map<String, dynamic> json) {
    return IncomeSummaryModel(
      totalMonthly: (json['total_monthly'] as num? ?? json['total_monthly_income'] as num? ?? 0).toDouble(),
      activeCount: json['active_count'] as int? ?? 0,
      inactiveCount: json['inactive_count'] as int? ?? 0,
    );
  }
}
