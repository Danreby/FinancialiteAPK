import '../../domain/entities/bank_account.dart';

class BankAccountModel extends BankAccount {
  const BankAccountModel({
    super.id,
    required super.userId,
    required super.bankId,
    super.accountType,
    super.balance,
    super.nickname,
    super.bankName,
    super.bankCode,
    super.bankColor,
    super.bankLogo,
    super.createdAt,
    super.updatedAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      bankId: json['bank_id'] as int,
      accountType: json['account_type'] as String? ?? 'checking',
      balance: double.tryParse((json['balance'] ?? 0).toString()) ?? 0.0,
      nickname: json['nickname'] as String?,
      bankName:
          json['bank']?['name'] as String? ?? json['bank_name'] as String?,
      bankCode:
          json['bank']?['code'] as String? ?? json['bank_code'] as String?,
      bankColor:
          json['bank']?['color'] as String? ?? json['bank_color'] as String?,
      bankLogo:
          json['bank']?['logo'] as String? ?? json['bank_logo'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'bank_id': bankId,
        'account_type': accountType,
        'balance': balance,
        'nickname': nickname,
      };

  Map<String, dynamic> toDbMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'bank_id': bankId,
        'account_type': accountType,
        'balance': balance,
        'nickname': nickname,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced': 0,
      };

  factory BankAccountModel.fromDb(Map<String, dynamic> map) {
    return BankAccountModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      bankId: map['bank_id'] as int,
      accountType: map['account_type'] as String?,
      balance: (map['balance'] as num? ?? 0).toDouble(),
      nickname: map['nickname'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }
}

class BankModel extends Bank {
  const BankModel(
      {required super.id,
      required super.name,
      super.code,
      super.color,
      super.logo});

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      color: json['color'] as String?,
      logo: json['logo'] as String?,
    );
  }
}

class BankTransferModel extends BankTransfer {
  const BankTransferModel({
    super.id,
    required super.fromBankUserId,
    required super.toBankUserId,
    required super.amount,
    super.description,
    required super.userId,
    super.fromBankName,
    super.toBankName,
    super.createdAt,
  });

  factory BankTransferModel.fromJson(Map<String, dynamic> json) {
    return BankTransferModel(
      id: json['id'] as int?,
      fromBankUserId: json['from_bank_user_id'] as int,
      toBankUserId: json['to_bank_user_id'] as int,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      description: json['description'] as String?,
      userId: json['user_id'] as int,
      fromBankName: json['from_account']?['bank']?['name'] as String?,
      toBankName: json['to_account']?['bank']?['name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'from_bank_user_id': fromBankUserId,
        'to_bank_user_id': toBankUserId,
        'amount': amount,
        'description': description,
      };
}

class BankStatsModel extends BankStats {
  const BankStatsModel(
      {required super.totalBalance,
      required super.totalIncome,
      required super.accountCount});

  factory BankStatsModel.fromJson(Map<String, dynamic> json) {
    return BankStatsModel(
      totalBalance:
          double.tryParse((json['total_balance'] ?? 0).toString()) ?? 0.0,
      totalIncome:
          double.tryParse((json['total_income'] ?? 0).toString()) ?? 0.0,
      accountCount: json['account_count'] as int? ?? 0,
    );
  }
}
