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

  // Auth endpoints
  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/auth/register', data: data);
  }

  Future<Response> login(Map<String, dynamic> data) async {
    return await _dio.post('/auth/login', data: data);
  }

  Future<Response> getCurrentUser() async {
    return await _dio.get('/auth/me');
  }

  // Profile endpoints
  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.put('/profile', data: data);
  }

  Future<Response> deleteProfile() async {
    return await _dio.delete('/profile');
  }

  Future<Response> changePassword(Map<String, dynamic> data) async {
    return await _dio.post('/profile/change-password', data: data);
  }

  // User endpoints
  Future<Response> getUser(String email) async {
    return await _dio.get('/users', queryParameters: {'email': email});
  }
}