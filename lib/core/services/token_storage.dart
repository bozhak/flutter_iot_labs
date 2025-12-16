// core/services/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';

  final FlutterSecureStorage _storage;

  TokenStorage() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Зберегти токен
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Отримати токен
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Видалити токен
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Перевірити чи є токен
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Зберегти email користувача
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// Отримати email користувача
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Видалити email користувача
  Future<void> deleteUserEmail() async {
    await _storage.delete(key: _userEmailKey);
  }

  /// Очистити всі дані
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}