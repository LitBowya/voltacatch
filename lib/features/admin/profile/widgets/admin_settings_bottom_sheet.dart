// lib/features/admin/profile/widgets/admin_settings_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_profile_controller.dart';

class AdminSettingsBottomSheet extends StatelessWidget {
  final AdminProfileController controller;

  const AdminSettingsBottomSheet({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, AdminProfileController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminSettingsBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar and header
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
                  'Admin Settings',
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

          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Manage notification settings',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      Get.snackbar('Info', 'Notification settings updated');
                    },
                    activeColor: TColors.primary,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Receive email updates',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      Get.snackbar('Info', 'Email notification settings updated');
                    },
                    activeColor: TColors.primary,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      Get.snackbar('Info', 'Theme will be updated in future version');
                    },
                    activeColor: TColors.primary,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () {
                    Get.snackbar('Info', 'Language settings coming soon');
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.backup_outlined,
                  title: 'Data Backup',
                  subtitle: 'Backup and restore data',
                  onTap: () {
                    Get.snackbar('Info', 'Data backup functionality coming soon');
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.security_outlined,
                  title: 'Security Settings',
                  subtitle: 'Manage security preferences',
                  onTap: () {
                    Get.snackbar('Info', 'Security settings coming soon');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: TColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}