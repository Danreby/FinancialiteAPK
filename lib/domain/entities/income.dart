import 'package:equatable/equatable.dart';

class Income extends Equatable {
  final int? id;
  final String title;
  final double amount;
  final String type;
  final bool isRecurring;
  final String? paymentDayType;
  final int? paymentDayValue;
  final bool isActive;
  final int? bankUserId;
  final int? bankAccountId;
  final int userId;
  final String? description;
  final String? bankName;
  final DateTime? receivedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Income({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.isRecurring = true,
    this.paymentDayType,
    this.paymentDayValue,
    this.isActive = true,
    this.bankUserId,
    this.bankAccountId,
    required this.userId,
    this.description,
    this.bankName,
    this.receivedAt,
    this.createdAt,
    this.updatedAt,
  });

  String get typeLabel {
    switch (type) {
      case 'salary':
        return 'Salário';
      case 'freelance':
        return 'Freelance';
      case 'investment':
        return 'Investimento';
      case 'rental':
        return 'Aluguel';
      case 'benefit':
        return 'Benefício';
      case 'pix':
        return 'Pix';
      default:
        return 'Outro';
    }
  }

  @override
  List<Object?> get props => [id, title, amount, userId];
}

class IncomeSummary extends Equatable {
  final double totalMonthly;
  final int activeCount;
  final int inactiveCount;

  const IncomeSummary({
    required this.totalMonthly,
    required this.activeCount,
    required this.inactiveCount,
  });

  @override
  List<Object?> get props => [totalMonthly, activeCount];
}
