// features/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../data/repositories/local_auth_repository.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authRepository = LocalAuthRepository();
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    setState(() => _isLoading = true);

    final email = await _authRepository.getCurrentUserEmail();
    setState(() {
      _userEmail = email;
      _isLoading = false;
    });

    if (email == null && mounted) {
      _navigateToLogin();
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
    ).then((_) => _loadUserEmail());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Головна'),
        actions: [
          if (_userEmail != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text(
                  _userEmail!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Вийти',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home,
                size: 120,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                'Вітаємо!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_userEmail != null)
                Text(
                  _userEmail!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 48),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: const Text('Мій профіль'),
                      subtitle: const Text('Переглянути та редагувати профіль'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _navigateToProfile,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.blue),
                      title: const Text('Налаштування'),
                      subtitle: const Text('Налаштування додатку'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Функція в розробці'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info, color: Colors.blue),
                      title: const Text('Про додаток'),
                      subtitle: const Text('Версія 1.0.0'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Auth App',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2025 Лабораторна робота №3',
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Додаток створений для демонстрації роботи '
                                  'з локальним сховищем та автентифікацією користувачів.',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}