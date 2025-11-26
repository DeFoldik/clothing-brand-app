import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin_users_screen.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import '../services/admin_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await AdminService.getOrderStats();
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Приветствие
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Добро пожаловать, ${authProvider.user?.name ?? 'Администратор'}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Управление магазином',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Статистика
           /* const Text(
              'Статистика',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Заказы',
                  _stats['totalOrders']?.toString() ?? '0',
                  Icons.shopping_cart,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Выручка',
                  '\$${_stats['totalRevenue']?.toStringAsFixed(2) ?? '0'}',
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildStatCard(
                  'Товары',
                  _stats['totalProducts']?.toString() ?? '0',
                  Icons.inventory,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Пользователи',
                  _stats['totalUsers']?.toString() ?? '0',
                  Icons.people,
                  Colors.purple,
                ),
              ],
            ),*/

            const SizedBox(height: 24),

            // Быстрые действия
            const Text(
              'Управление',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  'Пользователи',
                  Icons.people,
                  Colors.blue,
                      () => _navigateToUsers(),
                ),
                _buildActionCard(
                  'Товары',
                  Icons.shopping_bag,
                  Colors.green,
                      () => _navigateToProducts(),
                ),
                _buildActionCard(
                  'Заказы',
                  Icons.list_alt,
                  Colors.orange,
                      () => _navigateToOrders(),
                ),
                _buildActionCard(
                  'Ожидают обработки',
                  Icons.pending_actions,
                  Colors.red,
                      () => _navigateToOrders(),
                  badge: _stats['pendingOrders']?.toString() ?? '0',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Дополнительные инструменты
           /* const Text(
              'Инструменты',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.blue),
                      title: const Text('Обновить статистику'),
                      trailing: IconButton(
                        onPressed: _loadStats,
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.grey),
                      title: const Text('Настройки магазина'),
                      onTap: () {
                        // TODO: Переход к настройкам магазина
                      },
                    ),
                  ],
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap, {String? badge}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 32, color: color),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (badge != null && badge != '0')
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
    );
  }

  void _navigateToProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
    );
  }

  void _navigateToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
    );
  }
}