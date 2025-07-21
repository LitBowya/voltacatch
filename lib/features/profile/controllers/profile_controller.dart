// lib/features/profile/controllers/profile_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/models/user_model.dart';
import '../../orders/models/order_model.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<OrderModel> userOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdatingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadOrderHistory();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          currentUser.value = UserModel.fromMap(doc.data()!, doc.id);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrderHistory() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

        userOrders.value = querySnapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data(), doc.id))
            .toList();

      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load order history: $e');
    }
  }

  Future<void> updateProfile({
     String? email,
     String? firstName,
     String? lastName,
     String? phoneNumber,
  }) async {
    try {
      isUpdatingProfile.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Update local user object
        if (currentUser.value != null) {
          currentUser.value = currentUser.value!.copyWith(
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            updatedAt: DateTime.now(),
          );
        }

        Get.back(); // Close bottom sheet
        Get.snackbar('Success', 'Profile updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: $e');
    }
  }
}