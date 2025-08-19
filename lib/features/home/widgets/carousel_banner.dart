// lib/features/home/widgets/simple_carousel_banner.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/constants/images.dart';
import '../../../core/constants/colors.dart';

class SimpleCarouselBanner extends StatefulWidget {
  const SimpleCarouselBanner({super.key});

  @override
  State<SimpleCarouselBanner> createState() => _SimpleCarouselBannerState();
}

class _SimpleCarouselBannerState extends State<SimpleCarouselBanner> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> _bannerImages = [
    TImages.banner1,
    TImages.banner2,
    TImages.banner3,
  ];

  final List<Map<String, String>> _bannerData = [
    {
      'title': 'Fresh Farm Products',
      'subtitle': 'Get the best quality products directly from farms',
    },
    {
      'title': 'Premium Quality Fish',
      'subtitle': 'Discover our wide selection of fresh aquatic products',
    },
    {
      'title': 'Farm to Table',
      'subtitle': 'Experience the freshest produce delivered to your door',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentIndex < _bannerImages.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return _buildBannerItem(index);
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildDotsIndicator(),
        ],
      ),
    );
  }

  Widget _buildBannerItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _bannerImages[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: TColors.primary.withAlpha((0.1 * 255).toInt()),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: TColors.primary,
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha((0.7 * 255).toInt()),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bannerData[index]['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _bannerData[index]['subtitle']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _bannerImages.asMap().entries.map((entry) {
        int index = entry.key;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentIndex == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentIndex == index
                ? TColors.primary
                : TColors.primary.withAlpha((0.3 * 255).toInt()),
          ),
        );
      }).toList(),
    );
  }
}