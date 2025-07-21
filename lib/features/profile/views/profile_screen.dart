// lib/features/profile/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/edit_profile_bottom_sheet.dart';
import '../widgets/order_history_bottom_sheet.dart';
import '../widgets/help_support_bottom_sheet.dart';
import '../widgets/about_bottom_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Obx(() {
      final user = controller.currentUser.value;

      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: TColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: const ProfileHeader(),
              ),

              const SizedBox(height: 24),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildSectionHeader('Account'),
                    const SizedBox(height: 12),
                    ProfileMenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () => _showEditProfile(controller),
                    ),
                    const SizedBox(height: 8),
                    ProfileMenuItem(
                      icon: Icons.history_outlined,
                      title: 'Order History',
                      subtitle: 'View your past orders',
                      onTap: () => _showOrderHistory(controller),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader('Support'),
                    const SizedBox(height: 12),
                    ProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: _showHelpSupport,
                    ),
                    const SizedBox(height: 8),
                    ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'App version and information',
                      onTap: _showAbout,
                    ),

                    const SizedBox(height: 24),
                    // Logout Button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () => _showLogoutDialog(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[600],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.red[200]!),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_outlined, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),

        // ✅ Floating Action Button for Admins
        floatingActionButton: user?.isAdmin == true
            ? FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/admin'), // Or use Get.to(() => AdminScreen())
          backgroundColor: TColors.primary,
          icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
          label: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
        )
            : null,
      );
    });

  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _showEditProfile(ProfileController controller) {
    Get.bottomSheet(
      EditProfileBottomSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  void _showOrderHistory(ProfileController controller) {
    Get.bottomSheet(
      OrderHistoryBottomSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  void _showHelpSupport() {
    Get.bottomSheet(
      const HelpSupportBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  void _showAbout() {
    Get.bottomSheet(
      const AboutBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  void _showLogoutDialog(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}