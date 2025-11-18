// screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/cart_service.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  double _totalPrice = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final cart = await CartService.getCartItems();
      final total = await CartService.getTotalPrice();

      setState(() {
        _cartItems = cart;
        _totalPrice = total;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cart: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateQuantity(CartItem item, int newQuantity) async {
    await CartService.updateQuantity(
        item.productId,
        item.size,
        item.color,
        newQuantity
    );
    _loadCart(); // Перезагружаем корзину
  }

  void _removeItem(CartItem item) async {
    await CartService.removeFromCart(item.productId, item.size, item.color);
    _loadCart(); // Перезагружаем корзину
  }

  void _buyItem(CartItem item) {
    // Логика покупки одного товара
    _showOrderDialog([item]);
  }

  void _buyAll() {
    // Логика покупки всей корзины
    if (_cartItems.isNotEmpty) {
      _showOrderDialog(_cartItems);
    }
  }

  void _showOrderDialog(List<CartItem> items) {
    final total = items.fold(0.0, (sum, item) => sum + item.totalPrice);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Оформление заказа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Товаров: ${items.length}'),
            Text('Общая сумма: \$${total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Заказ успешно оформлен!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Здесь можно добавить логику очистки корзины после покупки
              // CartService.clearCart();
              // _loadCart();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context);
    final isLoggedIn = authProvider?.isLoggedIn ?? false;

    // 🎯 Для незарегистрированных пользователей
    if (!isLoggedIn) {
      return _buildGuestScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              onPressed: _loadCart,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _cartItems.isEmpty
          ? _buildEmptyCartScreen()
          : _buildCartWithItems(),
      bottomNavigationBar: _cartItems.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  // 🎯 Экран для гостей
  Widget _buildGuestScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Корзина доступна только\nзарегистрированным пользователям',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Войдите или зарегистрируйтесь,\nчтобы добавлять товары в корзину',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Войти или зарегистрироваться',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
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

  // 🎯 Корзина с товарами
  Widget _buildCartWithItems() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return _buildCartItem(item);
      },
    );
  }

  // 🎯 Виджет товара в корзине
  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 ИЗОБРАЖЕНИЕ ТОВАРА
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(item.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 🎯 ИНФОРМАЦИЯ О ТОВАРЕ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.length > 40
                        ? '${item.title.substring(0, 40)}...'
                        : item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),

                  // ЦЕНА
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // РАЗМЕР И ЦВЕТ
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Размер: ${item.size}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Цвет: ${item.color}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 🎯 УПРАВЛЕНИЕ КОЛИЧЕСТВОМ И КНОПКИ
                  Row(
                    children: [
                      // СЧЕТЧИК КОЛИЧЕСТВА
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: item.quantity > 1
                                  ? () => _updateQuantity(item, item.quantity - 1)
                                  : null,
                              icon: const Icon(Icons.remove, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                item.quantity.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: item.quantity < item.maxQuantity
                                  ? () => _updateQuantity(item, item.quantity + 1)
                                  : null,
                              icon: const Icon(Icons.add, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // КНОПКА КУПИТЬ
                      OutlinedButton(
                        onPressed: () => _buyItem(item),
                        child: const Text('Купить'),
                      ),
                      const SizedBox(width: 8),

                      // КНОПКА УДАЛИТЬ
                      IconButton(
                        onPressed: () => _removeItem(item),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 НИЖНЯЯ ПАНЕЛЬ С ОБЩЕЙ СУММОЙ
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Общая сумма',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                '\$$_totalPrice',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _buyAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Купить всё',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyCartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'Корзина пуста',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Добавляйте товары из каталога',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}