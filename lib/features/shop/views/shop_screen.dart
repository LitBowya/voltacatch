// lib/features/shop/views/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/product_card.dart';
import '../controllers/shop_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/sort_bottom_sheet.dart';
import '../../products/views/product_details_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ShopController shopController = Get.put(ShopController());

    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Shop", style: TextStyle(color: Colors.white)),
            backgroundColor: TColors.primary,
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search
            _buildHeader(shopController, searchController),

            // Categories Section
            _buildCategoriesSection(shopController),

            // Filters and Sort Bar
            _buildFiltersBar(shopController),

            // Products Grid
            Expanded(
              child: _buildProductsGrid(shopController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ShopController controller, TextEditingController searchController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: searchController,
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    controller.updateSearchQuery('');
                  },
                  icon: Icon(Icons.clear, color: Colors.grey[500]),
                )
                    : const SizedBox.shrink()),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(ShopController controller) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // All Products Category
            CategoryChip(
              name: 'All',
              isSelected: controller.selectedCategoryId.value.isEmpty,
              onTap: () => controller.clearCategorySelection(),
              icon: Icons.grid_view_rounded,
            ),

            const SizedBox(width: 12),

            // Category chips
            ...controller.categories.map((category) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CategoryChip(
                name: category.title,
                isSelected: controller.selectedCategoryId.value == category.id,
                onTap: () => controller.selectCategory(category.id ?? ''),
                imageUrl: category.image,
              ),
            )),
          ],
        );
      }),
    );
  }

  Widget _buildFiltersBar(ShopController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Results count
          Expanded(
            child: Obx(() => Text(
              '${controller.filteredProductsCount} products found',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            )),
          ),

          // Sort button
          GestureDetector(
            onTap: () => _showSortBottomSheet(controller),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Filter button
          GestureDetector(
            onTap: () => _showFilterBottomSheet(controller),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(ShopController controller) {
    return Obx(() {
      if (controller.isLoadingProducts.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.displayedProducts.isEmpty) {
        return _buildEmptyState(controller);
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchProducts();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.displayedProducts.length,
          itemBuilder: (context, index) {
            final product = controller.displayedProducts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ProductCard(
                product: product,
                onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
              ),
            );
          },
        ),
      );
    });
  }


  Widget _buildEmptyState(ShopController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No products found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filters',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action buttons side by side
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reload Products button
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Reload products from server
                            await controller.fetchProducts();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Clear All Filters button
                        ElevatedButton.icon(
                          onPressed: () => controller.clearAllFilters(),
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSortBottomSheet(ShopController controller) {
    Get.bottomSheet(
      SortBottomSheet(controller: controller),
      isScrollControlled: true,
    );
  }

  void _showFilterBottomSheet(ShopController controller) {
    Get.bottomSheet(
      FilterBottomSheet(controller: controller),
      isScrollControlled: true,
    );
  }
}