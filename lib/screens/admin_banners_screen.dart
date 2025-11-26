import 'package:flutter/material.dart';

class AdminBannersScreen extends StatelessWidget {
  const AdminBannersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Управление баннерами - скоро будет!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}