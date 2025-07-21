// lib/features/admin/orders/views/admin_orders_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../widgets/order_list.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TColors.dark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const OrderList(),
    );
  }
}