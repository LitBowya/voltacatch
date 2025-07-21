import 'package:flutter/material.dart';

import '../../../core/widgets/product_card.dart';
import '../../admin/products/models/product_model.dart';

class MostExpensiveProductsWidget extends StatelessWidget {
  final List<ProductModel> products;

  const MostExpensiveProductsWidget({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final expensiveProducts = products.toList()
      ..sort((a, b) => b.price.compareTo(a.price));

    final displayProducts = expensiveProducts.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Expensive Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: displayProducts
              .map((product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCard(product: product),
          ))
              .toList(),
        ),
      ],
    );
  }
}
