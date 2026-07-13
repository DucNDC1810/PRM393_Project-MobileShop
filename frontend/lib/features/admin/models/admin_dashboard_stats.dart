class AdminDashboardStats {
  final int totalProducts;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int totalCustomers;
  final double revenueToday;
  final double revenueThisMonth;

  AdminDashboardStats({
    required this.totalProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalCustomers,
    required this.revenueToday,
    required this.revenueThisMonth,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      totalCustomers: json['totalCustomers'] ?? 0,
      revenueToday: (json['revenueToday'] ?? 0).toDouble(),
      revenueThisMonth: (json['revenueThisMonth'] ?? 0).toDouble(),
    );
  }
}
