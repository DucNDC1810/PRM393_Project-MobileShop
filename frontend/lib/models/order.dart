import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingInfo {
  final String name;
  final String phone;
  final String address;
  final String district;
  final String city;
  final String notes;

  const ShippingInfo({
    required this.name,
    required this.phone,
    required this.address,
    required this.district,
    required this.city,
    this.notes = '',
  });

  factory ShippingInfo.fromMap(Map<String, dynamic> data) => ShippingInfo(
        name: data['name'] as String? ?? '',
        phone: data['phone'] as String? ?? '',
        address: data['address'] as String? ?? '',
        district: data['district'] as String? ?? '',
        city: data['city'] as String? ?? '',
        notes: data['notes'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'address': address,
        'district': district,
        'city': city,
        'notes': notes,
      };
}

class Order {
  final String id;
  final String userEmail;
  final String status;
  final int total;
  final String paymentMethod;
  final ShippingInfo shippingInfo;
  final List<Map<String, dynamic>> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.userEmail,
    required this.status,
    required this.total,
    required this.paymentMethod,
    required this.shippingInfo,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final shippingRaw = data['shipping_info'] as Map<String, dynamic>? ?? {};
    final createdTs = data['created_at'] as Timestamp?;
    final updatedTs = data['updated_at'] as Timestamp?;
    return Order(
      id: doc.id,
      userEmail: data['user_email'] as String? ?? '',
      status: data['status'] as String? ?? 'Chờ xử lý',
      total: (data['total'] as num? ?? 0).toInt(),
      paymentMethod: data['payment_method'] as String? ?? 'cod',
      shippingInfo: ShippingInfo.fromMap(shippingRaw),
      items: List<Map<String, dynamic>>.from(data['items'] as List? ?? []),
      createdAt: createdTs?.toDate(),
      updatedAt: updatedTs?.toDate(),
    );
  }
}
