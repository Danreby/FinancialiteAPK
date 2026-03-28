import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    required super.title,
    required super.amount,
    required super.type,
    super.status,
    super.date,
    super.description,
    super.isRecurring,
    super.installments,
    required super.userId,
    super.categoryId,
    super.cardUserId,
    super.bankUserId,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
    super.cardName,
    super.bankName,
    super.parcelas,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    List<TransactionParcela>? parcelas;
    if (json['parcelas'] != null) {
      parcelas = (json['parcelas'] as List)
          .map((p) => TransactionParcelaModel.fromJson(p))
          .toList();
    }

    return TransactionModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] as String,
      status: json['status'] as String? ?? 'pending',
      date: json['paid_date'] != null
          ? DateTime.tryParse(json['paid_date'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null),
      description: json['description'] as String?,
      isRecurring: json['is_recurring'] == true || json['is_recurring'] == 1,
      installments: json['total_installments'] as int? ?? json['installments'] as int? ?? 1,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int?,
      cardUserId: json['card_user_id'] as int?,
      bankUserId: json['bank_user_id'] as int?,
      categoryName: json['category']?['name'] as String? ??
          json['category_name'] as String?,
      categoryIcon: json['category']?['icon'] as String? ??
          json['category_icon'] as String?,
      categoryColor: json['category']?['color'] as String? ??
          json['category_color'] as String?,
      cardName: json['bank_user']?['card']?['name'] as String? ??
          json['card_name'] as String?,
      bankName: json['bank_user']?['card']?['name'] as String? ??
          json['bank_name'] as String?,
      parcelas: parcelas,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'type': type,
        'status': status,
        'date': date?.toIso8601String().split('T').first,
        'description': description,
        'is_recurring': isRecurring,
        'installments': installments,
        'category_id': categoryId,
        'card_user_id': cardUserId,
        'bank_user_id': bankUserId,
      };

  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'status': status,
        'date': date?.toIso8601String().split('T').first,
        'description': description,
        'is_recurring': isRecurring ? 1 : 0,
        'installments': installments,
        'user_id': userId,
        'category_id': categoryId,
        'card_user_id': cardUserId,
        'bank_user_id': bankUserId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'synced': 0,
      };

  factory TransactionModel.fromDb(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      status: map['status'] as String? ?? 'pending',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString())
          : null,
      description: map['description'] as String?,
      isRecurring: map['is_recurring'] == 1,
      installments: map['installments'] as int? ?? 1,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int?,
      cardUserId: map['card_user_id'] as int?,
      bankUserId: map['bank_user_id'] as int?,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
      categoryColor: map['category_color'] as String?,
      cardName: map['card_name'] as String?,
      bankName: map['bank_name'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      deletedAt: map['deleted_at'] != null
          ? DateTime.tryParse(map['deleted_at'].toString())
          : null,
    );
  }
}

class TransactionParcelaModel extends TransactionParcela {
  const TransactionParcelaModel({
    super.id,
    required super.transactionId,
    required super.parcelaNumber,
    required super.monthKey,
    super.dueDate,
    required super.amount,
    super.status,
    super.paidAt,
  });

  factory TransactionParcelaModel.fromJson(Map<String, dynamic> json) {
    return TransactionParcelaModel(
      id: json['id'] as int?,
      transactionId:
          json['transaction_id'] as int? ?? json['transacao_id'] as int? ?? 0,
      parcelaNumber:
          json['parcela_number'] as int? ?? json['numero'] as int? ?? 1,
      monthKey: json['month_key'] as String? ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      amount: (json['amount'] as num? ?? json['valor'] as num? ?? 0).toDouble(),
      status: json['status'] as String? ?? 'pending',
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'transaction_id': transactionId,
        'parcela_number': parcelaNumber,
        'month_key': monthKey,
        'due_date': dueDate?.toIso8601String().split('T').first,
        'amount': amount,
        'status': status,
        'paid_at': paidAt?.toIso8601String(),
        'synced': 0,
      };
}
