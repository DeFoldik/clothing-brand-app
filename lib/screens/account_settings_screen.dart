import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as my_auth;
import '../services/account_service.dart';
import '../models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
    }
  }

  // Обновить имя
  void _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Введите имя');
      return;
    }

    final password = await _showPasswordDialog('Подтвердите пароль для изменения имени');
    if (password == null) return;

    await _performOperation(
      operation: () => AccountService.updateName(_nameController.text.trim(), password),
      successMessage: 'Имя успешно обновлено',
    );
  }

  // Обновить email
  void _updateEmail() async {
    final newEmail = _emailController.text.trim();
    if (newEmail.isEmpty || !newEmail.contains('@')) {
      _showError('Введите корректный email');
      return;
    }

    final password = await _showPasswordDialog('Подтвердите пароль для изменения email');
    if (password == null) return;

    await _performOperation(
      operation: () => AccountService.updateEmail(newEmail, password),
      successMessage: 'Email успешно обновлен. Проверьте почту для подтверждения',
    );
  }

  // Обновить телефон
  void _updatePhone() async {
    final newPhone = _phoneController.text.trim();
    if (newPhone.isEmpty) {
      _showError('Введите номер телефона');
      return;
    }

    final password = await _showPasswordDialog('Подтвердите пароль для изменения телефона');
    if (password == null) return;

    await _performOperation(
      operation: () => AccountService.updatePhone(newPhone, password),
      successMessage: 'Телефон успешно обновлен',
    );
  }

  // Сменить пароль
  void _updatePassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.length < 6) {
      _showError('Пароль должен содержать не менее 6 символов');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Пароли не совпадают');
      return;
    }

    final currentPassword = await _showPasswordDialog('Введите текущий пароль');
    if (currentPassword == null) return;

    await _performOperation(
      operation: () => AccountService.updatePassword(currentPassword, newPassword),
      successMessage: 'Пароль успешно изменен',
      onSuccess: () {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      },
    );
  }

  // 🎯 ДИАЛОГ ВВОДА ПАРОЛЯ С ОБРАБОТКОЙ ОШИБОК И ГЛАЗИКОМ
  Future<String?> _showPasswordDialog(String message) async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    String? errorText;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Подтверждение пароля'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    border: const OutlineInputBorder(),
                    errorText: errorText,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    if (errorText != null) {
                      setState(() {
                        errorText = null;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  final password = passwordController.text.trim();
                  if (password.isEmpty) {
                    setState(() {
                      errorText = 'Введите пароль';
                    });
                    return;
                  }
                  Navigator.pop(context, password);
                },
                child: const Text('Подтвердить'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Удалить аккаунт
  void _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление аккаунта'),
        content: const Text(
          'Вы уверены, что хотите удалить аккаунт? '
              'Это действие невозможно отменить. '
              'Все ваши данные будут безвозвратно удалены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final password = await _showPasswordDialog('Введите пароль для подтверждения удаления аккаунта');
    if (password == null) return;

    await _performOperation(
      operation: () => AccountService.deleteAccount(password),
      successMessage: 'Аккаунт успешно удален',
      isDestructive: true,
    );
  }

  Future<void> _performOperation({
    required Future<void> Function() operation,
    required String successMessage,
    Function()? onSuccess,
    bool isDestructive = false,
  }) async {
    setState(() {
      _isLoading = true;
      _currentError = null;
    });

    try {
      await operation();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        if (isDestructive) {
          // Если это удаление аккаунта - выходим из приложения
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } else {
          // Обновляем данные в провайдере без выхода
          final authProvider = Provider.of<my_auth.AuthProvider>(context, listen: false);
          await _refreshUserData(authProvider);

          onSuccess?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        // 🎯 УПРОЩЕННАЯ ОБРАБОТКА ОШИБОК - ВСЕ ОШИБКИ ПАРОЛЯ ПОКАЗЫВАЕМ КАК "НЕВЕРНЫЙ ПАРОЛЬ"
        String errorMessage = 'Неверный пароль. Пожалуйста, проверьте введенные данные.';

        // Только для сетевых ошибок показываем другой текст
        if (e.toString().contains('network-error') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('network-request-failed') ||
            e.toString().contains('I/0 error during system call') ||
            e.toString().contains('Connection reset by peer')) {
          errorMessage = 'Ошибка сети. Проверьте подключение к интернету.';
        }


        _showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUserData(my_auth.AuthProvider authProvider) async {
    try {
      // Вызываем метод обновления в провайдере
      await authProvider.refreshUserData();

      // Также обновляем локальные контроллеры для надежности
      final user = authProvider.user;
      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.name ?? '';
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
        });
      }
    } catch (e) {
      print('Ошибка обновления данных: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearError() {
    setState(() {
      _currentError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<my_auth.AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки аккаунта'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Отображение ошибки
            if (_currentError != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      onPressed: _clearError,
                    ),
                  ],
                ),
              ),
            ],

            // Информация о пользователе
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Пользователь',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(user?.email ?? ''),
                    const SizedBox(height: 8),
                    if (user?.isAdmin == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'АДМИНИСТРАТОР',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Изменение имени
            _buildSettingSection(
              title: 'Имя',
              controller: _nameController,
              hintText: 'Введите ваше имя',
              onSave: _updateName,
            ),

            const SizedBox(height: 16),

            // Изменение email
            _buildSettingSection(
              title: 'Email',
              controller: _emailController,
              hintText: 'Введите ваш email',
              onSave: _updateEmail,
            ),

            const SizedBox(height: 16),

            // Изменение телефона
            _buildSettingSection(
              title: 'Телефон',
              controller: _phoneController,
              hintText: 'Введите ваш телефон',
              onSave: _updatePhone,
            ),

            const SizedBox(height: 24),

            // Смена пароля
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Смена пароля',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Новый пароль',
                        border: OutlineInputBorder(),
                        hintText: 'Минимум 6 символов',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Подтвердите пароль',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updatePassword,
                        child: const Text('Сменить пароль'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Удаление аккаунта
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Удаление аккаунта',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'После удаления аккаунта все ваши данные будут безвозвратно утеряны. '
                          'Это действие нельзя отменить.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _deleteAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Удалить аккаунт'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onSave,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}