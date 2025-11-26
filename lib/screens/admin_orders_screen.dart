import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/app_order.dart';
import '../models/order_status.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление заказами'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<AppOrder>>(
        stream: AdminService.getAllOrdersStream(),
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
                  const Text('Ошибка загрузки заказов'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(AppOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок заказа
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заказ #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<OrderStatus>(
                  value: order.status,
                  onChanged: (newStatus) => _updateOrderStatus(order.id, newStatus!),
                  items: OrderStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: status.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(status.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Информация о заказе
            Text('Клиент: ${order.deliveryAddress.fullName}'),
            Text('Телефон: ${order.deliveryAddress.phone}'),
            Text('Адрес: ${order.deliveryAddress.fullAddress}'),
            const SizedBox(height: 8),
            // Товары
            ...order.items.take(2).map((item) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item.product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(item.product.title),
              subtitle: Text('Размер: ${item.size}, Цвет: ${item.color}'),
              trailing: Text('×${item.quantity}'),
            )),
            if (order.items.length > 2)
              Text('и ещё ${order.items.length - 2} товар(ов)'),
            const SizedBox(height: 8),
            // Трек номер
            if (order.trackingNumber == null)
              ElevatedButton(
                onPressed: () => _addTrackingNumber(order.id),
                child: const Text('Добавить трек номер'),
              )
            else
              Row(
                children: [
                  const Text('Трек номер: '),
                  Text(
                    order.trackingNumber!,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _addTrackingNumber(order.id),
                    icon: const Icon(Icons.edit, size: 16),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // Итог
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.totalItems} товар(ов)'),
                Text(
                  '\$${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await AdminService.updateOrderStatus(orderId, newStatus);
      _showSnackBar('Статус заказа обновлен');
    } catch (e) {
      _showSnackBar('Ошибка обновления: $e', isError: true);
    }
  }

  Future<void> _addTrackingNumber(String orderId) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить трек номер'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введите трек номер',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  await AdminService.updateOrderTracking(orderId, controller.text.trim());
                  Navigator.pop(context);
                  _showSnackBar('Трек номер добавлен');
                } catch (e) {
                  _showSnackBar('Ошибка: $e', isError: true);
                }
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}