// core/models/user_model.dart

class UserModel {
  final String email;
  final String name;
  final String password;
  final DateTime createdAt;

  const UserModel({
    required this.email,
    required this.name,
    required this.password,
    required this.createdAt,
  });

  /// Конвертація в JSON для збереження
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Створення з JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Копіювання з можливістю зміни полів
  UserModel copyWith({
    String? email,
    String? name,
    String? password,
    DateTime? createdAt,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}