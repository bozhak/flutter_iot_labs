// core/abstractions/profile_repository.dart

import '../models/user_model.dart';

abstract class ProfileRepository {
  /// Отримання профілю поточного користувача
  Future<UserModel?> getCurrentProfile();

  /// Оновлення профілю
  Future<bool> updateProfile({
    String? name,
    String? password,
  });

  /// Видалення профілю (акаунту)
  Future<bool> deleteProfile();

  /// Зміна пароля
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}