import 'package:equatable/equatable.dart';

class BankAccount extends Equatable {
  final int? id;
  final int userId;
  final int bankId;
  final String? accountType;
  final double balance;
  final String? nickname;
  final String? bankName;
  final String? bankCode;
  final String? bankColor;
  final String? bankLogo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BankAccount({
    this.id,
    required this.userId,
    required this.bankId,
    this.accountType = 'checking',
    this.balance = 0,
    this.nickname,
    this.bankName,
    this.bankCode,
    this.bankColor,
    this.bankLogo,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName => nickname ?? bankName ?? 'Conta';
  String get accountTypeLabel {
    switch (accountType) {
      case 'checking': return 'Conta Corrente';
      case 'savings': return 'Poupança';
      default: return 'Conta';
    }
  }

  @override
  List<Object?> get props => [id, userId, bankId];
}

class Bank extends Equatable {
  final int id;
  final String name;
  final String? code;
  final String? color;
  final String? logo;

  const Bank({
    required this.id,
    required this.name,
    this.code,
    this.color,
    this.logo,
  });

  @override
  List<Object?> get props => [id, name];
}

class BankTransfer extends Equatable {
  final int? id;
  final int fromBankUserId;
  final int toBankUserId;
  final double amount;
  final String? description;
  final int userId;
  final String? fromBankName;
  final String? toBankName;
  final DateTime? createdAt;

  const BankTransfer({
    this.id,
    required this.fromBankUserId,
    required this.toBankUserId,
    required this.amount,
    this.description,
    required this.userId,
    this.fromBankName,
    this.toBankName,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, fromBankUserId, toBankUserId, amount];
}

class BankStats extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final int accountCount;

  const BankStats({
    required this.totalBalance,
    required this.totalIncome,
    required this.accountCount,
  });

  @override
  List<Object?> get props => [totalBalance, totalIncome, accountCount];
}
