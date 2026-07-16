import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> push({
    required String userUid,
    required String title,
    required String body,
    String type = 'order',
    Map<String, dynamic>? extra,
  }) async {
    await _db.collection('notifications').add({
      'user_uid': userUid,
      'title': title,
      'body': body,
      'type': type,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
      if (extra != null) 'extra': extra,
    });
  }

  static String orderStatusTitle(String status) {
    switch (status) {
      case 'Đã xác nhận': return 'Đơn hàng đã xác nhận ✅';
      case 'Đang giao':   return 'Đơn hàng đang được giao 🚚';
      case 'Hoàn thành':  return 'Đơn hàng đã giao thành công 🎉';
      case 'Đã hủy':      return 'Đơn hàng đã bị hủy ❌';
      default:            return 'Cập nhật đơn hàng';
    }
  }

  static String orderStatusBody(String status, String orderId) {
    final short = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
    switch (status) {
      case 'Đã xác nhận':
        return 'Đơn hàng #$short của bạn đã được xác nhận và đang chuẩn bị hàng.';
      case 'Đang giao':
        return 'Đơn hàng #$short đang trên đường đến tay bạn, hãy chú ý điện thoại nhé!';
      case 'Hoàn thành':
        return 'Đơn hàng #$short đã giao thành công. Cảm ơn bạn đã mua sắm tại Beauty & Glow!';
      case 'Đã hủy':
        return 'Đơn hàng #$short đã bị hủy. Liên hệ hỗ trợ nếu bạn cần giúp đỡ.';
      default:
        return 'Trạng thái đơn hàng #$short đã được cập nhật: $status.';
    }
  }
}
