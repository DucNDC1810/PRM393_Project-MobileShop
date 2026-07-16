import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/core/utils/format_utils.dart';
import 'package:project_mobileshop/core/widgets/order_summary_row.dart';

class OrderDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> order;

  const OrderDetailScreen({
    super.key,
    required this.docId,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _editingAddress = false;
  bool _isSaving = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _notesCtrl;
  late String _selectedDistrict;

  final List<String> _districts = [
    'Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5',
    'Quận 7', 'Quận 10', 'Quận 12', 'Bình Thạnh',
    'Gò Vấp', 'Phú Nhuận', 'Tân Bình', 'Thủ Đức',
  ];

  @override
  void initState() {
    super.initState();
    final info = widget.order['shipping_info'] as Map<String, dynamic>? ?? {};
    _nameCtrl = TextEditingController(text: info['name'] as String? ?? '');
    _phoneCtrl = TextEditingController(text: info['phone'] as String? ?? '');
    _notesCtrl = TextEditingController(text: info['notes'] as String? ?? '');
    final district = info['district'] as String? ?? 'Quận 1';
    _selectedDistrict = _districts.contains(district) ? district : 'Quận 1';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canEditAddress {
    final status = widget.order['status'] as String? ?? '';
    return status == 'Chờ xử lý' || status == 'Đã xác nhận';
  }

  Future<void> _saveAddress() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ tên và số điện thoại.',
              style: TextStyle(fontFamily: 'DM Sans')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final info = widget.order['shipping_info'] as Map<String, dynamic>? ?? {};
      final updatedInfo = {
        ...info,
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'district': _selectedDistrict,
        'city': info['city'] ?? 'TP. Hồ Chí Minh',
        'notes': _notesCtrl.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.docId)
          .update({'shipping_info': updatedInfo});

      widget.order['shipping_info'] = updatedInfo;

      if (mounted) {
        setState(() => _editingAddress = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật địa chỉ giao hàng.',
                style: TextStyle(fontFamily: 'DM Sans')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thất bại, vui lòng thử lại.',
                style: TextStyle(fontFamily: 'DM Sans')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId =
        (widget.order['order_id'] as String? ?? widget.docId).substring(0, 8).toUpperCase();
    final status = widget.order['status'] as String? ?? 'Chờ xử lý';
    final items = widget.order['items'] as List? ?? [];
    final subtotal = (widget.order['subtotal'] as num? ?? 0).toInt();
    final discount = (widget.order['discount'] as num? ?? 0).toInt();
    final shippingFee = (widget.order['shipping_fee'] as num? ?? 0).toInt();
    final total = (widget.order['total'] as num? ?? 0).toInt();
    final paymentMethod = widget.order['payment_method'] as String? ?? '';
    final shippingMethod = widget.order['shipping_method'] as String? ?? '';
    final createdAt = widget.order['created_at'] as Timestamp?;
    final dateStr = createdAt != null ? formatDate(createdAt.toDate()) : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Đơn hàng #$orderId',
          style: const TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(status, dateStr),
            const SizedBox(height: 16),
            _buildAddressCard(),
            const SizedBox(height: 16),
            _buildItemsCard(items),
            const SizedBox(height: 16),
            _buildPaymentCard(
                paymentMethod, shippingMethod, subtotal, discount, shippingFee, total),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String status, String dateStr) {
    final statusColor = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(status), color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: statusColor),
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    'Đặt lúc $dateStr',
                    style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final info = widget.order['shipping_info'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Địa chỉ giao hàng',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.onSurface),
                  ),
                ],
              ),
              if (_canEditAddress)
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _editingAddress = !_editingAddress),
                  icon: Icon(
                    _editingAddress ? Icons.close : Icons.edit_outlined,
                    size: 16,
                    color: _editingAddress
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                  label: Text(
                    _editingAddress ? 'Hủy' : 'Sửa',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _editingAddress
                            ? AppColors.error
                            : AppColors.primary),
                  ),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_editingAddress) ...[
            _infoRow(Icons.person_outline, info['name'] as String? ?? '-'),
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, info['phone'] as String? ?? '-'),
            const SizedBox(height: 6),
            _infoRow(
              Icons.home_outlined,
              [
                if ((info['notes'] as String? ?? '').isNotEmpty) info['notes'],
                info['district'],
                info['city'] ?? 'TP. Hồ Chí Minh',
              ].whereType<String>().join(', '),
            ),
          ] else ...[
            _buildTextField(_nameCtrl, 'Họ và tên', Icons.person_outline),
            const SizedBox(height: 10),
            _buildTextField(_phoneCtrl, 'Số điện thoại', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              decoration: _inputDecoration('Quận / Huyện', Icons.map_outlined),
              items: _districts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14))))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDistrict = v!),
            ),
            const SizedBox(height: 10),
            _buildTextField(_notesCtrl, 'Số nhà / Tên đường', Icons.home_outlined),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Lưu địa chỉ',
                        style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
              ),
            ),
          ],
          if (!_canEditAddress && !_editingAddress) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.orange),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Không thể sửa địa chỉ khi đơn đang được xử lý.',
                      style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(List items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sản phẩm (${items.length})',
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.onSurface),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 20, color: AppColors.outlineVariant),
            itemBuilder: (context, idx) {
              final item = items[idx] as Map<String, dynamic>;
              final emoji = item['emoji'] as String? ?? '✨';
              final name = item['name'] as String? ?? 'Sản phẩm';
              final brand = item['brand'] as String? ?? '';
              final qty = (item['quantity'] as num? ?? 1).toInt();
              final price = (item['price'] as num? ?? 0).toInt();
              final imagesList = item['images'];
              String? imageUrl;
              if (imagesList is List && imagesList.isNotEmpty) {
                imageUrl = imagesList.first?.toString();
              }
              final hasImage =
                  imageUrl != null && imageUrl.startsWith('http');

              return Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.network(imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                    child: Text(emoji,
                                        style: const TextStyle(fontSize: 28)))),
                          )
                        : Center(
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.onSurface),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if (brand.isNotEmpty)
                          Text(brand,
                              style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('x$qty',
                                style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant)),
                            Text(formatPrice(price),
                                style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String paymentMethod, String shippingMethod,
      int subtotal, int discount, int shippingFee, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thanh toán',
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.onSurface),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.local_shipping_outlined, shippingMethod.isNotEmpty ? shippingMethod : 'Giao hàng tiêu chuẩn'),
          const SizedBox(height: 6),
          _infoRow(Icons.payment_outlined, paymentMethod.isNotEmpty ? paymentMethod : 'COD'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.outlineVariant),
          ),
          OrderSummaryRow('Tạm tính', subtotal),
          if (discount > 0) ...[
            const SizedBox(height: 4),
            OrderSummaryRow('Giảm giá', -discount, isDiscount: true),
          ],
          const SizedBox(height: 4),
          OrderSummaryRow('Phí vận chuyển', shippingFee, isFree: shippingFee == 0),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.outlineVariant),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.onSurface),
              ),
              Text(
                formatPrice(total),
                style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.onSurface,
                height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14),
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'DM Sans', fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Hoàn thành':
        return AppColors.success;
      case 'Đã hủy':
        return AppColors.error;
      case 'Đang giao':
        return Colors.orange;
      case 'Đã xác nhận':
        return const Color(0xFF1E40AF);
      default:
        return AppColors.primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Hoàn thành':
        return Icons.check_circle_outline;
      case 'Đã hủy':
        return Icons.cancel_outlined;
      case 'Đang giao':
        return Icons.local_shipping_outlined;
      case 'Đã xác nhận':
        return Icons.verified_outlined;
      case 'Đang thanh toán':
        return Icons.qr_code_outlined;
      default:
        return Icons.hourglass_empty_outlined;
    }
  }
}
