// lib/features/admin/profile/widgets/change_password_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_profile_controller.dart';

class ChangePasswordBottomSheet extends StatelessWidget {
  final AdminProfileController controller;

  const ChangePasswordBottomSheet({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, AdminProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangePasswordBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isLoading = false.obs;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar and header (same as edit profile)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const Spacer(),

                  // Change Password Button
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (newPasswordController.text != confirmPasswordController.text) {
                                  Get.snackbar('Error', 'Passwords do not match');
                                  return;
                                }

                                if (newPasswordController.text.length < 6) {
                                  Get.snackbar('Error', 'Password must be at least 6 characters');
                                  return;
                                }

                                isLoading.value = true;
                                await controller.changePassword(
                                  currentPasswordController.text,
                                  newPasswordController.text,
                                );
                                isLoading.value = false;
                                Get.back();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Change Password'),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}