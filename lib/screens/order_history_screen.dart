// screens/order_history_screen.dart
import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/app_order.dart';
import '../widgets/order_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Stream<List<AppOrder>>? _ordersStream;
  String _error = '';

  @override
  void initState() {
    super.initState();
    print(' OrderHistoryScreen инициализирован');
    _loadOrders();
  }

  void _loadOrders() {
    try {
      print('🔍 Загружаем заказы...');
      final user = FirebaseAuth.instance.currentUser;
      print('👤 Пользователь: ${user?.uid}');

      _ordersStream = OrderService.getUserOrders();

      //  ПОДПИСЫВАЕМСЯ ДЛЯ ОТЛАДКИ
      _ordersStream?.first.then((orders) {
        print('✅ Заказы загружены: ${orders.length}');
        for (final order in orders) {
          print('📦 Заказ #${order.id}: ${order.items.length} товаров, статус: ${order.status.displayName}');
        }
      }).catchError((e) {
        print('❌ Ошибка загрузки заказов: $e');
      });

    } catch (e) {
      print('❌ Ошибка в _loadOrders: $e');
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _error.isNotEmpty
          ? _buildErrorScreen()
          : StreamBuilder<List<AppOrder>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }

          if (snapshot.hasError) {
            return _buildErrorScreen();
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return _buildEmptyState();
          }

          return _buildOrdersList(orders);
        },
      ),
    );
  }

  Widget _buildOrdersList(List<AppOrder> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order);
      },
    );
  }

  //  Пустой экран
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'У вас еще нет заказов',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Совершите первую покупку!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  //  Экран загрузки
  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  //  Экран ошибки
  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Ошибка загрузки',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrders,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }
}