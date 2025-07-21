// lib/features/admin/home/widgets/latest_products.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class LatestProducts extends StatelessWidget {
  const LatestProducts({super.key});

  // Mock product data
  List<Map<String, dynamic>> get mockProducts => [
    {
      'name': 'Fresh Tomatoes',
      'price': '\$4.99',
      'category': 'Vegetables',
      'stock': 45,
    },
    {
      'name': 'Organic Apples',
      'price': '\$6.50',
      'category': 'Fruits',
      'stock': 32,
    },
    {
      'name': 'Free Range Eggs',
      'price': '\$8.99',
      'category': 'Dairy',
      'stock': 28,
    },
    {
      'name': 'Whole Wheat Bread',
      'price': '\$3.75',
      'category': 'Bakery',
      'stock': 15,
    },
    {
      'name': 'Fresh Carrots',
      'price': '\$2.99',
      'category': 'Vegetables',
      'stock': 67,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.dark,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockProducts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final product = mockProducts[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: TColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: TColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  product['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  product['category'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product['price'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Stock: ${product['stock']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}