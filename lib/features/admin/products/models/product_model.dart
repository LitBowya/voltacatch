// lib/features/admin/products/models/product_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String categoryName;
  final int stock;
  final List<String> images;
  final String size;
  final String origin;
  final double weight;
  final String waterType;
  final String ph;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.stock,
    required this.images,
    required this.size,
    required this.origin,
    required this.weight,
    required this.waterType,
    required this.ph,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'stock': stock,
      'images': images,
      'size': size,
      'origin': origin,
      'weight': weight,
      'waterType': waterType,
      'ph': ph,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ProductModel(
      id: documentId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      stock: json['stock'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      size: json['size'] ?? '',
      origin: json['origin'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      waterType: json['waterType'] ?? '',
      ph: json['ph'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? categoryName,
    int? stock,
    List<String>? images,
    String? species,
    String? size,
    String? origin,
    double? weight,
    String? waterType,
    String? careLevel,
    String? temperament,
    int? minTankSize,
    String? temperature,
    String? ph,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      stock: stock ?? this.stock,
      images: images ?? this.images,
      size: size ?? this.size,
      origin: origin ?? this.origin,
      weight: weight ?? this.weight,
      waterType: waterType ?? this.waterType,
      ph: ph ?? this.ph,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}