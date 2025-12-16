// features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/validators/input_validators.dart';
import '../../data/repositories/hybrid_auth_repository.dart';
import '../../data/repositories/local_user_repository.dart';
import '../../data/repositories/remote_profile_repository.dart';
import '../../data/repositories/local_profile_repository.dart';
import '../../data/repositories/hybrid_profile_repository.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(UserModel user) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await _profileRepository.updateProfile(
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дані успішно оновлено'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Помилка при оновленні даних'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    final success = await _profileRepository.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isChangingPassword = false;
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пароль успішно змінено'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Невірний старий пароль'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Видалити акаунт?'),
            content: const Text(
              'Ви впевнені, що хочете видалити свій акаунт? '
                  'Цю дію неможливо скасувати.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Скасувати'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Видалити'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final success = await _profileRepository.deleteProfile();

    if (!mounted) return;

    if (success) {
      _navigateToLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Помилка при видаленні акаунту'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month
        .toString()
        .padLeft(2, '0')}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        centerTitle: true,
      ),
      body: FutureBuilder<UserModel?>(
        future: _profileRepository.getCurrentProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Помилка: ${snapshot.error}'),
                ],
              ),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return const Center(
              child: Text('Дані користувача не знайдено'),
            );
          }

          _nameController.text = user.name;

          return _buildProfileContent(user);
        },
      ),
    );
  }

  // Продовження в Part 2...
  Widget _buildProfileContent(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(user),
          const SizedBox(height: 16),
          _buildSecurityCard(user),
          const SizedBox(height: 24),
          _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildEmailField(user.email),
              const SizedBox(height: 16),
              _buildCreatedAtField(user.createdAt),
              if (_isEditing) ...[
                const SizedBox(height: 24),
                _buildEditButtons(user),
              ],
            ],
          ),
        ),
      ),
    );
  }

// Додаткові методи для ProfileScreen (додати в клас _ProfileScreenState)

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Основна інформація',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit),
          onPressed: () {
            setState(() => _isEditing = !_isEditing);
          },
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Ім\'я',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      enabled: _isEditing,
      validator: InputValidators.validateName,
    );
  }

  Widget _buildEmailField(String email) {
    return TextFormField(
      initialValue: email,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      enabled: false,
    );
  }

  Widget _buildCreatedAtField(DateTime createdAt) {
    return TextFormField(
      initialValue: _formatDate(createdAt),
      decoration: const InputDecoration(
        labelText: 'Дата реєстрації',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      enabled: false,
    );
  }

  Widget _buildEditButtons(UserModel user) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _isEditing = false),
            child: const Text('Скасувати'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _saveChanges(user),
            child: const Text('Зберегти'),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard(UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Безпека',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (!_isChangingPassword)
                  TextButton.icon(
                    onPressed: () => setState(() => _isChangingPassword = true),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Змінити пароль'),
                  ),
              ],
            ),
            if (_isChangingPassword) ...[
              const SizedBox(height: 16),
              _buildPasswordForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _passwordFormKey,
      child: Column(
        children: [
          _buildPasswordField(
            controller: _oldPasswordController,
            label: 'Старий пароль',
            obscure: _obscureOldPassword,
            onToggle: () =>
                setState(() => _obscureOldPassword = !_obscureOldPassword),
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: _newPasswordController,
            label: 'Новий пароль',
            obscure: _obscureNewPassword,
            onToggle: () =>
                setState(() => _obscureNewPassword = !_obscureNewPassword),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Підтвердіть новий пароль',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons
                        .visibility),
                onPressed: () =>
                    setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) =>
                InputValidators.validateConfirmPassword(
                  value,
                  _newPasswordController.text,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isChangingPassword = false;
                      _oldPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  child: const Text('Скасувати'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Змінити'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      obscureText: obscure,
      validator: InputValidators.validatePassword,
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton.icon(
      onPressed: _deleteAccount,
      icon: const Icon(Icons.delete_forever),
      label: const Text('Видалити акаунт'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
// Решта методів у Part 2...