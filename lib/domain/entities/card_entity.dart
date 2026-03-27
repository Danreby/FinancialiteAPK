import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final int id;
  final String name;
  final String? brand;
  final String? color;
  final String? logo;

  const CardEntity({
    required this.id,
    required this.name,
    this.brand,
    this.color,
    this.logo,
  });

  @override
  List<Object?> get props => [id, name];
}

class CardUser extends Equatable {
  final int? id;
  final int userId;
  final int cardId;
  final int dueDay;
  final int closingDay;
  final double creditLimit;
  final String? nickname;
  final String? cardName;
  final String? cardBrand;
  final String? cardColor;
  final String? cardLogo;
  final double? currentSpending;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CardUser({
    this.id,
    required this.userId,
    required this.cardId,
    this.dueDay = 10,
    this.closingDay = 3,
    this.creditLimit = 0,
    this.nickname,
    this.cardName,
    this.cardBrand,
    this.cardColor,
    this.cardLogo,
    this.currentSpending,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName => nickname ?? cardName ?? 'Cartão';
  double get availableLimit => creditLimit - (currentSpending ?? 0);
  double get usagePercentage => creditLimit > 0 ? ((currentSpending ?? 0) / creditLimit * 100) : 0;

  @override
  List<Object?> get props => [id, userId, cardId];
}
