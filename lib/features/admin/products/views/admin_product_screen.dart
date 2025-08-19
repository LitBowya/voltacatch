// lib/features/admin/products/views/admin_products_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../home/widgets/stat_card.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_list_item.dart';
import '../../categories/controllers/category_controller.dart';
import '../../categories/views/create_category_screen.dart';
import '../../categories/widgets/category_list_item.dart';
import '../views/create_product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _productScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final ProductController productController = Get.find<ProductController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
          _productScrollController.position.maxScrollExtent) {
        productController.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _productScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Product Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: TColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Categories'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          indicatorColor: TColors.primary,
        ),
      ),
      body: Column(
        children: [
          // Stat Cards
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FutureBuilder<int>(
                    future: productController.getProductCount(),
                    builder: (context, snapshot) {
                      return StatCard(
                        title: 'Total Products',
                        value: snapshot.data?.toString() ?? '0',
                        icon: Icons.inventory_2,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<int>(
                    future: categoryController.getCategoryCount(),
                    builder: (context, snapshot) {
                      return StatCard(
                        title: 'Total Categories',
                        value: snapshot.data?.toString() ?? '0',
                        icon: Icons.category,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => const CreateProductScreen()),
                    icon: const Icon(Icons.add),
                    label: const Text('Product'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                    ),
                    onPressed: () => Get.to(() => const CreateCategoryScreen()),
                    icon: const Icon(Icons.add, color: Colors.white,),
                    label: const Text('Category', style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: productController.searchProducts,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButton<String>(
                      value: productController.selectedCategory,
                      items: ['All', ...categoryController.categories.map((cat) => cat.title)]
                          .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                          .toList(),
                      onChanged: (value) => productController.filterByCategory(value!),
                      isExpanded: true,
                    )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => DropdownButton<String>(
                      value: productController.sortBy,
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                        DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                        DropdownMenuItem(value: 'date', child: Text('Date Created')),
                      ],
                      onChanged: (value) => productController.sortProducts(value!),
                      isExpanded: true,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Products List
        Expanded(
          child: Obx(() {
            if (productController.isLoading && productController.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productController.products.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              controller: _productScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: productController.products.length + (productController.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == productController.products.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final product = productController.products[index];
                return ProductListItem(
                  product: product,
                  onEdit: () => Get.to(() => CreateProductScreen(product: product)),
                  onDelete: () => _showDeleteDialog(
                    'Delete Product',
                    'Are you sure you want to delete ${product.name}?',
                        () => productController.deleteProduct(product.id),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return Obx(() {
      if (categoryController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (categoryController.categories.isEmpty) {
        return const Center(child: Text('No categories found'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categoryController.categories.length,
        itemBuilder: (context, index) {
          final category = categoryController.categories[index];
          return CategoryListItem(
            category: category,
            onEdit: () => Get.to(() => CreateCategoryScreen(category: category)),
            onDelete: () => _showDeleteDialog(
              'Delete Category',
              'Are you sure you want to delete ${category.title}?',
                  () => categoryController.deleteCategory(category.id!),
            ),
          );
        },
      );
    });
  }

  void _showDeleteDialog(String title, String content, VoidCallback onConfirm) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Enhanced icon with gradient background
            Container(
              padding: const EdgeInsets.all(24),
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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Your product inventory is empty.\nAdd some products to get started!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Refresh button
                ElevatedButton.icon(
                  onPressed: () async {
                    // Refresh products list
                    await productController.loadProducts(refresh: true);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                ),
                const SizedBox(width: 16),

                // Add Product button
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const CreateProductScreen()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}