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
      // Отримати email поточного користувача
      final email = await _authRepository.getCurrentUserEmail();
      if (email == null) return null;

      // Знайти користувача за email
      final response = await _apiService.getUserByEmail(email);

      if (response.statusCode == 200) {
        final users = response.data as List;
        if (users.isEmpty) return null;

        final userData = users.first as Map<String, dynamic>;
        return UserModel.fromJson(userData);
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
      // 1. Отримати поточний профіль
      final currentProfile = await getCurrentProfile();
      if (currentProfile == null) return false;

      // 2. Знайти ID користувача
      final email = currentProfile.email;
      final response = await _apiService.getUserByEmail(email);

      if (response.statusCode != 200) return false;

      final users = response.data as List;
      if (users.isEmpty) return false;

      final userId = (users.first as Map<String, dynamic>)['id'] as String;

      // 3. Підготувати дані для оновлення
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (password != null) updateData['password'] = password;

      // 4. Оновити користувача
      final updateResponse = await _apiService.updateUser(userId, updateData);

      return updateResponse.statusCode == 200;
    } on DioException catch (e) {
      print('Update profile error: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> deleteProfile() async {
    try {
      // 1. Отримати email
      final email = await _authRepository.getCurrentUserEmail();
      if (email == null) return false;

      // 2. Знайти ID користувача
      final response = await _apiService.getUserByEmail(email);

      if (response.statusCode != 200) return false;

      final users = response.data as List;
      if (users.isEmpty) return false;

      final userId = (users.first as Map<String, dynamic>)['id'] as String;

      // 3. Видалити користувача
      final deleteResponse = await _apiService.deleteUser(userId);

      if (deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204) {
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
      // 1. Отримати поточний профіль
      final currentProfile = await getCurrentProfile();
      if (currentProfile == null) return false;

      // 2. Перевірити старий пароль
      if (currentProfile.password != oldPassword) {
        print('Old password is incorrect');
        return false;
      }

      // 3. Оновити пароль
      return await updateProfile(password: newPassword);
    } on DioException catch (e) {
      print('Change password error: ${e.message}');
      return false;
    }
  }
}