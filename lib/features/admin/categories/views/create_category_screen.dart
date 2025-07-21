// lib/features/admin/categories/views/create_category_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../navigation/controllers/admin_navigation_controller.dart';
import '../../../navigation/widgets/admin_screen_wrapper.dart';
import '../../widgets/image_picker_widget.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';

class CreateCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const CreateCategoryScreen({super.key, this.category});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final CategoryController categoryController = Get.find<CategoryController>();

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final category = widget.category!;
    _titleController.text = category.title;
    _descriptionController.text = category.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScreenWrapper(
      title: isEditing ? 'Edit Category' : 'Create Category',
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
                fontWeight: FontWeight.bold,
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
              // Category Image
              const Text(
                'Category Image',
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
                maxImages: 1,
                existingImageUrls: isEditing ? [widget.category!.image] : null,
              ),
              const SizedBox(height: 24),

              // Basic Information
              const Text(
                'Category Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Category Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Please enter category title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!isEditing && _selectedImages.isEmpty) {
        Get.snackbar('Error', 'Please select an image');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final category = CategoryModel(
          id: isEditing ? widget.category!.id : null,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          image: isEditing ? widget.category!.image : '',
          createdAt: isEditing ? widget.category!.createdAt : DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final imageFile = _selectedImages.isNotEmpty ? _selectedImages.first : null;

        if (isEditing) {
          await categoryController.updateCategory(category, imageFile);
        } else {
          await categoryController.createCategory(category, imageFile);
        }

        // Navigate back to admin products tab (where categories are managed)
        Get.find<AdminNavigationController>().changeIndex(1);
        Get.offNamedUntil('/admin', (route) => route.settings.name != '/admin');
      } catch (e) {
        Get.snackbar('Error', 'Failed to ${isEditing ? 'update' : 'create'} category: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}