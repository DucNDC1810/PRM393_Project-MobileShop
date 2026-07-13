import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';

import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/features/wallet/services/payos_service.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/core/widgets/custom_toast.dart';

class DepositWaitingScreen extends StatefulWidget {
  final int orderCode; // Mã đơn PayOS
  final String checkoutUrl; // Link thanh toán
  final String qrCode; // Chuỗi VietQR
  final int amount; // Số tiền nạp
  final VoidCallback onSuccess;

  const DepositWaitingScreen({
    super.key,
    required this.orderCode,
    required this.checkoutUrl,
    required this.qrCode,
    required this.amount,
    required this.onSuccess,
  });

  @override
  State<DepositWaitingScreen> createState() => _DepositWaitingScreenState();
}

class _DepositWaitingScreenState extends State<DepositWaitingScreen> {
  Timer? _pollingTimer;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await PayOSService.getPaymentStatus(widget.orderCode);
        if (status == 'PAID') {
          timer.cancel();
          _handleDepositSuccess();
        } else if (status == 'CANCELLED') {
          timer.cancel();
          setState(() => _isCancelled = true);
        }
      } catch (e) {
        // ignore network error
      }
    });
  }

  Future<void> _handleDepositSuccess() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(auth.user!.uid);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        int currentBalance = 0;
        if (snapshot.exists && snapshot.data()!.containsKey('wallet_balance')) {
          currentBalance = snapshot.get('wallet_balance');
        }
        transaction.update(docRef, {'wallet_balance': currentBalance + widget.amount});
      });
      
      // Save transaction
      await FirebaseFirestore.instance.collection('wallet_transactions').add({
        'user_uid': auth.user!.uid,
        'type': 'deposit',
        'amount': widget.amount,
        'status': 'completed',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        CustomToast.showSuccess(context, 'Nạp tiền thành công!');
        widget.onSuccess();
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        CustomToast.showError(context, 'Lỗi cập nhật số dư.');
        Navigator.of(context).pop();
      }
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
        title: const Text('Đang chờ nạp tiền', style: TextStyle(fontFamily: 'DM Sans', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
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
                const Text('Giao dịch đã bị hủy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface, fontFamily: 'DM Sans')),
                const SizedBox(height: 12),
                const Text('Bạn đã hủy nạp tiền hoặc giao dịch thất bại.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans')),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Quay lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outlineVariant)),
                  child: QrImageView(
                    data: widget.qrCode,
                    version: QrVersions.auto,
                    size: 220.0,
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                const Text('Đang chờ thanh toán nạp tiền...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface, fontFamily: 'DM Sans')),
                const SizedBox(height: 12),
                const Text('Vui lòng dùng app ngân hàng quét mã QR trên.\nSố dư sẽ tự động được cộng sau khi thanh toán thành công.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans')),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: _openPaymentLink,
                  icon: const Icon(Icons.open_in_new_rounded, color: AppColors.primary),
                  label: const Text('Hoặc mở qua app ngân hàng', style: TextStyle(color: AppColors.primary, fontFamily: 'DM Sans', fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
