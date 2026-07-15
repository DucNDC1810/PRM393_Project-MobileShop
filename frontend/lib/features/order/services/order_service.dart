import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:project_mobileshop/features/notification/services/notification_service.dart';
import 'package:project_mobileshop/features/wallet/services/payos_service.dart';

enum PlaceOrderResult { success, payos, insufficientBalance, error }

class OrderResult {
  final PlaceOrderResult result;
  final String orderId;
  final String? docId;
  final String? checkoutUrl;
  final String? qrCode;
  final int? orderCode;
  final String? errorMessage;

  const OrderResult({
    required this.result,
    required this.orderId,
    this.docId,
    this.checkoutUrl,
    this.qrCode,
    this.orderCode,
    this.errorMessage,
  });
}

class OrderService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<int> getWalletBalance(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['wallet_balance'] as num? ?? 0).toInt();
  }

  static Future<OrderResult> placeOrder({
    required String? userUid,
    required String? userEmail,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingInfo,
    required String shippingMethod,
    required String paymentMethod,
    required int subtotal,
    required int discount,
    required int shippingFee,
    required int total,
    required String orderId,
  }) async {
    try {
      final int orderCode = DateTime.now().millisecondsSinceEpoch;

      final docRef = await _db.collection('orders').add({
        'order_id': orderId,
        'user_email': userEmail,
        'user_uid': userUid,
        'shipping_info': shippingInfo,
        'shipping_method': shippingMethod == 'standard' ? 'Giao hàng tiêu chuẩn' : 'Giao hàng nhanh',
        'payment_method': paymentMethod == 'cod'
            ? 'Thanh toán khi nhận hàng'
            : (paymentMethod == 'payos' ? 'Thanh toán chuyển khoản' : 'Thanh toán bằng số dư ví'),
        'items': items,
        'subtotal': subtotal,
        'discount': discount,
        'shipping_fee': shippingFee,
        'total': total,
        'status': paymentMethod == 'payos' ? 'Đang thanh toán' : 'Chờ xử lý',
        'order_code': paymentMethod == 'payos' ? orderCode : null,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (userUid != null) {
        final short = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
        await NotificationService.push(
          userUid: userUid,
          title: 'Đặt hàng thành công 🎉',
          body: 'Đơn hàng #$short của bạn đã được tiếp nhận và đang chờ xác nhận.',
          type: 'order',
          extra: {'order_id': orderId},
        );
      }

      if (paymentMethod == 'payos') {
        final payosData = await PayOSService.createPaymentLink(
          orderCode: orderCode,
          amount: total,
          description: 'Thanh toan don hang',
        );
        final checkoutUrl = payosData['checkoutUrl'] as String? ?? '';
        final qrCode = payosData['qrCode'] as String? ?? '';
        await docRef.update({'checkout_url': checkoutUrl, 'qr_code': qrCode});
        return OrderResult(
          result: PlaceOrderResult.payos,
          orderId: orderId,
          docId: docRef.id,
          checkoutUrl: checkoutUrl,
          qrCode: qrCode,
          orderCode: orderCode,
        );
      }

      if (paymentMethod == 'wallet' && userUid != null) {
        await _db.runTransaction((transaction) async {
          final userDocRef = _db.collection('users').doc(userUid);
          final snapshot = await transaction.get(userDocRef);
          final currentBalance = (snapshot.data()?['wallet_balance'] as num? ?? 0).toInt();
          transaction.update(userDocRef, {'wallet_balance': currentBalance - total});
        });
        await _db.collection('wallet_transactions').add({
          'user_uid': userUid,
          'type': 'payment',
          'amount': total,
          'status': 'completed',
          'order_id': orderId,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return OrderResult(result: PlaceOrderResult.success, orderId: orderId, docId: docRef.id);
    } catch (e) {
      debugPrint('OrderService.placeOrder error: $e');
      return OrderResult(result: PlaceOrderResult.error, orderId: orderId, errorMessage: e.toString());
    }
  }

  static Future<void> saveAddress(String uid, Map<String, dynamic> address, List<Map<String, dynamic>> addresses) async {
    try {
      await _db.collection('users').doc(uid).update({'saved_addresses': addresses});
    } catch (e) {
      debugPrint('OrderService.saveAddress error: $e');
    }
  }
}
