// lib/features/cart/models/cart_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../admin/products/models/product_model.dart';

class CartModel {
  final String id;
  final String userId;
  final String productId;
  final ProductModel product;
  final int quantity;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json, String id) {
    return CartModel(
      id: id,
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      product: ProductModel.fromJson(json['product'], json['productId']),
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'product': product.toJson(),
      'quantity': quantity,
      'totalPrice': totalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CartModel copyWith({
    String? id,
    String? userId,
    String? productId,
    ProductModel? product,
    int? quantity,
    double? totalPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}