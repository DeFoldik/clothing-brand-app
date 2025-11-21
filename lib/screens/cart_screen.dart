// screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/cart_service.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';
import '../models/cart_product.dart';
import '../screens/auth_screen.dart';
import '../screens/poduct_detail_screen.dart';
import '../services/checkout_service.dart';
import '../models/app_order.dart';
import '../screens/add_address_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartProduct> _cartItems = [];
  double _totalPrice = 0.0;
  bool _isLoading = true;
  StreamSubscription<List<CartProduct>>? _cartSubscription;

  @override
  void initState() {
    super.initState();
    _setupCartStream();
  }

  void _setupCartStream() {
    if (CartService.isUserLoggedIn) {
      _cartSubscription = CartService.cartStream.listen(
              (cartItems) {
            print('🔄 Получены обновленные данные корзины: ${cartItems.length} товаров');
            _updateCartData(cartItems);
          },
          onError: (error) {
            print('❌ Ошибка в stream корзины: $error');
            _updateCartData([]);
          }
      );
    } else {
      _isLoading = false;
    }
  }

  void _updateCartData(List<CartProduct> cartItems) {
    if (mounted) {
      setState(() {
        _cartItems = cartItems;
        _totalPrice = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCart() async {
    try {
      if (!CartService.isUserLoggedIn) {
        setState(() {
          _isLoading = false;
          _cartItems = [];
          _totalPrice = 0.0;
        });
        return;
      }

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
        _cartItems = [];
        _totalPrice = 0.0;
      });
    }
  }

  Future<int> _getMaxAvailableQuantity(CartProduct item) async {
    try {
      final firestoreProduct = await FirestoreService.getProductById(item.product.id.toString());
      if (firestoreProduct != null) {
        final stock = firestoreProduct.getStockForVariant(item.size, item.color);
        return stock.clamp(1, 10);
      }
    } catch (e) {
      print('❌ Ошибка проверки наличия: $e');
    }
    return 10;
  }

  void _updateQuantity(CartProduct item, int newQuantity) async {
    try {
      final maxQuantity = await _getMaxAvailableQuantity(item);
      final clampedQuantity = newQuantity.clamp(1, maxQuantity);

      if (clampedQuantity != newQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Максимальное количество: $maxQuantity'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      await CartService.updateQuantity(
          item.product.id,
          item.size,
          item.color,
          clampedQuantity
      );
    } catch (e) {
      _showErrorSnackBar('Ошибка обновления: $e');
    }
  }

  void _removeItem(CartProduct item) async {
    try {
      await CartService.removeFromCart(item.product.id, item.size, item.color);
    } catch (e) {
      _showErrorSnackBar('Ошибка удаления: $e');
    }
  }

  void _buyItem(CartProduct item) async {
    try {
      print('🎯 Начало оформления заказа для товара: ${item.product.title}');

      // Получаем адрес доставки
      final address = await CheckoutService.getSelectedAddress();

      if (address == null) {
        _showAddressRequiredDialog();
        return;
      }

      // Оформляем заказ для одного товара
      final order = await CheckoutService.checkoutSingleItem(
        item: item,
        deliveryAddress: address,
      );

      _showOrderSuccessDialog([item], order);

    } catch (e) {
      print('❌ Ошибка оформления заказа: $e');
      _showErrorSnackBar('Ошибка оформления заказа: $e');
    }
  }

  void _buyAll() async {
    if (_cartItems.isEmpty) return;

    try {
      print('🎯 Начало оформления заказа для всей корзины: ${_cartItems.length} товаров');

      // Получаем адрес доставки
      final address = await CheckoutService.getSelectedAddress();

      if (address == null) {
        _showAddressRequiredDialog();
        return;
      }

      // Оформляем заказ для всей корзины
      final order = await CheckoutService.checkoutCart(
        deliveryAddress: address,
      );

      _showOrderSuccessDialog(_cartItems, order);

    } catch (e) {
      print('❌ Ошибка оформления заказа: $e');
      _showErrorSnackBar('Ошибка оформления заказа: $e');
    }
  }

  void _showOrderDialog(List<CartProduct> items) {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToProductDetail(CartProduct item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: item.product),
      ),
    );
  }

  Widget _buildGuestScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Войдите или зарегистрируйтесь,\nчтобы добавлять товары в корзину',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
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
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityCounter(CartProduct item) {
    return FutureBuilder<int>(
      future: _getMaxAvailableQuantity(item),
      builder: (context, snapshot) {
        final maxQuantity = snapshot.data ?? 10;
        final canIncrease = item.quantity < maxQuantity;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: item.quantity > 1
                    ? () => _updateQuantity(item, item.quantity - 1)
                    : null,
                icon: const Icon(Icons.remove, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  item.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.quantity >= maxQuantity ? Colors.orange : Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: canIncrease
                    ? () => _updateQuantity(item, item.quantity + 1)
                    : null,
                icon: const Icon(Icons.add, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    if (authProvider.isInitializing) {
      return _buildLoadingScreen();
    }

    if (!isLoggedIn) {
      return _buildGuestScreen(context);
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

  Widget _buildCartItem(CartProduct item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _navigateToProductDetail(item),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(item.product.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title.length > 40
                              ? '${item.product.title.substring(0, 40)}...'
                              : item.product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${item.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQuantityCounter(item),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => _buyItem(item),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Купить'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeItem(item),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
                '\$${_totalPrice.toStringAsFixed(2)}',
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

  void _showAddressRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Требуется адрес доставки'),
        content: const Text('Для оформления заказа необходимо добавить адрес доставки.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAddAddress();
            },
            child: const Text('Добавить адрес'),
          ),
        ],
      ),
    );
  }

  void _showUnavailableItemsDialog(List<CartProduct> unavailableItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Некоторые товары недоступны'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Следующие товары временно отсутствуют:'),
            const SizedBox(height: 12),
            ...unavailableItems.map((item) =>
                Text('• ${item.product.title} (${item.size}, ${item.color})')
            ).toList(),
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

  void _showOrderSuccessDialog(List<CartProduct> items, AppOrder order) {
    final total = items.fold(0.0, (sum, item) => sum + item.totalPrice);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заказ оформлен!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Номер заказа: #${order.id.substring(0, 8)}'),
            Text('Товаров: ${items.length}'),
            Text('Общая сумма: \$${total.toStringAsFixed(2)}'),
            Text('Статус: ${order.status.displayName}'),
            const SizedBox(height: 16),
            const Text('Заказ успешно создан и передан в обработку.',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Переход на экран деталей заказа
            },
            child: const Text('Детали заказа'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAddressScreen()),
    );
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}