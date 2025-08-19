
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_profile_controller.dart';
import 'change_password_bottom_sheet.dart';

class ProfileMenu extends StatelessWidget {
  final AdminProfileController controller;

  const ProfileMenu({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.1).toInt()),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              ChangePasswordBottomSheet.show(context, controller);
            },
          ),
          _buildDivider(),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.home_rounded,
            title: 'Go Home',
            subtitle: 'Return to home screen',
            customColor: Colors.green,
            onTap: () {
              _showGoHomeDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out from your account',
            onTap: () {
              _showSignOutDialog(context);
            },
            isDestructive: true,
          ),

        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? customColor,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withAlpha((255 * 0.1).toInt())
              : TColors.primary.withAlpha((255 * 0.1).toInt()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: customColor ?? (isDestructive ? Colors.red : TColors.primary),
          size: 20,
        ),

      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 16,
      endIndent: 16,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showGoHomeDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Go Home'),
        content: const Text('Are you sure you want to go home?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.offAllNamed('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go Home'),
          ),
        ],
      ),
    );
  }

}