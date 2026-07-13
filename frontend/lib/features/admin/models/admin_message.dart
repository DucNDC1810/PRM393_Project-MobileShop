class AdminMessage {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderRole; // 'admin' or 'customer'
  final String message;
  final DateTime createdAt;
  final bool read;

  AdminMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.createdAt,
    required this.read,
  });

  factory AdminMessage.fromJson(Map<String, dynamic> json) {
    return AdminMessage(
      messageId: json['messageId'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderRole: json['senderRole'] ?? 'customer',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderRole': senderRole,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }
}
