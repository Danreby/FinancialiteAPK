import '../../core/utils/json_helpers.dart';
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
      amount: json.toDouble('amount'),
      type: json['type'] as String,
      isRecurring: json.toBool('is_recurring'),
      paymentDayType: json['payment_day_type'] as String?,
      paymentDayValue:
          json['payment_day_value'] as int? ?? json['payment_day'] as int?,
      isActive: json.toBool('is_active'),
      bankUserId: json['bank_user_id'] as int?,
      bankAccountId: json['bank_account_id'] as int?,
      userId: json['user_id'] as int,
      description: json['description'] as String?,
      bankName: json.nestedOr(['bank_user', 'bank', 'name'], 'bank_name'),
      receivedAt: json.dateTime('received_at'),
      createdAt: json.dateTime('created_at'),
      updatedAt: json.dateTime('updated_at'),
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
      amount: map.toDouble('amount'),
      type: map['type'] as String,
      isRecurring: map['is_recurring'] == 1,
      paymentDayType: map['payment_day_type'] as String?,
      paymentDayValue: map['payment_day_value'] as int?,
      isActive: map['is_active'] == 1,
      bankUserId: map['bank_user_id'] as int?,
      bankAccountId: map['bank_account_id'] as int?,
      userId: map['user_id'] as int,
      description: map['description'] as String?,
      receivedAt: map.dateTime('received_at'),
      createdAt: map.dateTime('created_at'),
      updatedAt: map.dateTime('updated_at'),
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
      totalMonthly: (json['total_monthly'] as num? ??
              json['total_monthly_income'] as num? ??
              0)
          .toDouble(),
      activeCount: json['active_count'] as int? ?? 0,
      inactiveCount: json['inactive_count'] as int? ?? 0,
    );
  }
}
