// features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../data/repositories/hybrid_auth_repository.dart';
import '../../data/repositories/hybrid_profile_repository.dart';
import '../../data/repositories/remote_profile_repository.dart';
import '../../data/repositories/local_profile_repository.dart';
import '../../data/repositories/local_user_repository.dart';
import '../../core/services/mqtt_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/models/server_status_model.dart';
import '../../core/models/user_model.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../mqtt/mqtt_monitor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authRepository = HybridAuthRepository();
  late final _profileRepository = HybridProfileRepository(
    remoteRepository: RemoteProfileRepository(
      authRepository: _authRepository,
    ),
    localRepository: LocalProfileRepository(
      authRepository: _authRepository,
      userRepository: LocalUserRepository(),
    ),
    userRepository: LocalUserRepository(),
  );
  final _mqttService = MqttService();
  final _connectivityService = ConnectivityService();

  bool _hasInternet = true;
  bool _isMqttConnected = false;
  ServerStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkConnectivity();
    _startMonitoring();
    if (_hasInternet) {
      await _connectMqtt();
    }
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await _connectivityService.checkConnection();
    setState(() => _hasInternet = hasConnection);
  }

  void _startMonitoring() {
    _connectivityService.connectionStream.listen((hasConnection) {
      if (mounted) {
        setState(() => _hasInternet = hasConnection);

        if (!hasConnection) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ З\'єднання з Інтернетом втрачено'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          _mqttService.disconnect();
          setState(() => _isMqttConnected = false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ З\'єднання з Інтернетом відновлено'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          _connectMqtt();
        }
      }
    });

    _mqttService.connectionStream.listen((state) {
      if (mounted) {
        setState(() =>
        _isMqttConnected = state == MqttConnectionState.connected);
      }
    });

    _mqttService.statusStream.listen((status) {
      if (mounted) {
        setState(() => _lastStatus = status);
      }
    });
  }

  Future<void> _connectMqtt() async {
    final success = await _mqttService.connect();
    if (mounted) {
      setState(() => _isMqttConnected = success);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Вийти?'),
            content: const Text('Ви впевнені, що хочете вийти з акаунту?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Скасувати'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Вийти'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      _mqttService.disconnect();
      await _authRepository.logout();
      if (mounted) _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((_) => setState(() {})); // Оновити після повернення
  }

  void _navigateToMqttMonitor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MqttMonitorScreen(mqttService: _mqttService),
      ),
    );
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Dashboard'),
        actions: [
          _buildMqttIndicator(),
          _buildWifiIndicator(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Вийти',
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _profileRepository.getCurrentProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWelcomeCard(user?.email),
                const SizedBox(height: 16),
                if (_lastStatus != null) _buildServerStatusCard(),
                const SizedBox(height: 16),
                _buildMenuCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMqttIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isMqttConnected
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud,
                size: 16,
                color: _isMqttConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                _isMqttConnected ? 'MQTT' : 'OFF',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _isMqttConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWifiIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: Icon(
          _hasInternet ? Icons.wifi : Icons.wifi_off,
          color: _hasInternet ? Colors.white : Colors.red,
        ),
      ),
    );
  }

// Helper методи для HomeScreen (додати в клас _HomeScreenState)

  Widget _buildWelcomeCard(String? email) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.person, size: 60, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              'Вітаємо!',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (email != null) ...[
              const SizedBox(height: 4),
              Text(
                email,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (!_hasInternet) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📡 Офлайн режим',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerStatusCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🖥️ Server Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _lastStatus!.online ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _lastStatus!.online ? 'ONLINE' : 'OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildQuickStat('CPU', _lastStatus!.cpu, Colors.blue),
            const SizedBox(height: 8),
            _buildQuickStat('RAM', _lastStatus!.ram, Colors.purple),
            const SizedBox(height: 8),
            _buildQuickStat('Disk', _lastStatus!.disk, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            '${value.toStringAsFixed(1)}%',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.monitor_heart, color: Colors.blue),
            title: const Text('MQTT Monitor'),
            subtitle: const Text('Детальний моніторинг сервера'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _navigateToMqttMonitor,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Мій профіль'),
            subtitle: const Text('Переглянути та редагувати профіль'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _navigateToProfile,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Про додаток'),
            subtitle: const Text('IoT Flutter Lab #5'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'IoT MQTT Monitor',
                applicationVersion: '2.0.0',
                applicationLegalese: '© 2025 Лабораторна робота №5',
                children: const [
                  SizedBox(height: 16),
                  Text(
                    'Додаток для моніторингу IoT-пристроїв через MQTT протокол '
                        'з підтримкою REST API автентифікації та офлайн режиму.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
// Решта методів в наступній частині...