// lib/features/admin/profile/controllers/admin_profile_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/models/user_model.dart';

class AdminProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isUpdatingProfile = false.obs;
  final RxBool _isUploadingImage = false.obs;
  final RxString _profileImageUrl = ''.obs;

  UserModel? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isUpdatingProfile => _isUpdatingProfile.value;
  bool get isUploadingImage => _isUploadingImage.value;
  String get profileImageUrl => _profileImageUrl.value;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      _isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _currentUser.value = UserModel.fromMap(doc.data()!, doc.id);
          _profileImageUrl.value = doc.data()?['profileImageUrl'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      _isUpdatingProfile.value = true;
      final user = _auth.currentUser;
      if (user != null && _currentUser.value != null) {
        final updatedUser = _currentUser.value!.copyWith(
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).update(updatedUser.toMap());
        _currentUser.value = updatedUser;
        Get.back();

        Get.snackbar('Success', 'Profile updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      _isUpdatingProfile.value = false;
    }
  }

  Future<void> updateProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _isUploadingImage.value = true;
        final user = _auth.currentUser;

        if (user != null) {
          final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
          await ref.putFile(File(image.path));
          final url = await ref.getDownloadURL();

          await _firestore.collection('users').doc(user.uid).update({
            'profileImageUrl': url,
            'updatedAt': DateTime.now().toIso8601String(),
          });

          _profileImageUrl.value = url;
          Get.snackbar('Success', 'Profile image updated successfully');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile image: $e');
    } finally {
      _isUploadingImage.value = false;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);
        Get.back();
        Get.snackbar('Success', 'Password changed successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  Future<Map<String, int>> getAdminStats() async {
    try {
      final ordersSnapshot = await _firestore.collection('orders').get();
      final usersSnapshot = await _firestore.collection('users').get();
      final productsSnapshot = await _firestore.collection('products').where('isActive', isEqualTo: true).get();

      return {
        'totalOrders': ordersSnapshot.docs.length,
        'totalUsers': usersSnapshot.docs.length,
        'totalProducts': productsSnapshot.docs.length,
      };
    } catch (e) {
      return {'totalOrders': 0, 'totalUsers': 0, 'totalProducts': 0};
    }
  }
}