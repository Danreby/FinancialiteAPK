import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
    required super.type,
    super.icon,
    super.color,
    required super.userId,
    super.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      userId: json['user_id'] as int,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'icon': icon,
    'color': color,
  };

  Map<String, dynamic> toDbMap() => {
    if (id != null) 'id': id,
    'name': name,
    'type': type,
    'icon': icon,
    'color': color,
    'user_id': userId,
    'created_at': createdAt?.toIso8601String(),
    'synced': 0,
  };

  factory CategoryModel.fromDb(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: map['type'] as String,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      userId: map['user_id'] as int,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }
}
