// core/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final _connectionController = StreamController<bool>.broadcast();
  StreamSubscription<ConnectivityResult>? _subscription;

  Stream<bool> get connectionStream => _connectionController.stream;

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  void startMonitoring() {
    _subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          final isConnected = _isConnected(result);
          _connectionController.add(isConnected);
        });
  }

  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}
