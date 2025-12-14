// data/repositories/local_auth_repository.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/abstractions/auth_repository.dart';
import '../../core/models/user_model.dart';

class LocalAuthRepository implements AuthRepository {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Перевірка чи користувач вже існує
      final usersJson = prefs.getString(_usersKey);
      final Map<String, dynamic> users = usersJson != null
          ? json.decode(usersJson) as Map<String, dynamic>
          : {};

      if (users.containsKey(email)) {
        return false; // Користувач вже існує
      }

      // Створення нового користувача
      final user = UserModel(
        email: email,
        name: name,
        password: password,
        createdAt: DateTime.now(),
      );

      // Збереження користувача
      users[email] = user.toJson();
      await prefs.setString(_usersKey, json.encode(users));

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Отримання всіх користувачів
      final usersJson = prefs.getString(_usersKey);
      if (usersJson == null) {
        return false;
      }

      final Map<String, dynamic> users =
      json.decode(usersJson) as Map<String, dynamic>;

      // Перевірка чи існує користувач
      if (!users.containsKey(email)) {
        return false;
      }

      // Перевірка пароля
      final userJson = users[email] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);

      if (user.password != password) {
        return false;
      }

      // Збереження поточного користувача
      await prefs.setString(_currentUserKey, email);

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }
}