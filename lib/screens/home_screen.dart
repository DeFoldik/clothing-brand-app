import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/event_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';

  // 🎯 БАННЕРЫ ИВЕНТОВ
  final List<Map<String, dynamic>> _eventBanners = [
    {
      'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500',
      'title': 'Новая Осенняя Коллекция',
      'subtitle': 'Открой для себя свежие тренды',
    },
    {
      'image': 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=500',
      'title': 'Распродажа до 50%',
      'subtitle': 'Успей до конца недели',
    },
    {
      'image': 'https://images.unsplash.com/photo-1601924582970-9238bcb495d9?w=500',
      'title': 'Бестселлеры',
      'subtitle': 'То, что выбирают другие',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 🎯 САМЫЕ ПОПУЛЯРНЫЕ (первые 4)
  List<Product> get _popularProducts {
    return _products.take(4).toList();
  }

  // 🎯 ПОСЛЕДНЯЯ КОЛЛЕКЦИЯ (следующие 4)
  List<Product> get _latestCollection {
    return _products.skip(4).take(4).toList();
  }

  // 🎯 ТОВАРЫ СО СКИДКОЙ (дорогие товары как "премиум")
  List<Product> get _discountedProducts {
    if (_products.isEmpty) return [];
    final sorted = List<Product>.from(_products);
    sorted.sort((a, b) => b.price.compareTo(a.price));
    return sorted.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingScreen()
          : _error.isNotEmpty
          ? _buildErrorScreen()
          : _buildHomeScreen(),
    );
  }

  Widget _buildHomeScreen() {
    return CustomScrollView(
      slivers: [
        // 🎯 APP BAR
        const SliverAppBar(
          title: Text('Fashion Store'),
          floating: true,
          snap: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),

        SliverToBoxAdapter(
          child: EventBanner(
            banners: _eventBanners,
            height: 300,
          ),
        ),

        // 🎯 СЕКЦИЯ: САМЫЕ ПОПУЛЯРНЫЕ
        _buildProductSection(
          title: '🔥 Самые популярные',
          subtitle: 'То, что выбирают наши клиенты',
          products: _popularProducts,
        ),

        // 🎯 СЕКЦИЯ: ПОСЛЕДНЯЯ КОЛЛЕКЦИЯ
        _buildProductSection(
          title: '🆕 Последняя коллекция',
          subtitle: 'Самые свежие поступления',
          products: _latestCollection,
        ),

        // 🎯 СЕКЦИЯ: ТОВАРЫ СО СКИДКОЙ
        _buildProductSection(
          title: '💰 Товары со скидкой',
          subtitle: 'Особые предложения этой недели',
          products: _discountedProducts,
        ),
      ],
    );
  }

  // 🎯 УНИВЕРСАЛЬНАЯ СЕКЦИЯ ТОВАРОВ
  Widget _buildProductSection({
    required String title,
    required String subtitle,
    required List<Product> products,
  }) {
    if (products.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ЗАГОЛОВОК СЕКЦИИ
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // СЕТКА ТОВАРОВ 2x2
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Text('Ошибка: $_error'),
    );
  }
}