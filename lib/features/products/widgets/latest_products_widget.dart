import 'package:flutter/material.dart';
import '../../../core/widgets/product_card.dart';
import '../../admin/products/models/product_model.dart';

class LatestProductsWidget extends StatelessWidget {
  final List<ProductModel> products;

  const LatestProductsWidget({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final latestProducts = products
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final displayProducts = latestProducts.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Products',
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
