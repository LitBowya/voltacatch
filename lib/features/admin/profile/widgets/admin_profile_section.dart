// lib/features/admin/profile/widgets/admin_profile_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_profile_controller.dart';
import 'profile_header.dart';
import 'profile_stats.dart';
import 'profile_menu.dart';

class AdminProfileSection extends StatelessWidget {
  const AdminProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.dark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ProfileHeader(controller: controller),
              const SizedBox(height: 24),
              ProfileStats(controller: controller),
              const SizedBox(height: 24),
              ProfileMenu(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}