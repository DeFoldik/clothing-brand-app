// widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/favorite_service.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onFavoriteChanged;

  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteChanged,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  final PageController _pageController = PageController();

  List<String> get _productImages {
    return [
      widget.product.image,
      'https://via.placeholder.com/300/FF0000/FFFFFF?text=Image+2',
      'https://via.placeholder.com/300/0000FF/FFFFFF?text=Image+3',
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await FavoriteService.isFavorite(widget.product.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      await FavoriteService.addToFavorites(widget.product.id);
    } else {
      await FavoriteService.removeFromFavorites(widget.product.id);
    }

    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
    }
  }

  // В ProductCard обновите метод _showAddToCartDialog
  void _showAddToCartDialog() async {
    String selectedSize = 'M';
    String selectedColor = 'Черный';
    bool _isLoading = true;
    List<String> availableSizes = [];
    List<String> availableColors = [];
    Map<String, bool> sizeAvailability = {};
    Map<String, bool> colorAvailability = {};

    // Загружаем доступные размеры и цвета
    availableSizes = await CartService.getAvailableSizes(widget.product.id);
    availableColors = await CartService.getAvailableColors(widget.product.id);

    // Устанавливаем первый доступный размер и цвет по умолчанию
    if (availableSizes.isNotEmpty) selectedSize = availableSizes.first;
    if (availableColors.isNotEmpty) selectedColor = availableColors.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Функция для проверки доступности при изменении выбора
          void _checkAvailability() async {
            final isAvailable = await CartService.checkAvailability(
                widget.product.id,
                selectedSize,
                selectedColor
            );

            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }

          // Первоначальная проверка
          if (_isLoading) {
            _checkAvailability();
          }

          return AlertDialog(
            title: const Text('Добавить в корзину'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ВЫБОР РАЗМЕРА
                const Text('Размер:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSizes.map((size) {
                    return ChoiceChip(
                      label: Text(size),
                      selected: selectedSize == size,
                      onSelected: (selected) {
                        setState(() {
                          selectedSize = size;
                          _isLoading = true;
                        });
                        _checkAvailability();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ВЫБОР ЦВЕТА
                const Text('Цвет:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableColors.map((color) {
                    return ChoiceChip(
                      label: Text(color),
                      selected: selectedColor == color,
                      onSelected: (selected) {
                        setState(() {
                          selectedColor = color;
                          _isLoading = true;
                        });
                        _checkAvailability();
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // ИНФОРМАЦИЯ О НАЛИЧИИ
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Размер ${selectedSize}, цвет $selectedColor в наличии',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  final cartProduct = CartProduct(
                    product: widget.product,
                    size: selectedSize,
                    color: selectedColor,
                    quantity: 1,
                  );

                  CartService.addToCart(cartProduct);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Товар добавлен в корзину')),
                  );
                },
                child: const Text('Добавить'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = _productImages.length > 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // БЛОК С ИЗОБРАЖЕНИЕМ
          Stack(
            children: [
              // PAGE VIEW ДЛЯ СВАЙПА
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _productImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: _productImages[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      );
                    },
                  ),
                ),
              ),

              // индикатор точек
              if (hasMultipleImages)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _productImages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentImageIndex == index ? 9 : 6,
                        height: _currentImageIndex == index ? 9 : 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(3),
                          color: _currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),

              // 🎯 КНОПКА ИЗБРАННОГО
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // 🎯 КНОПКА КОРЗИНЫ
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _showAddToCartDialog,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black54,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ), // Закрывающая скобка для Stack

          // ИНФОРМАЦИЯ О ТОВАРЕ
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ЦЕНА
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 4),

                // НАЗВАНИЕ ТОВАРА
                Text(
                  widget.product.title.length > 25
                      ? '${widget.product.title.substring(0, 25)}...'
                      : widget.product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}