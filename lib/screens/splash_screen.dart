// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _waitForInitialization();
  }

  void _waitForInitialization() async {
    // Ждем пока AuthProvider проинициализируется
    await Future.delayed(const Duration(milliseconds: 100));

    // Подписываемся на изменения AuthProvider
    final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false
    );

    // Ждем завершения инициализации
    while (authProvider.isInitializing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Переходим на главный экран
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Image.asset('assets/images/splash_logo.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}