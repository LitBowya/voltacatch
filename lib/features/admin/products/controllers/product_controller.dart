// lib/features/admin/products/controllers/product_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final RxList<ProductModel> _products = <ProductModel>[].obs;
  final RxList<ProductModel> _filteredProducts = <ProductModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxString _sortBy = 'name'.obs; // name, price_low, price_high, date

  // Pagination
  DocumentSnapshot? _lastDocument;
  final RxBool _hasMore = true.obs;
  final int _pageSize = 10;

  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  String get sortBy => _sortBy.value;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // Create product
  Future<String> createProduct(ProductModel product, List<File> imageFiles) async {
    try {
      _isLoading.value = true;

      List<String> imageUrls = [];

      for (File imageFile in imageFiles) {
        final ref = _storage.ref().child('products/${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg');
        await ref.putFile(imageFile);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      final productData = product.copyWith(
        images: imageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('products').add(productData.toJson());
      await loadProducts(refresh: true);

      _isLoading.value = false;
      Get.snackbar('Success', 'Product created successfully');
      return docRef.id;
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to create product: $e');
      throw Exception('Failed to create product: $e');
    }
  }

  // Load products with pagination
  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading.value || (!_hasMore.value && !refresh)) return;

    try {
      _isLoading.value = true;

      if (refresh) {
        _products.clear();
        _lastDocument = null;
        _hasMore.value = true;
      }

      Query query = _firestore
          .collection('products')
          .where('isActive', isEqualTo: true);

      // Apply category filter
      if (_selectedCategory.value != 'All') {
        query = query.where('categoryName', isEqualTo: _selectedCategory.value);
      }

      // Apply sorting
      switch (_sortBy.value) {
        case 'price_low':
          query = query.orderBy('price', descending: false);
          break;
        case 'price_high':
          query = query.orderBy('price', descending: true);
          break;
        case 'date':
          query = query.orderBy('createdAt', descending: true);
          break;
        default:
          query = query.orderBy('name', descending: false);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_pageSize);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newProducts = snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        _products.addAll(newProducts);

        if (snapshot.docs.length < _pageSize) {
          _hasMore.value = false;
        }
      } else {
        _hasMore.value = false;
      }

      _applyFilters();
      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to load products: $e');
    }
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery.value = query;
    _applyFilters();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory.value = category;
    loadProducts(refresh: true);
  }

  // Sort products
  void sortProducts(String sortBy) {
    _sortBy.value = sortBy;
    loadProducts(refresh: true);
  }

  // Apply search filter
  void _applyFilters() {
    _filteredProducts.value = _products.where((product) {
      final matchesSearch = _searchQuery.value.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.value.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.value.toLowerCase());

      return matchesSearch;
    }).toList();
  }

  // Update product
  Future<void> updateProduct(ProductModel product, List<File>? imageFiles) async {
    try {
      _isLoading.value = true;

      List<String> imageUrls = product.images;

      if (imageFiles != null && imageFiles.isNotEmpty) {
        imageUrls = [];
        for (File imageFile in imageFiles) {
          final ref = _storage.ref().child('products/${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg');
          await ref.putFile(imageFile);
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      }

      final productData = product.copyWith(
        images: imageUrls,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('products')
          .doc(product.id)
          .update(productData.toJson());

      await loadProducts(refresh: true);
      _isLoading.value = false;
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to update product: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update({'isActive': false});

      await loadProducts(refresh: true);
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    }
  }

  // Get product count
  Future<int> getProductCount() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  void reset() {
    _products.clear();
    _filteredProducts.clear();
    _lastDocument = null;
    _hasMore.value = true;
    _searchQuery.value = '';
    _selectedCategory.value = 'All';
    _sortBy.value = 'name';
  }
}