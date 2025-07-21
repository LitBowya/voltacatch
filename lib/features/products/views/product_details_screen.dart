// lib/features/products/views/product_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../core/constants/colors.dart';
import '../../navigation/widgets/main_screen_wrapper.dart';
import '../../admin/products/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/models/cart_model.dart';
import '../../checkout/views/checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  final CartController cartController = Get.put(CartController());
  int _currentImageIndex = 0;
  Timer? _timer;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.product.images.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && widget.product.images.length > 1) {
        if (_currentImageIndex < widget.product.images.length - 1) {
          _currentImageIndex++;
        } else {
          _currentImageIndex = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentImageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = widget.product.stock == 0;
    final bool isLowStock = widget.product.stock > 0 && widget.product.stock < 10;

    return MainScreenWrapper(
      title: widget.product.name,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Expanded(
             child: Padding(padding: EdgeInsets.all(16),
               child: SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Carousel
                      _buildImageCarousel(),
                      const SizedBox(height: 20),

                      // Basic Product Info
                      _buildBasicInfo(isOutOfStock, isLowStock),
                      const SizedBox(height: 24),

                      // Quantity Selector (only if not out of stock)
                      if (!isOutOfStock) ...[
                        _buildQuantitySelector(),
                        const SizedBox(height: 24),
                      ],

                      // Description
                      _buildDescription(),
                      const SizedBox(height: 24),

                      // Product Details
                      _buildProductDetails(),
                      const SizedBox(height: 24),

                      // Aquarium Specs (if available)
                      if (_hasAquariumSpecs()) ...[
                        _buildAquariumSpecs(),
                        const SizedBox(height: 24),
                      ],

                      // Add some bottom padding
                      const SizedBox(height: 100),
                    ],
                  ),
                ))
              ),

            // Bottom Action Bar
            if (!isOutOfStock) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: widget.product.images.isNotEmpty
          ? Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: widget.product.images.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(
                    widget.product.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 80),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Image indicators
          if (widget.product.images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.product.images.asMap().entries.map((entry) {
                  return Container(
                    width: _currentImageIndex == entry.key ? 12 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentImageIndex == entry.key
                          ? TColors.primary
                          : Colors.white.withAlpha(60),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      )
          : Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 80),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(bool isOutOfStock, bool isLowStock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: TColors.primary.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.product.categoryName,
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Price
        Text(
          'GHS ${widget.product.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 28,
            color: TColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Stock Status
        if (isOutOfStock)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: Colors.red[800], size: 16),
                const SizedBox(width: 4),
                Text(
                  'Out of Stock',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else if (isLowStock)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[800], size: 16),
                const SizedBox(width: 4),
                Text(
                  'Only ${widget.product.stock} left in stock',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green[800], size: 16),
                const SizedBox(width: 4),
                Text(
                  'In Stock (${widget.product.stock} available)',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              if (widget.product.size.isNotEmpty)
                _buildDetailRow('Size', widget.product.size),
              if (widget.product.origin.isNotEmpty)
                _buildDetailRow('Origin', widget.product.origin),
              if (widget.product.weight > 0)
                _buildDetailRow('Weight', '${widget.product.weight} kg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAquariumSpecs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aquarium Requirements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              if (widget.product.waterType.isNotEmpty)
                _buildDetailRow('Water Type', widget.product.waterType),
              if (widget.product.ph.isNotEmpty)
                _buildDetailRow('pH Level', widget.product.ph),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      foregroundColor: _quantity > 1 ? TColors.primary : Colors.grey,
                    ),
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      _quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _quantity < widget.product.stock
                        ? () => setState(() => _quantity++)
                        : null,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      foregroundColor: _quantity < widget.product.stock
                          ? TColors.primary
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Total: GHS ${(widget.product.price * _quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Add to Cart Button
            Expanded(
              child: Obx(() {
                final isInCart = cartController.isInCart(widget.product.id);
                final quantity = cartController.getItemQuantity(widget.product.id);

                return ElevatedButton(
                  onPressed: () => _addToCart(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInCart ? Colors.green : TColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isInCart ? 'In Cart ($quantity)' : 'Add to Cart',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(width: 12),

            // Buy Now Button
            Expanded(
              child: ElevatedButton(
                onPressed: () => _buyNow(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

          ],
        ),
      ),
    );
  }

  bool _hasAquariumSpecs() {
    return widget.product.waterType.isNotEmpty ||
        widget.product.ph.isNotEmpty;
  }

  Future<void> _addToCart() async {
    if (!cartController.isUserAuthenticated) {
      Get.snackbar(
        'Authentication Required',
        'Please login to add items to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(80),
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    if (_quantity > widget.product.stock) {
      Get.snackbar(
        'Insufficient Stock',
        'Only ${widget.product.stock} items available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withAlpha(80),
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    await cartController.addToCart(widget.product, quantity: _quantity);
  }

  void _buyNow() {
    if (!cartController.isUserAuthenticated) {
      Get.snackbar(
        'Authentication Required',
        'Please login to buy this product',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(80),
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    if (_quantity > widget.product.stock) {
      Get.snackbar(
        'Insufficient Stock',
        'Only ${widget.product.stock} items available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withAlpha(80),
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    // Create a temporary cart item for buy now
    final buyNowItem = CartModel(
      id: 'temp_${widget.product.id ?? 'unknown'}',
      userId: cartController.isUserAuthenticated
          ? cartController.auth.currentUser!.uid
          : '',
      productId: widget.product.id ?? '',
      product: widget.product,
      quantity: _quantity,
      totalPrice: (widget.product.price * _quantity).toDouble(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );


    Get.to(() => CheckoutScreen(
      cartItems: [buyNowItem],
      isFromCart: false,
    ));
  }
}