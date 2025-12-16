// data/repositories/local_profile_repository.dart

import '../../core/abstractions/profile_repository.dart';
import '../../core/abstractions/auth_repository.dart';
import '../../core/abstractions/user_repository.dart';
import '../../core/models/user_model.dart';

class LocalProfileRepository implements ProfileRepository {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LocalProfileRepository({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  @override
  Future<UserModel?> getCurrentProfile() async {
    final email = await _authRepository.getCurrentUserEmail();
    if (email == null) return null;

    return await _userRepository.getUser(email);
  }

  @override
  Future<bool> updateProfile({
    String? name,
    String? password,
  }) async {
    final currentUser = await getCurrentProfile();
    if (currentUser == null) return false;

    final updatedUser = currentUser.copyWith(
      name: name ?? currentUser.name,
      password: password ?? currentUser.password,
    );

    return await _userRepository.updateUser(updatedUser);
  }

  @override
  Future<bool> deleteProfile() async {
    final email = await _authRepository.getCurrentUserEmail();
    if (email == null) return false;

    final deleted = await _userRepository.deleteUser(email);
    if (deleted) {
      await _authRepository.logout();
    }

    return deleted;
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final currentUser = await getCurrentProfile();
    if (currentUser == null) return false;

    // Перевірка старого пароля
    if (currentUser.password != oldPassword) {
      return false;
    }

    // Оновлення пароля
    final updatedUser = currentUser.copyWith(password: newPassword);
    return await _userRepository.updateUser(updatedUser);
  }
}