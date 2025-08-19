import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/constants/colors.dart';
import '../../admin/products/models/product_model.dart';
import '../../admin/products/controllers/product_controller.dart';
import '../../products/views/product_details_screen.dart';

class LatestProductsWidget extends StatelessWidget {
  const LatestProductsWidget({
    super.key, required RxList<ProductModel> products,
  });

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();

    return Obx(() {
      // Get latest products from the controller
      final latestProducts = productController.products
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final displayProducts = latestProducts.take(12).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and refresh button
          Row(
            children: [
              const Text(
                'Latest Products',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: productController.isLoading
                    ? null
                    : () async {
                        await productController.loadProducts(refresh: true);
                        Get.snackbar(
                          'Refreshed',
                          'Latest products updated!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.withOpacity(0.8),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                      },
                icon: productController.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh latest products',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content based on state
          if (productController.isLoading && productController.products.isEmpty)
            _buildLoadingState()
          else if (displayProducts.isEmpty)
            _buildEmptyState(productController)
          else
            _buildProductsList(displayProducts),
        ],
      );
    });
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Loading latest products...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ProductController productController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[200]!,
                  Colors.grey[100]!,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'No Latest Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'We couldn\'t find any recent products.\nTry refreshing to see new arrivals!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Refresh button
          ElevatedButton.icon(
            onPressed: productController.isLoading
                ? null
                : () async {
                    await productController.loadProducts(refresh: true);
                    Get.snackbar(
                      'Refreshed',
                      'Products have been refreshed successfully!',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                    );
                  },
            icon: productController.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(productController.isLoading ? 'Refreshing...' : 'Refresh Products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<ProductModel> displayProducts) {
    return Column(
      children: displayProducts
          .map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProductCard(
                  product: product,
                  onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
                ),
              ))
          .toList(),
    );
  }
}
