// lib/features/admin/categories/controllers/category_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../models/category_model.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  // Create category
  Future<String> createCategory(CategoryModel category, File? imageFile) async {
    try {
      _isLoading.value = true;

      String imageUrl = '';

      if (imageFile != null) {
        final ref = _storage.ref().child('categories/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final categoryData = category.copyWith(
        image: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('categories').add(categoryData.toJson());
      await loadCategories();

      _isLoading.value = false;
      Get.snackbar('Success', 'Category created successfully');
      return docRef.id;
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to create category: $e');
      throw Exception('Failed to create category: $e');
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _isLoading.value = true;

      final snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _categories.value = snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList();

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to load categories: $e');
      print('Failed to load categories: $e');
    }
  }

  // Update category
  Future<void> updateCategory(CategoryModel category, File? imageFile) async {
    try {
      _isLoading.value = true;

      String imageUrl = category.image;

      if (imageFile != null) {
        final ref = _storage.ref().child('categories/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final categoryData = category.copyWith(
        image: imageUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(categoryData.toJson());

      await loadCategories();
      _isLoading.value = false;
      Get.snackbar('Success', 'Category updated successfully');
    } catch (e) {
      _isLoading.value = false;
      Get.snackbar('Error', 'Failed to update category: $e');
      print('Failed to update category: $e');
    }
  }

  // Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update({'isActive': false});

      await loadCategories();
      Get.snackbar('Success', 'Category deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e');
      print('Failed to delete category: $e');
    }
  }

  // Get category count
  Future<int> getCategoryCount() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}