// lib/features/admin/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_profile_controller.dart';
import 'edit_profile_bottom_sheet.dart';

class ProfileHeader extends StatelessWidget {
  final AdminProfileController controller;

  const ProfileHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              Obx(() {
                return CircleAvatar(
                  radius: 50,
                  backgroundColor: TColors.primary.withOpacity(0.1),
                  backgroundImage: controller.profileImageUrl.isNotEmpty
                      ? NetworkImage(controller.profileImageUrl)
                      : null,
                  child: controller.profileImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: TColors.primary,
                        )
                      : null,
                );
              }),

            ],
          ),
          const SizedBox(height: 16),

          // User Info
          Obx(() {
            final user = controller.currentUser;
            return Column(
              children: [
                Text(
                  user?.fullName ?? 'Admin User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Administrator',
                    style: TextStyle(
                      color: TColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                EditProfileBottomSheet.show(context, controller);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}