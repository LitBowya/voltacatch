// lib/features/checkout/models/shipping_address_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingAddressModel {
  final String id;
  final String userId;
  final String name;
  final String region;
  final String city;
  final String town;
  final String address1;
  final String address2;
  final String contact;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShippingAddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.region,
    required this.city,
    required this.town,
    required this.address1,
    required this.address2,
    required this.contact,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json, String id) {
    return ShippingAddressModel(
      id: id,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      city: json['city'] ?? '',
      town: json['town'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'] ?? '',
      contact: json['contact'] ?? '',
      isDefault: json['isDefault'] ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'region': region,
      'city': city,
      'town': town,
      'address1': address1,
      'address2': address2,
      'contact': contact,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get fullAddress {
    return '$address1, ${address2.isNotEmpty ? '$address2, ' : ''}$town, $city, $region';
  }

  ShippingAddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? region,
    String? city,
    String? town,
    String? address1,
    String? address2,
    String? contact,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShippingAddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      region: region ?? this.region,
      city: city ?? this.city,
      town: town ?? this.town,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      contact: contact ?? this.contact,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
