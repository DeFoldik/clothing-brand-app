// screens/admin_panel_screen.dart
import 'package:flutter/material.dart';

class AdminPanelScreen extends StatelessWidget {
  final String initialSection;

  const AdminPanelScreen({super.key, required this.initialSection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Панель администратора')),
      body: const Center(
        child: Text('Панель администратора - скоро будет!'),
      ),
    );
  }
}