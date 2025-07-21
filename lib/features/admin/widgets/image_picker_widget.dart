// lib/features/admin/widgets/image_picker_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';

class ImagePickerWidget extends StatefulWidget {
  final List<File> selectedImages;
  final Function(List<File>) onImagesSelected;
  final int maxImages;
  final List<String>? existingImageUrls;

  const ImagePickerWidget({
    super.key,
    required this.selectedImages,
    required this.onImagesSelected,
    this.maxImages = 2,
    this.existingImageUrls,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImages = false;

  Future<void> _pickImages() async {
    if (_isPickingImages) return;

    setState(() {
      _isPickingImages = true;
    });

    try {
      // Try multiple image picker first
      List<XFile> images = [];

      try {
        images = await _picker.pickMultiImage(
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 85,
        );
      } catch (e) {
        print('Multi-image picker failed: $e');
        // Fallback to single image picker
        await _pickSingleImageFallback();
        return;
      }

      if (images.isNotEmpty) {
        List<File> newImages = images.map((image) => File(image.path)).toList();

        // Limit to max images
        int remainingSlots = widget.maxImages - widget.selectedImages.length;
        if (newImages.length > remainingSlots) {
          newImages = newImages.take(remainingSlots).toList();
        }

        // Combine with existing selected images
        List<File> allImages = [...widget.selectedImages, ...newImages];
        widget.onImagesSelected(allImages);

        Get.snackbar(
          'Success',
          '${newImages.length} image(s) added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      }
    } on PlatformException catch (e) {
      print('Platform exception: ${e.message}');
      await _handlePlatformException(e);
    } catch (e) {
      print('General exception: $e');
      Get.snackbar(
        'Error',
        'Failed to pick images. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      setState(() {
        _isPickingImages = false;
      });
    }
  }

  Future<void> _pickSingleImageFallback() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        List<File> allImages = [...widget.selectedImages, File(image.path)];
        widget.onImagesSelected(allImages);

        Get.snackbar(
          'Success',
          'Image added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      }
    } catch (e) {
      print('Single image picker also failed: $e');
      _showImagePickerOptions();
    }
  }

  Future<void> _handlePlatformException(PlatformException e) async {
    if (e.code == 'channel-error') {
      // Channel communication error - try alternative approach
      Get.snackbar(
        'Connection Error',
        'Image picker connection failed. Trying alternative method...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );

      // Wait a bit and try again with single picker
      await Future.delayed(const Duration(milliseconds: 500));
      await _pickSingleImageFallback();
    } else {
      Get.snackbar(
        'Error',
        'Failed to access image picker: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                _pickFromCamera();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        List<File> allImages = [...widget.selectedImages, File(image.path)];
        widget.onImagesSelected(allImages);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image from gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        List<File> allImages = [...widget.selectedImages, File(image.path)];
        widget.onImagesSelected(allImages);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image from camera',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  void _removeImage(int index) {
    List<File> updatedImages = List.from(widget.selectedImages);
    updatedImages.removeAt(index);
    widget.onImagesSelected(updatedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images (Max ${widget.maxImages})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TColors.dark,
          ),
        ),
        const SizedBox(height: 12),

        // Display existing images if any
        if (widget.existingImageUrls != null && widget.existingImageUrls!.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.existingImageUrls!.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.existingImageUrls![index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

        if (widget.existingImageUrls != null && widget.existingImageUrls!.isNotEmpty)
          const SizedBox(height: 12),

        // Display selected images
        if (widget.selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          widget.selectedImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        const SizedBox(height: 12),

        // Add images button
        if (widget.selectedImages.length < widget.maxImages)
          GestureDetector(
            onTap: _isPickingImages ? null : _pickImages,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: _isPickingImages ? Colors.grey[200] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isPickingImages ? Colors.grey : TColors.primary,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPickingImages)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: TColors.primary,
                      size: 32,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _isPickingImages ? 'Loading...' : 'Add Images',
                    style: TextStyle(
                      color: _isPickingImages ? Colors.grey : TColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 8),

        // Add alternative picker button
        if (widget.selectedImages.length < widget.maxImages)
          TextButton.icon(
            onPressed: _showImagePickerOptions,
            icon: const Icon(Icons.camera_alt_outlined, size: 16),
            label: const Text('Alternative Picker'),
            style: TextButton.styleFrom(
              foregroundColor: TColors.primary,
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}