// core/abstractions/auth_repository.dart

abstract class AuthRepository {
  /// Реєстрація нового користувача
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  });

  /// Вхід користувача
  Future<bool> login({
    required String email,
    required String password,
  });

  /// Вихід користувача
  Future<void> logout();

  /// Перевірка чи користувач залогінений
  Future<bool> isLoggedIn();

  /// Отримання email поточного користувача
  Future<String?> getCurrentUserEmail();
}