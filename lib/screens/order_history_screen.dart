// screens/order_history_screen.dart
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История заказов')),
      body: const Center(
        child: Text('История заказов - скоро будет!'),
      ),
    );
  }
}

