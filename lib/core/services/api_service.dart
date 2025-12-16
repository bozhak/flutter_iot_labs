// core/services/api_service.dart

import 'package:dio/dio.dart';
import 'token_storage.dart';

class ApiService {
  static const String baseUrl = 'https://69414194686bc3ca81663c51.mockapi.io/';

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiService({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.deleteToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ============= USER ENDPOINTS =============

  /// Створити нового користувача (register)
  Future<Response> createUser(Map<String, dynamic> data) async {
    return await _dio.post('/users', data: data);
  }

  /// Отримати всіх користувачів
  Future<Response> getUsers() async {
    return await _dio.get('/users');
  }

  /// Знайти користувача за email
  Future<Response> getUserByEmail(String email) async {
    // MockAPI підтримує фільтрацію через query params
    return await _dio.get('/users', queryParameters: {'email': email});
  }

  /// Отримати користувача за ID
  Future<Response> getUserById(String id) async {
    return await _dio.get('/users/$id');
  }

  /// Оновити користувача
  Future<Response> updateUser(String id, Map<String, dynamic> data) async {
    return await _dio.put('/users/$id', data: data);
  }

  /// Видалити користувача
  Future<Response> deleteUser(String id) async {
    return await _dio.delete('/users/$id');
  }
}