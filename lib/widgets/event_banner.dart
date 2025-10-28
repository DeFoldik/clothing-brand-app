import 'package:flutter/material.dart';

class EventBanner extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final double height;

  const EventBanner({
    super.key,
    required this.banners,
    this.height = 180,
  });

  @override
  State<EventBanner> createState() => _EventBannerState();
}

class _EventBannerState extends State<EventBanner> {
  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // 🎯 PAGE VIEW ДЛЯ СВАЙПА БАННЕРОВ
          PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return _buildBannerItem(banner);
            },
          ),

          // 🎯 ИНДИКАТОР ТОЧЕК СНИЗУ
          if (widget.banners.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.banners.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentBannerIndex == index ? 9 : 6,
                    height: _currentBannerIndex == index ? 9 : 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(3),
                      color: _currentBannerIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(Map<String, dynamic> banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(banner['image']),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banner['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                banner['subtitle'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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