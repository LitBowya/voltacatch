import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/admin/products/models/product_model.dart';
import '../constants/colors.dart';
import '../../features/products/views/product_details_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool showAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product.stock == 0;
    final bool isLowStock = product.stock > 0 && product.stock < 10;

    return GestureDetector(
      onTap: onTap ?? () => _navigateToProductDetail(),
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Row(
                children: [
                  // Product Image (Left Side)
                  _buildProductImage(isOutOfStock),

                  // Product Info (Right Side)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title and Category Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isOutOfStock ? Colors.grey[500] : const Color(0xFF2D3748),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildCategoryChip(),
                            ],
                          ),

                          // Price, Weight, and Stock Info Row
                          Row(
                            children: [
                              // Price and Weight
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GHS ${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: isOutOfStock ? Colors.grey[500] : TColors.primary,
                                      ),
                                    ),
                                    if (product.weight > 0)
                                      Text(
                                        '${product.weight}kg',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Stock Information
                              if (isLowStock && !isOutOfStock)
                                _buildStockInfo()
                              else if (!isOutOfStock)
                                _buildInStockBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Out of Stock Overlay
              if (isOutOfStock) _buildOutOfStockOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(bool isOutOfStock) {
    return SizedBox(
      width: 85,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          product.images.isNotEmpty
              ? Hero(
            tag: 'product-${product.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // Add border radius here
              child: Image.network(
                product.images.first,
                fit: BoxFit.cover,
                colorBlendMode: isOutOfStock ? BlendMode.saturation : null,
                color: isOutOfStock ? Colors.grey : null,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder(isOutOfStock);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
              : _buildImagePlaceholder(isOutOfStock),

          // Subtle gradient overlay
          if (!isOutOfStock)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.03),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isOutOfStock) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isOutOfStock ? Colors.grey[200]! : Colors.grey[100]!,
            isOutOfStock ? Colors.grey[300]! : Colors.grey[200]!,
          ],
        ),
      ),
      child: Icon(
        Icons.local_grocery_store_outlined,
        color: isOutOfStock ? Colors.grey[400] : Colors.grey[400],
        size: 32,
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TColors.primary.withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Text(
        product.categoryName,
        style: TextStyle(
          fontSize: 9,
          color: TColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStockInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange[50]!,
            Colors.orange[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 12,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            '${product.stock} left',
            style: TextStyle(
              fontSize: 10,
              color: Colors.orange[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[50]!,
            Colors.green[100]!,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 12,
            color: Colors.green[700],
          ),
          const SizedBox(width: 4),
          Text(
            'In Stock',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutOfStockOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Colors.red[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'OUT OF STOCK',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetail() {
    Get.to(() => ProductDetailsScreen(product: product));
  }
}