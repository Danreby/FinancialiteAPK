import '../../core/utils/json_helpers.dart';
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
      balance: json.toDouble('balance'),
      nickname: json['nickname'] as String?,
      bankName: json.nestedOr(['bank', 'name'], 'bank_name'),
      bankCode: json.nestedOr(['bank', 'code'], 'bank_code'),
      bankColor: json.nestedOr(['bank', 'color'], 'bank_color'),
      bankLogo: json.nestedOr(['bank', 'logo'], 'bank_logo'),
      createdAt: json.dateTime('created_at'),
      updatedAt: json.dateTime('updated_at'),
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
      balance: map.toDouble('balance'),
      nickname: map['nickname'] as String?,
      createdAt: map.dateTime('created_at'),
      updatedAt: map.dateTime('updated_at'),
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
      amount: json.toDouble('amount'),
      description: json['description'] as String?,
      userId: json['user_id'] as int,
      fromBankName: json.nested(['from_account', 'bank', 'name']),
      toBankName: json.nested(['to_account', 'bank', 'name']),
      createdAt: json.dateTime('created_at'),
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
