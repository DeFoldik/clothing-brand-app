// screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_isLogin) {
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } else {
      await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
    }

    if (authProvider.error != null) {
      final errorMessage = authProvider.error!;
      final isAuthError = errorMessage.contains('логин') ||
          errorMessage.contains('пароль') ||
          errorMessage.contains('email') ||
          errorMessage.contains('пользователь') ||
          errorMessage.contains('сеть');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Вход' : 'Регистрация'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 🎯 ЛОГОТИП
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 40, top: 20),
              child: Image.asset(
                'assets/images/registration_logo1.png',
                fit: BoxFit.contain,
              ),
            ),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // 🎯 ПОЛЯ ДЛЯ РЕГИСТРАЦИИ (только при регистрации)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'ФИО',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите ФИО';
                        }
                        if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s\-]+$').hasMatch(value)) {
                          return 'ФИО может содержать только буквы, пробелы и дефисы';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Номер телефона',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Введите номер телефона';
                        }
                        if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
                          return 'Введите корректный номер';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 🎯 EMAIL
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Введите корректный email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🎯 ПАРОЛЬ
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите пароль';
                      }
                      if (value.length < 6) {
                        return 'Пароль должен быть не менее 6 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🎯 ПОДТВЕРЖДЕНИЕ ПАРОЛЯ (только при регистрации)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Подтверждение пароля',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Пароли не совпадают';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 🎯 КНОПКА ВХОДА/РЕГИСТРАЦИИ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🎯 ПЕРЕКЛЮЧЕНИЕ РЕЖИМА
                  TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      _isLogin
                          ? 'Нет аккаунта? Зарегистрируйтесь'
                          : 'Уже есть аккаунт? Войдите',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}