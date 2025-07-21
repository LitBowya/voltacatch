// lib/features/admin/profile/widgets/profile_stats.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../controllers/admin_profile_controller.dart';

class ProfileStats extends StatelessWidget {
  final AdminProfileController controller;

  const ProfileStats({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, int>>(
            future: controller.getAdminStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data ?? {'totalOrders': 0, 'totalUsers': 0, 'totalProducts': 0};

              return Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Orders',
                      stats['totalOrders'].toString(),
                      Icons.shopping_bag,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Users',
                      stats['totalUsers'].toString(),
                      Icons.people,
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Products',
                      stats['totalProducts'].toString(),
                      Icons.inventory,
                      Colors.orange,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}