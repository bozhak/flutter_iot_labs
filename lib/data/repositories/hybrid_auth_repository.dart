// data/repositories/hybrid_auth_repository.dart

import '../../core/abstractions/auth_repository.dart';
import '../../core/services/connectivity_service.dart';
import 'local_auth_repository.dart';
import 'remote_auth_repository.dart';

class HybridAuthRepository implements AuthRepository {
  final RemoteAuthRepository _remoteRepository;
  final LocalAuthRepository _localRepository;
  final ConnectivityService _connectivityService;

  HybridAuthRepository({
    RemoteAuthRepository? remoteRepository,
    LocalAuthRepository? localRepository,
    ConnectivityService? connectivityService,
  })  : _remoteRepository = remoteRepository ?? RemoteAuthRepository(),
        _localRepository = localRepository ?? LocalAuthRepository(),
        _connectivityService = connectivityService ?? ConnectivityService();

  @override
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final hasInternet = await _connectivityService.checkConnection();

    if (hasInternet) {
      // Спробувати зареєструвати через API
      final remoteSuccess = await _remoteRepository.register(
        email: email,
        password: password,
        name: name,
      );

      if (remoteSuccess) {
        // Також зберегти локально для кешу
        await _localRepository.register(
          email: email,
          password: password,
          name: name,
        );
        return true;
      }
      return false;
    } else {
      // Без інтернету - тільки локально
      return await _localRepository.register(
        email: email,
        password: password,
        name: name,
      );
    }
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final hasInternet = await _connectivityService.checkConnection();

    if (hasInternet) {
      // Спробувати увійти через API
      final remoteSuccess = await _remoteRepository.login(
        email: email,
        password: password,
      );

      if (remoteSuccess) {
        // Також оновити локальний кеш
        await _localRepository.login(
          email: email,
          password: password,
        );
        return true;
      }
      return false;
    } else {
      // Без інтернету - використати локальні дані
      return await _localRepository.login(
        email: email,
        password: password,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _remoteRepository.logout();
    await _localRepository.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    final remoteLoggedIn = await _remoteRepository.isLoggedIn();
    if (remoteLoggedIn) return true;

    return await _localRepository.isLoggedIn();
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    final remoteEmail = await _remoteRepository.getCurrentUserEmail();
    if (remoteEmail != null) return remoteEmail;

    return await _localRepository.getCurrentUserEmail();
  }
}