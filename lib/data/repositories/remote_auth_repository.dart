// data/repositories/remote_auth_repository.dart

import 'package:dio/dio.dart';
import '../../core/abstractions/auth_repository.dart';
import '../../core/services/api_service.dart';
import '../../core/services/token_storage.dart';

class RemoteAuthRepository implements AuthRepository {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  RemoteAuthRepository({
    ApiService? apiService,
    TokenStorage? tokenStorage,
  })  : _apiService = apiService ?? ApiService(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Перевірити чи користувач вже існує
      final existingUsers = await _apiService.getUserByEmail(email);

      if (existingUsers.statusCode == 200) {
        final users = existingUsers.data as List;
        if (users.isNotEmpty) {
          print('User already exists with email: $email');
          return false; // Користувач вже існує
        }
      }

      // 2. Створити нового користувача
      final response = await _apiService.createUser({
        'email': email,
        'password': password,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        final userId = userData['id'] as String;

        // 3. Згенерувати "фейковий" токен (MockAPI не підтримує реальні токени)
        final fakeToken = 'mock_token_${userId}_${DateTime.now().millisecondsSinceEpoch}';

        await _tokenStorage.saveToken(fakeToken);
        await _tokenStorage.saveUserEmail(email);

        print('User registered successfully: $email');
        return true;
      }

      return false;
    } on DioException catch (e) {
      print('Register error: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      }
      return false;
    }
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Знайти користувача за email
      final response = await _apiService.getUserByEmail(email);

      if (response.statusCode == 200) {
        final users = response.data as List;

        if (users.isEmpty) {
          print('User not found: $email');
          return false; // Користувача не знайдено
        }

        // 2. Перевірити пароль
        final user = users.first as Map<String, dynamic>;
        final storedPassword = user['password'] as String;

        if (storedPassword != password) {
          print('Invalid password for: $email');
          return false; // Невірний пароль
        }

        // 3. "Увійти" - зберегти фейковий токен
        final userId = user['id'] as String;
        final fakeToken = 'mock_token_${userId}_${DateTime.now().millisecondsSinceEpoch}';

        await _tokenStorage.saveToken(fakeToken);
        await _tokenStorage.saveUserEmail(email);

        print('User logged in successfully: $email');
        return true;
      }

      return false;
    } on DioException catch (e) {
      print('Login error: ${e.message}');
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearAll();
    print('User logged out');
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.hasToken();
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return await _tokenStorage.getUserEmail();
  }
}