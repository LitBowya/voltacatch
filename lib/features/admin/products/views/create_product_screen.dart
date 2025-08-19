// lib/features/admin/products/views/create_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../navigation/controllers/admin_navigation_controller.dart';
import '../../../navigation/widgets/admin_screen_wrapper.dart';
import '../../widgets/image_picker_widget.dart';
import '../controllers/product_controller.dart';
import '../../categories/controllers/category_controller.dart';
import '../models/product_model.dart';

class CreateProductScreen extends StatefulWidget {
  final ProductModel? product;

  const CreateProductScreen({super.key, this.product});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _speciesController = TextEditingController();
  final _sizeController = TextEditingController();
  final _originController = TextEditingController();
  final _weightController = TextEditingController();
  final _waterTypeController = TextEditingController();
  final _careLevelController = TextEditingController();
  final _temperamentController = TextEditingController();
  final _minTankSizeController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _phController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final ProductController productController = Get.find<ProductController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      categoryController.loadCategories();
    });
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();
    _sizeController.text = product.size;
    _originController.text = product.origin;
    _weightController.text = product.weight.toString();
    _waterTypeController.text = product.waterType;
    _phController.text = product.ph;
    _selectedCategoryId = product.categoryId;
    _selectedCategoryName = product.categoryName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _speciesController.dispose();
    _sizeController.dispose();
    _originController.dispose();
    _weightController.dispose();
    _waterTypeController.dispose();
    _careLevelController.dispose();
    _temperamentController.dispose();
    _minTankSizeController.dispose();
    _temperatureController.dispose();
    _phController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreenWrapper(
      title: isEditing ? 'Edit Product' : 'Create Product',
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          TextButton(
            onPressed: _submitForm,
            child: Text(
              isEditing ? 'Update' : 'Create',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              const Text(
                'Product Images',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ImagePickerWidget(
                selectedImages: _selectedImages,
                onImagesSelected: (images) {
                  setState(() {
                    _selectedImages = images;
                  });
                },
                maxImages: 5,
                existingImageUrls: isEditing ? widget.product!.images : null,
              ),
              const SizedBox(height: 24),

              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Product Name', 'Please enter product name'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description', 'Please enter description', maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_priceController, 'Price', 'Please enter price', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_stockController, 'Stock', 'Please enter stock quantity', keyboardType: TextInputType.number),
              const SizedBox(height: 16),

              // Category Selection
              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (categoryController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  hint: const Text('Select Category'),
                  items: categoryController.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      _selectedCategoryName = categoryController.categories
                          .firstWhere((cat) => cat.id == value)
                          .title;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a category' : null,
                );
              }),
              const SizedBox(height: 24),

              // Fish Details
              const Text(
                'Fish Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildTextField(_sizeController, 'Size (optional)', null),
              const SizedBox(height: 16),
              _buildTextField(_originController, 'Origin (optional)', null),
              const SizedBox(height: 16),
              _buildTextField(_weightController, 'Weight (kg) (optional)', null, keyboardType: TextInputType.number),
              const SizedBox(height: 24),

              // Care Information
              const Text(
                'Care Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildTextField(_waterTypeController, 'Water Type', 'Please enter water type'),
              const SizedBox(height: 16),
              _buildTextField(_phController, 'pH Range (optional)', null),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String? validationMessage,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validationMessage != null
          ? (value) => value!.isEmpty ? validationMessage : null
          : null,
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        Get.snackbar('Error', 'Please select a category');
        return;
      }

      if (!isEditing && _selectedImages.isEmpty) {
        Get.snackbar('Error', 'Please select at least one image');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final product = ProductModel(
          id: isEditing ? widget.product!.id : '',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          categoryId: _selectedCategoryId!,
          categoryName: _selectedCategoryName!,
          stock: int.parse(_stockController.text),
          images: isEditing ? widget.product!.images : [],
          size: _sizeController.text.trim(),
          origin: _originController.text.trim(),
          weight: double.tryParse(_weightController.text) ?? 0.0,
          waterType: _waterTypeController.text.trim(),
          ph: _phController.text.trim(),
          createdAt: isEditing ? widget.product!.createdAt : DateTime.now(),
          updatedAt: DateTime.now(),
          // Add default rating values for new products
          averageRating: isEditing ? widget.product!.averageRating : 0.0,
          totalReviews: isEditing ? widget.product!.totalReviews : 0,
          ratingDistribution: isEditing ? widget.product!.ratingDistribution : const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        );

        if (isEditing) {
          await productController.updateProduct(product, _selectedImages.isNotEmpty ? _selectedImages : null);
        } else {
          await productController.createProduct(product, _selectedImages);
        }

        // Navigate back to admin products tab
        Get.find<AdminNavigationController>().changeIndex(1);
        Get.offNamedUntil('/admin', (route) => route.settings.name != '/admin');
      } catch (e) {
        Get.snackbar('Error', 'Failed to ${isEditing ? 'update' : 'create'} product: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}