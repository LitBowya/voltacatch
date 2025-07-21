// lib/features/shop/controllers/shop_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../admin/products/models/product_model.dart';
import '../../admin/categories/models/category_model.dart';

enum SortBy {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  newestFirst,
  oldestFirst,
}

class ShopController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable lists
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> displayedProducts = <ProductModel>[].obs;

  // State variables
  final RxBool isLoadingCategories = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rx<SortBy> currentSort = SortBy.newestFirst.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 10000.0.obs;
  final RxDouble filterMinPrice = 0.0.obs;
  final RxDouble filterMaxPrice = 10000.0.obs;
  final RxBool inStockOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;

      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('title')
          .get();

      categories.value = snapshot.docs
          .map((doc) => CategoryModel.fromJson(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoadingProducts.value = true;

      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      allProducts.value = snapshot.docs
          .map((doc) => ProductModel.fromJson(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      _calculatePriceRange();
      _applyFiltersAndSort();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch products: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(days: 1), // Keeps it visible "forever"
        mainButton: TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: 'Failed to fetch products: $e'));
            Get.snackbar('Copied', 'Error message copied to clipboard', snackPosition: SnackPosition.BOTTOM);
          },
          child: const Text(
            'COPY',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

    } finally {
      isLoadingProducts.value = false;
    }
  }

  void _calculatePriceRange() {
    if (allProducts.isEmpty) return;

    final prices = allProducts.map((product) => product.price).toList();
    minPrice.value = prices.reduce((a, b) => a < b ? a : b);
    maxPrice.value = prices.reduce((a, b) => a > b ? a : b);

    // Set initial filter range
    if (filterMinPrice.value == 0.0 && filterMaxPrice.value == 10000.0) {
      filterMinPrice.value = minPrice.value;
      filterMaxPrice.value = maxPrice.value;
    }
  }

  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
    _applyFiltersAndSort();
  }

  void clearCategorySelection() {
    selectedCategoryId.value = '';
    _applyFiltersAndSort();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
    _applyFiltersAndSort();
  }

  void updateSort(SortBy sortBy) {
    currentSort.value = sortBy;
    _applyFiltersAndSort();
  }

  void updatePriceFilter(double min, double max) {
    filterMinPrice.value = min;
    filterMaxPrice.value = max;
    _applyFiltersAndSort();
  }

  void toggleInStockOnly(bool value) {
    inStockOnly.value = value;
    _applyFiltersAndSort();
  }

  void clearAllFilters() {
    selectedCategoryId.value = '';
    searchQuery.value = '';
    filterMinPrice.value = minPrice.value;
    filterMaxPrice.value = maxPrice.value;
    inStockOnly.value = false;
    currentSort.value = SortBy.newestFirst;
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    List<ProductModel> products = List.from(allProducts);

    // Apply category filter
    if (selectedCategoryId.value.isNotEmpty) {
      products = products
          .where((product) => product.categoryId == selectedCategoryId.value)
          .toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      products = products.where((product) {
        return product.name.toLowerCase().contains(searchQuery.value) ||
            product.description.toLowerCase().contains(searchQuery.value) ||
            product.categoryName.toLowerCase().contains(searchQuery.value);
      }).toList();
    }

    // Apply price filter
    products = products
        .where((product) =>
    product.price >= filterMinPrice.value &&
        product.price <= filterMaxPrice.value)
        .toList();

    // Apply stock filter
    if (inStockOnly.value) {
      products = products.where((product) => product.stock > 0).toList();
    }

    // Apply sorting
    switch (currentSort.value) {
      case SortBy.nameAsc:
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortBy.nameDesc:
        products.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortBy.priceAsc:
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortBy.priceDesc:
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortBy.newestFirst:
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortBy.oldestFirst:
        products.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    filteredProducts.value = products;
    displayedProducts.value = products;
  }

  String get selectedCategoryName {
    if (selectedCategoryId.value.isEmpty) return 'All Products';
    final category = categories.firstWhereOrNull(
            (cat) => cat.id == selectedCategoryId.value);
    return category?.title ?? 'Unknown Category';
  }

  int get totalProductsCount => allProducts.length;
  int get filteredProductsCount => filteredProducts.length;

  String getSortDisplayName(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.nameAsc:
        return 'Name (A-Z)';
      case SortBy.nameDesc:
        return 'Name (Z-A)';
      case SortBy.priceAsc:
        return 'Price (Low to High)';
      case SortBy.priceDesc:
        return 'Price (High to Low)';
      case SortBy.newestFirst:
        return 'Newest First';
      case SortBy.oldestFirst:
        return 'Oldest First';
    }
  }
}