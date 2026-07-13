class AdminConversation {
  final String conversationId;
  final String orderId;
  final String customerId;
  final String adminId;
  final String customerName;
  final String customerAvatar;
  final String latestMessage;
  final int unreadCount;
  final DateTime updatedAt;

  AdminConversation({
    required this.conversationId,
    required this.orderId,
    required this.customerId,
    required this.adminId,
    required this.customerName,
    required this.customerAvatar,
    required this.latestMessage,
    required this.unreadCount,
    required this.updatedAt,
  });

  factory AdminConversation.fromJson(Map<String, dynamic> json) {
    return AdminConversation(
      conversationId: json['conversationId'] ?? '',
      orderId: json['orderId'] ?? '',
      customerId: json['customerId'] ?? '',
      adminId: json['adminId'] ?? '',
      customerName: json['customerName'] ?? 'Unknown Customer',
      customerAvatar: json['customerAvatar'] ?? '',
      latestMessage: json['latestMessage'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }
}
