// widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/favorite_service.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../screens/poduct_detail_screen.dart';

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
    // Если у товара есть дополнительные изображения, используем их
    if (widget.product.images != null && widget.product.images!.isNotEmpty) {
      return widget.product.images!.take(10).toList(); // Максимум 10 фото
    }
    // Иначе используем основное изображение
    return [widget.product.image];
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

  // 🆕 МЕТОД ДЛЯ ОТОБРАЖЕНИЯ ЦЕНЫ СО СКИДКОЙ
  // 🆕 КОМПАКТНЫЙ МЕТОД ДЛЯ ЦЕНЫ БЕЗ ПЕРЕПОЛНЕНИЯ
  Widget _buildPriceWithDiscount() {
    final hasDiscount = widget.product.id % 2 == 0;
    final discountPrice = hasDiscount ? widget.product.price * 0.7 : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDiscount && discountPrice != null) ...[
          Row(
            children: [
              Text(
                '\$${discountPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '-30%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '\$${widget.product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ] else ...[
          Text(
            '\$${widget.product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
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

  Widget _buildPriceSection() {
    final hasDiscount = widget.product.price > 50; // Заглушка для демо скидки

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDiscount) ...[
          Text(
            '\$${(widget.product.price * 0.7).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '\$${widget.product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ] else ...[
          Text(
            '\$${widget.product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = _productImages.length > 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: widget.product),
          ),
        );
      },
      child: Container(
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
                  height: 163,
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
                        _productImages.length, // 🎯 Теперь реальное количество
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
            ],
          ), // Закрывающая скобка для Stack

          // ИНФОРМАЦИЯ О ТОВАРЕ
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ЦЕНА
                _buildPriceWithDiscount(),
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
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}