// screens/debug_auth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController(text: 'Тестовый Пользователь');
  final _phoneController = TextEditingController(text: '+79998887766');
  final _confirmPasswordController = TextEditingController(text: 'password123');

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Тест Регистрации')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //  ТЕСТОВАЯ ФОРМА
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Тестовая регистрация',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    _buildTestField('Email', _emailController),
                    _buildTestField('Пароль', _passwordController, obscure: true),
                    _buildTestField('Имя', _nameController),
                    _buildTestField('Телефон', _phoneController),
                    _buildTestField('Подтверждение пароля', _confirmPasswordController, obscure: true),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _testRegistration,
                        child: const Text('Тест регистрации'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            //  БЫСТРЫЕ ТЕСТЫ
            const Text(
              'Быстрые тесты:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildQuickTestButton(
              'Обычный пользователь',
              email: 'user@gmail.com',
              name: 'Иван Иванов',
            ),
            _buildQuickTestButton(
              'Администратор',
              email: 'admin@tommysinny.ru',
              name: 'Админ Админов',
            ),

            const SizedBox(height: 20),

            //  СТАТУС
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Статус:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Загрузка: ${authProvider.isLoading}'),
                    Text('Ошибка: ${authProvider.error ?? "Нет"}'),
                    Text('Пользователь: ${authProvider.user?.email ?? "Нет"}'),
                    Text('Роль: ${authProvider.user?.role ?? "Нет"}'),
                    Text('Админ: ${authProvider.isAdmin}'),
                  ],
                ),
              ),
            ),

            //  ДЕЙСТВИЯ
            if (authProvider.isLoggedIn) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => authProvider.logout(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Выйти'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestField(String label, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildQuickTestButton(String text, {required String email, required String name}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () => _quickTest(email, name),
        child: Text(text),
      ),
    );
  }

  void _testRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('🧪 ТЕСТ РЕГИСТРАЦИИ ЗАПУЩЕН');

    await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      phone: _phoneController.text,
    );

    _showResultDialog('Ручной тест', authProvider);
  }

  void _quickTest(String email, String name) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    print('⚡ БЫСТРЫЙ ТЕСТ: $email');

    await authProvider.register(
      email: email,
      password: 'test123',
      name: name,
      phone: '+79998887766',
    );

    _showResultDialog('Быстрый тест: $email', authProvider);
  }

  void _showResultDialog(String testType, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Результат: $testType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Статус: ${authProvider.isLoggedIn ? '✅ УСПЕХ' : '❌ ОШИБКА'}'),
            if (authProvider.isLoggedIn) ...[
              Text('Email: ${authProvider.user?.email}'),
              Text('Имя: ${authProvider.user?.name}'),
              Text('Роль: ${authProvider.user?.role}'),
              Text('Админ: ${authProvider.isAdmin ? 'ДА' : 'НЕТ'}'),
            ],
            if (authProvider.error != null)
              Text('Ошибка: ${authProvider.error}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}