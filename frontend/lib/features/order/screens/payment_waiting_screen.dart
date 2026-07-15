import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:project_mobileshop/features/wallet/services/payos_service.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/features/order/screens/order_success_screen.dart';

class PaymentWaitingScreen extends StatefulWidget {
  final int orderCode; // Mã đơn PayOS
  final String firebaseOrderId; // Mã đơn hiển thị (VD: #BG...)
  final String firebaseDocId; // ID của document trên Firestore
  final String checkoutUrl; // Link thanh toán để mở lại nếu cần
  final String qrCode; // Chuỗi VietQR để tạo ảnh QR

  const PaymentWaitingScreen({
    super.key,
    required this.orderCode,
    required this.firebaseOrderId,
    required this.firebaseDocId,
    required this.checkoutUrl,
    required this.qrCode,
  });

  @override
  State<PaymentWaitingScreen> createState() => _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends State<PaymentWaitingScreen> {
  Timer? _pollingTimer;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    // Cứ mỗi 3 giây sẽ gọi API kiểm tra trạng thái
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await PayOSService.getPaymentStatus(widget.orderCode);
        if (status == 'PAID') {
          timer.cancel();
          _handlePaymentSuccess();
        } else if (status == 'CANCELLED') {
          timer.cancel();
          _handlePaymentCancelled();
        }
      } catch (e) {
        // Có thể lỗi mạng tạm thời, cứ bỏ qua và poll tiếp
      }
    });
  }

  Future<void> _handlePaymentSuccess() async {
    // Cập nhật trạng thái đơn trên Firebase
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.firebaseDocId)
          .update({'status': 'Đã thanh toán'});
    } catch (e) {
      debugPrint('Failed to update payment status: $e');
    }

    // Chuyển sang màn hình Order Success
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(orderId: widget.firebaseOrderId),
        ),
      );
    }
  }

  Future<void> _handlePaymentCancelled() async {
    setState(() => _isCancelled = true);
    
    // Cập nhật trạng thái đơn bị hủy
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.firebaseDocId)
          .update({'status': 'Đã hủy (Thanh toán thất bại)'});
    } catch (e) {
      debugPrint('Failed to update cancelled payment status: $e');
    }
  }

  Future<void> _openPaymentLink() async {
    final url = Uri.parse(widget.checkoutUrl);
    await launchUrl(url, mode: LaunchMode.externalApplication).catchError((_) => false);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Đang chờ thanh toán',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(), // Quay lại giỏ hàng/checkout
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isCancelled 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Thanh toán đã bị hủy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bạn đã hủy thanh toán hoặc giao dịch thất bại. Vui lòng đặt lại đơn hàng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Quay lại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: QrImageView(
                    data: widget.qrCode,
                    version: QrVersions.auto,
                    size: 220.0,
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Đang chờ thanh toán...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vui lòng dùng app ngân hàng quét mã QR trên.\nTrạng thái sẽ được cập nhật tự động.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: _openPaymentLink,
                  icon: const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
                  label: const Text(
                    'Hoặc mở qua app ngân hàng',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }
}
