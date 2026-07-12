class AdminOrder {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final double total;
  final String paymentMethod;
  final String status;

  AdminOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.orderDate,
    required this.total,
    required this.paymentMethod,
    required this.status,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? 'Unknown Customer',
      orderDate: json['orderDate'] != null 
          ? DateTime.parse(json['orderDate']) 
          : DateTime.now(),
      total: (json['total'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'COD',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'orderDate': orderDate.toIso8601String(),
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }
}
