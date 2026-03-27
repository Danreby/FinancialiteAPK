import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id;
  final String title;
  final double amount;
  final String type;
  final String status;
  final DateTime? date;
  final String? description;
  final bool isRecurring;
  final int installments;
  final int userId;
  final int? categoryId;
  final int? cardUserId;
  final int? bankUserId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? cardName;
  final String? bankName;
  final List<TransactionParcela>? parcelas;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.status = 'pending',
    this.date,
    this.description,
    this.isRecurring = false,
    this.installments = 1,
    required this.userId,
    this.categoryId,
    this.cardUserId,
    this.bankUserId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.cardName,
    this.bankName,
    this.parcelas,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get hasInstallments => installments > 1;

  @override
  List<Object?> get props => [id, title, amount, type, userId];
}

class TransactionParcela extends Equatable {
  final int? id;
  final int transactionId;
  final int parcelaNumber;
  final String monthKey;
  final DateTime? dueDate;
  final double amount;
  final String status;
  final DateTime? paidAt;

  const TransactionParcela({
    this.id,
    required this.transactionId,
    required this.parcelaNumber,
    required this.monthKey,
    this.dueDate,
    required this.amount,
    this.status = 'pending',
    this.paidAt,
  });

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';

  @override
  List<Object?> get props => [id, transactionId, parcelaNumber];
}
