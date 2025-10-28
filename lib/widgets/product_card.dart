import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _currentImageIndex = 0;
  bool _isFavorite = false;
  final PageController _pageController = PageController();

  // заглушка
  List<String> get _productImages {
    return [
      widget.product.image,
      'https://via.placeholder.com/300/FF0000/FFFFFF?text=Image+2',
      'https://via.placeholder.com/300/0000FF/FFFFFF?text=Image+3',
    ];
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
          // БЛОК С ИЗОБРАЖЕНИЕМ (СВАЙП + ИНДИКАТОР)
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

              // КНОПКА ИЗБРАННОГО
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.black54 : Colors.black54,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),

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