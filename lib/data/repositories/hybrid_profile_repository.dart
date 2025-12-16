// data/repositories/hybrid_profile_repository.dart

import '../../core/abstractions/profile_repository.dart';
import '../../core/abstractions/user_repository.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/models/user_model.dart';
import 'local_profile_repository.dart';
import 'remote_profile_repository.dart';

class HybridProfileRepository implements ProfileRepository {
  final RemoteProfileRepository _remoteRepository;
  final LocalProfileRepository _localRepository;
  final ConnectivityService _connectivityService;
  final UserRepository _userRepository;

  HybridProfileRepository({
    required RemoteProfileRepository remoteRepository,
    required LocalProfileRepository localRepository,
    required UserRepository userRepository,
    ConnectivityService? connectivityService,
  })  : _remoteRepository = remoteRepository,
        _localRepository = localRepository,
        _userRepository = userRepository,
        _connectivityService = connectivityService ?? ConnectivityService();

  @override
  Future<UserModel?> getCurrentProfile() async {
    final hasInternet = await _connectivityService.checkConnection();

    if (hasInternet) {
      try {
        // Спробувати отримати з API
        final remoteProfile = await _remoteRepository.getCurrentProfile();

        if (remoteProfile != null) {
          // Оновити локальний кеш
          await _userRepository.saveUser(remoteProfile);
          return remoteProfile;
        }
      } catch (e) {
        print('Remote profile error: $e');
      }
    }

    // Якщо немає інтернету або помилка - використати кеш
    return await _localRepository.getCurrentProfile();
  }

  @override
  Future<bool> updateProfile({
    String? name,
    String? password,
  }) async {
    final hasInternet = await _connectivityService.checkConnection();

    if (hasInternet) {
      final remoteSuccess = await _remoteRepository.updateProfile(
        name: name,
        password: password,
      );

      if (remoteSuccess) {
        // Оновити також локально
        await _localRepository.updateProfile(
          name: name,
          password: password,
        );
        return true;
      }
      return false;
    } else {
      // Без інтернету - тільки локально
      return await _localRepository.updateProfile(
        name: name,
        password: password,
      );
    }
  }

  @override
  Future<bool> deleteProfile() async {
    final hasInternet = await _connectivityService.checkConnection();

    if (hasInternet) {
      final remoteSuccess = await _remoteRepository.deleteProfile();
      if (remoteSuccess) {
        await _localRepository.deleteProfile();
        return true;
      }
      return false;
    } else {
      return await _localRepository.deleteProfile();
    }
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final hasInternet = await _connectivityService.checkConnection();

    if (hasInternet) {
      final remoteSuccess = await _remoteRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (remoteSuccess) {
        await _localRepository.changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
        return true;
      }
      return false;
    } else {
      return await _localRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    }
  }
}