// data/repositories/remote_auth_repository.dart

import 'package:dio/dio.dart';
import '../../core/abstractions/auth_repository.dart';
import '../../core/services/api_service.dart';
import '../../core/services/token_storage.dart';
import '../../core/models/api_response_models.dart';

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
      final response = await _apiService.register({
        'email': email,
        'password': password,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final registerResponse = RegisterResponse.fromJson(response.data);
        await _tokenStorage.saveToken(registerResponse.token);
        await _tokenStorage.saveUserEmail(registerResponse.user.email);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Register error: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login({
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await _tokenStorage.saveToken(loginResponse.token);
        await _tokenStorage.saveUserEmail(loginResponse.user.email);
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