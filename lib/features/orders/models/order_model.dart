// lib/features/orders/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../cart/models/cart_model.dart';
import '../../checkout/models/shipping_model.dart';

enum OrderStatus { pending, confirmed, shipped, delivered }

class OrderModel {
  final String id;
  final String userId;
  final List<CartModel> items;
  final ShippingAddressModel shippingAddress;
  final double subtotal;
  final double shippingFee;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    this.shippingFee = 0.0,
    required this.totalPrice,
    this.status = OrderStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, String id) {
    return OrderModel(
      id: id,
      userId: json['userId'] ?? '',
      items: (json['items'] as List)
          .map((item) => CartModel.fromJson(item, item['id'] ?? ''))
          .toList(),
      shippingAddress: ShippingAddressModel.fromJson(
          json['shippingAddress'], json['shippingAddress']['id'] ?? ''),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}