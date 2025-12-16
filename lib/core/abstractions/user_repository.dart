// core/abstractions/user_repository.dart

import '../models/user_model.dart';

abstract class UserRepository {
  /// Отримання даних користувача
  Future<UserModel?> getUser(String email);

  /// Оновлення даних користувача
  Future<bool> updateUser(UserModel user);

  /// Видалення користувача
  Future<bool> deleteUser(String email);

  /// Збереження користувача
  Future<bool> saveUser(UserModel user);
}