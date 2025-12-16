// data/repositories/remote_profile_repository.dart

import 'package:dio/dio.dart';
import '../../core/abstractions/profile_repository.dart';
import '../../core/abstractions/auth_repository.dart';
import '../../core/services/api_service.dart';
import '../../core/models/user_model.dart';

class RemoteProfileRepository implements ProfileRepository {
  final ApiService _apiService;
  final AuthRepository _authRepository;

  RemoteProfileRepository({
    required AuthRepository authRepository,
    ApiService? apiService,
  })  : _authRepository = authRepository,
        _apiService = apiService ?? ApiService();

  @override
  Future<UserModel?> getCurrentProfile() async {
    try {
      final response = await _apiService.getCurrentUser();
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('Get profile error: ${e.message}');
      return null;
    }
  }

  @override
  Future<bool> updateProfile({
    String? name,
    String? password,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (password != null) data['password'] = password;

      final response = await _apiService.updateProfile(data);
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Update profile error: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> deleteProfile() async {
    try {
      final response = await _apiService.deleteProfile();
      if (response.statusCode == 200 || response.statusCode == 204) {
        await _authRepository.logout();
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Delete profile error: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.changePassword({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Change password error: ${e.message}');
      return false;
    }
  }
}