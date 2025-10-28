import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';

  // Заглушка для баннеров (позже заменим на реальные)
  final List<String> _banners = [
    'https://via.placeholder.com/300x150/FF0000/FFFFFF?text=Новая+Коллекция',
    'https://via.placeholder.com/300x150/00FF00/FFFFFF?text=Скидки+50%',
    'https://via.placeholder.com/300x150/0000FF/FFFFFF?text=Осенняя+Распродажа',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Карусель баннеров
          SliverToBoxAdapter(
            child: _buildBannerCarousel(),
          ),

          // Секция с товарами
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return ProductCard(product: _products[index]);
                },
                childCount: _products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(16),
      child: PageView.builder(
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(_banners[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}