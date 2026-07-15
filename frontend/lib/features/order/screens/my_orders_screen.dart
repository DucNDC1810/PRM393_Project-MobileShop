import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/core/utils/format_utils.dart';
import 'package:project_mobileshop/features/chat/screens/chat_screen.dart';
import 'package:project_mobileshop/features/review/screens/review_screen.dart';
import 'package:project_mobileshop/features/wallet/services/payos_service.dart';
import 'package:project_mobileshop/features/order/screens/payment_waiting_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  // Keep stream reference stable so it doesn't recreate on rebuild
  Stream<QuerySnapshot>? _ordersStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ordersStream != null) return;
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _ordersStream = FirebaseFirestore.instance
          .collection('orders')
          .where('user_email', isEqualTo: user.email)
          .orderBy('created_at', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Vui lòng đăng nhập để xem lịch sử đơn hàng.',
                style: TextStyle(fontFamily: 'DM Sans'),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _ordersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Lỗi: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'DM Sans', color: AppColors.error),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📦', style: TextStyle(fontSize: 64)),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có đơn hàng nào',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Đơn hàng bạn đặt sẽ xuất hiện tại đây.',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) =>
                      _OrderCard(orderDoc: docs[index]),
                );
              },
            ),
    );
  }
}

/// Card hiển thị thông tin một đơn hàng trong danh sách lịch sử.
class _OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot orderDoc;

  const _OrderCard({required this.orderDoc});

  @override
  Widget build(BuildContext context) {
    final order = orderDoc.data() as Map<String, dynamic>;
    final orderId = orderDoc.id.substring(0, 8).toUpperCase();
    final items = order['items'] as List? ?? [];
    final total = (order['total'] ?? 0) as num;
    final status = order['status'] as String? ?? 'Chờ xử lý';
    final paymentMethod = order['payment_method'] as String? ?? '';
    final orderCode = (order['order_code'] as num?)?.toInt();
    final checkoutUrl = order['checkout_url'] as String? ?? '';
    final qrCode = order['qr_code'] as String? ?? '';
    final createdAt = order['created_at'] as Timestamp?;
    final dateStr =
        createdAt != null ? formatDate(createdAt.toDate()) : 'Vừa xong';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderHeader(orderId: orderId, dateStr: dateStr, status: status),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.outlineVariant),
          ),
          _OrderItemsList(items: items),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.outlineVariant),
          ),
          _OrderFooter(
            orderId: orderId,
            status: status,
            total: total,
            items: items,
            dateStr: dateStr,
            docId: orderDoc.id,
            paymentMethod: paymentMethod,
            orderCode: orderCode,
            checkoutUrl: checkoutUrl,
            qrCode: qrCode,
          ),
        ],
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final String orderId;
  final String dateStr;
  final String status;

  const _OrderHeader({
    required this.orderId,
    required this.dateStr,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MÃ ĐƠN: #$orderId',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dateStr,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        _StatusBadge(status: status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFF92400E);

    if (status == 'Đang giao') {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFF9A3412);
    } else if (status == 'Hoàn thành') {
      bg = const Color(0xFFD1FAE5);
      fg = AppColors.success;
    } else if (status == 'Đã hủy') {
      bg = const Color(0xFFFFE4E6);
      fg = AppColors.error;
    } else if (status == 'Đã xác nhận') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1E40AF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: fg,
        ),
      ),
    );
  }
}

class _OrderItemsList extends StatelessWidget {
  final List items;

  const _OrderItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final item = items[idx] as Map<String, dynamic>;
        final String emoji = item['emoji'] as String? ?? '✨';
        final String name = item['name'] as String? ?? 'Sản phẩm';
        final String brand = item['brand'] as String? ?? '';
        final int qty = (item['quantity'] as num? ?? 1).toInt();
        final int price = (item['price'] as num? ?? 0).toInt();

        final imagesList = item['images'];
        String? imageUrl;
        if (imagesList is List && imagesList.isNotEmpty) {
          imageUrl = imagesList.first?.toString();
        } else if (item['image_url'] != null) {
          imageUrl = item['image_url'].toString();
        }
        final bool hasImage =
            imageUrl != null && imageUrl.startsWith('http');

        return Row(
          children: [
            _ItemThumbnail(emoji: emoji, imageUrl: hasImage ? imageUrl : null),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (brand.isNotEmpty)
                    Text(
                      brand,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  Text(
                    'x$qty  •  ${formatPrice(price)}',
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  final String emoji;
  final String? imageUrl;

  const _ItemThumbnail({required this.emoji, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
              ),
            )
          : Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
    );
  }
}

class _OrderFooter extends StatefulWidget {
  final String orderId;
  final String status;
  final num total;
  final List items;
  final String dateStr;
  final String docId;
  final String paymentMethod;
  final int? orderCode;
  final String checkoutUrl;
  final String qrCode;

  const _OrderFooter({
    required this.orderId,
    required this.status,
    required this.total,
    required this.items,
    required this.dateStr,
    required this.docId,
    required this.paymentMethod,
    required this.orderCode,
    required this.checkoutUrl,
    required this.qrCode,
  });

  @override
  State<_OrderFooter> createState() => _OrderFooterState();
}

class _OrderFooterState extends State<_OrderFooter> {
  bool _isLoading = false;

  bool get _isBankTransfer =>
      widget.paymentMethod == 'Thanh toán chuyển khoản';

  bool get _isWalletPayment =>
      widget.paymentMethod == 'Thanh toán bằng số dư ví';

  Future<void> _resumePayment() async {
    if (widget.orderCode == null) return;

    // Nếu đã có QR trong Firestore thì dùng luôn, không gọi API
    if (widget.qrCode.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentWaitingScreen(
            orderCode: widget.orderCode!,
            firebaseOrderId: widget.orderId,
            firebaseDocId: widget.docId,
            checkoutUrl: widget.checkoutUrl,
            qrCode: widget.qrCode,
          ),
        ),
      );
      return;
    }

    // Fallback: lấy lại checkoutUrl và qrCode từ PayOS API
    setState(() => _isLoading = true);
    try {
      final info = await PayOSService.getPaymentInfo(widget.orderCode!);
      final checkoutUrl = info['checkoutUrl'] as String? ?? '';
      final qrCode = info['qrCode'] as String? ?? '';

      if (qrCode.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy mã QR cho đơn hàng này.',
                  style: TextStyle(fontFamily: 'DM Sans')),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Lưu lại vào Firestore để lần sau không cần gọi API
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.docId)
          .update({'checkout_url': checkoutUrl, 'qr_code': qrCode});

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentWaitingScreen(
            orderCode: widget.orderCode!,
            firebaseOrderId: widget.orderId,
            firebaseDocId: widget.docId,
            checkoutUrl: checkoutUrl,
            qrCode: qrCode,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lấy mã QR: $e',
                style: const TextStyle(fontFamily: 'DM Sans')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy đơn hàng',
            style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
        content: Text(
          (_isBankTransfer || _isWalletPayment)
              ? 'Bạn có chắc muốn hủy đơn này? Tiền sẽ được hoàn lại vào ví của bạn.'
              : 'Bạn có chắc muốn hủy đơn hàng này không?',
          style: const TextStyle(fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hủy đơn',
                style: TextStyle(
                    fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Lấy user trước khi vào async để tránh context across async gap
    final user = context.read<AuthProvider>().user;
    setState(() => _isLoading = true);
    try {
      final db = FirebaseFirestore.instance;
      final orderRef = db.collection('orders').doc(widget.docId);

      // Xác định có hoàn tiền không
      bool shouldRefund = false;

      if (_isWalletPayment) {
        // Thanh toán bằng ví → luôn hoàn tiền khi hủy
        shouldRefund = true;
      } else if (_isBankTransfer && widget.orderCode != null) {
        // Chuyển khoản PayOS → kiểm tra trạng thái thanh toán
        try {
          final payosStatus =
              await PayOSService.getPaymentStatus(widget.orderCode!);
          shouldRefund = payosStatus == 'PAID';
        } catch (_) {
          // Không kiểm tra được → không hoàn tiền tự động
        }
      }

      if (shouldRefund && user != null) {
        final userRef = db.collection('users').doc(user.uid);
        await db.runTransaction((txn) async {
          final userSnap = await txn.get(userRef);
          final currentBalance =
              (userSnap.data()?['wallet_balance'] as num? ?? 0).toInt();
          final refundAmount = widget.total.toInt();
          txn.update(userRef,
              {'wallet_balance': currentBalance + refundAmount});
          txn.update(orderRef, {'status': 'Đã hủy'});
          txn.set(
            db.collection('wallet_transactions').doc(),
            {
              'user_uid': user.uid,
              'user_email': user.email,
              'type': 'refund',
              'amount': refundAmount,
              'description': 'Hoàn tiền đơn hàng #${widget.orderId}',
              'order_id': widget.docId,
              'created_at': FieldValue.serverTimestamp(),
            },
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã hủy đơn và hoàn ${formatPrice(widget.total)} vào ví của bạn.',
                style: const TextStyle(fontFamily: 'DM Sans'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await orderRef.update({'status': 'Đã hủy'});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đơn hàng đã được hủy.',
                  style: TextStyle(fontFamily: 'DM Sans')),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra, vui lòng thử lại.',
                style: TextStyle(fontFamily: 'DM Sans')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tổng cộng (${widget.items.length} món):',
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              formatPrice(widget.total),
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      orderInfo: {
                        'orderId': widget.orderId,
                        'status': status,
                        'total': widget.total,
                        'items': widget.items,
                        'date': widget.dateStr,
                      },
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Liên hệ hỗ trợ',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (status == 'Đang thanh toán' && _isBankTransfer) ...[
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resumePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Thanh toán',
                          style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancelOrder,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Hủy đơn',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else if (status == 'Hoàn thành') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      showReviewSheet(context, widget.docId, widget.items),
                  icon: const Icon(Icons.star_outline, size: 16),
                  label: const Text(
                    'Đánh giá',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBC02D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ] else if (status.toLowerCase().contains('giao') &&
                status.toLowerCase() != 'hoàn thành') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _confirmReceived(context, widget.docId),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text(
                    'Đã nhận hàng',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
            ] else if (status.toLowerCase() != 'đã hủy') ...[
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showTrackingDialog(
                      context, status, widget.orderId, widget.dateStr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Theo dõi đơn',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showTrackingDialog(
      BuildContext context, String status, String orderId, String dateStr) {
    final steps = [
      {'label': 'Chờ xử lý', 'icon': Icons.hourglass_empty_outlined},
      {'label': 'Đã xác nhận', 'icon': Icons.check_circle_outline},
      {'label': 'Đang giao', 'icon': Icons.local_shipping_outlined},
      {'label': 'Hoàn thành', 'icon': Icons.done_all},
    ];

    final currentIndex = steps.indexWhere((s) => s['label'] == status);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Theo dõi đơn #$orderId',
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.onSurface)),
                if (dateStr.isNotEmpty)
                  Text(dateStr,
                      style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 20),
                ...steps.asMap().entries.map((e) {
                  final i = e.key;
                  final step = e.value;
                  final isDone = currentIndex >= 0 && i <= currentIndex;
                  final isCurrent = i == currentIndex;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDone ? AppColors.primary : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(step['icon'] as IconData,
                                size: 18,
                                color: isDone ? Colors.white : Colors.grey),
                          ),
                          if (i < steps.length - 1)
                            Container(
                                width: 2,
                                height: 28,
                                color: i < currentIndex
                                    ? AppColors.primary
                                    : Colors.grey.shade200),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          step['label'] as String,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            fontWeight:
                                isCurrent ? FontWeight.w800 : FontWeight.w500,
                            color: isCurrent
                                ? AppColors.primary
                                : isDone
                                    ? AppColors.onSurface
                                    : Colors.grey,
                          ),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text('Hiện tại',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        elevation: 0),
                    child: const Text('Đóng',
                        style: TextStyle(
                            fontFamily: 'DM Sans', fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReceived(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đã nhận hàng',
            style:
                TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
        content: const Text(
            'Bạn xác nhận đã nhận được hàng và đơn hàng này sẽ được hoàn tất?',
            style: TextStyle(fontFamily: 'DM Sans')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Xác nhận',
                style: TextStyle(
                    fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(docId)
          .update({
        'status': 'Hoàn thành',
        'received_at': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Cảm ơn bạn! Đơn hàng đã được xác nhận hoàn tất.',
                style: TextStyle(fontFamily: 'DM Sans')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Có lỗi xảy ra, vui lòng thử lại.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}
