import '../../domain/entities/card_entity.dart';

class CardEntityModel extends CardEntity {
  const CardEntityModel({required super.id, required super.name, super.brand, super.color, super.logo});

  factory CardEntityModel.fromJson(Map<String, dynamic> json) {
    return CardEntityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      logo: json['logo'] as String?,
    );
  }
}

class CardUserModel extends CardUser {
  const CardUserModel({
    super.id,
    required super.userId,
    required super.cardId,
    super.dueDay,
    super.closingDay,
    super.creditLimit,
    super.nickname,
    super.cardName,
    super.cardBrand,
    super.cardColor,
    super.cardLogo,
    super.currentSpending,
    super.createdAt,
    super.updatedAt,
  });

  factory CardUserModel.fromJson(Map<String, dynamic> json) {
    return CardUserModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      cardId: json['card_id'] as int,
      dueDay: json['due_day'] as int? ?? 10,
      closingDay: json['closing_day'] as int? ?? 3,
      creditLimit: (json['credit_limit'] as num? ?? 0).toDouble(),
      nickname: json['nickname'] as String?,
      cardName: json['card']?['name'] as String? ?? json['card_name'] as String?,
      cardBrand: json['card']?['brand'] as String? ?? json['card_brand'] as String?,
      cardColor: json['card']?['color'] as String? ?? json['card_color'] as String?,
      cardLogo: json['card']?['logo'] as String? ?? json['card_logo'] as String?,
      currentSpending: (json['current_spending'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'card_id': cardId,
    'due_day': dueDay,
    'closing_day': closingDay,
    'credit_limit': creditLimit,
    'nickname': nickname,
  };

  Map<String, dynamic> toDbMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'card_id': cardId,
    'due_day': dueDay,
    'closing_day': closingDay,
    'credit_limit': creditLimit,
    'nickname': nickname,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'synced': 0,
  };
}
