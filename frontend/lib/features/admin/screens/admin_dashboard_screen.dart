import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/features/notification/services/notification_service.dart';
import 'package:project_mobileshop/features/product/providers/product_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/features/admin/screens/admin_chat_detail_screen.dart';
import 'package:project_mobileshop/features/admin/screens/admin_product_form_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
          onPressed: _handleLogout,
          tooltip: 'Đăng xuất',
        ),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: AppColors.primary, size: 18),
              label: const Text(
                'Đăng xuất',
                style: TextStyle(color: AppColors.primary, fontFamily: 'DM Sans', fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'DM Sans'),
          tabs: const [
            Tab(text: 'Kho hàng'),
            Tab(text: 'Đơn hàng'),
            Tab(text: 'Hỗ trợ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _InventoryTab(),
          _OrdersTab(),
          _CustomerSupportTab(),
        ],
      ),
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab();

  void _deleteProduct(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await context.read<ProductProvider>().deleteProduct(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa sản phẩm thành công')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Search Bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Add New Product Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProductFormScreen()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Thêm sản phẩm mới',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Product List
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final stock = (product['stock'] as num?)?.toInt() ?? 0;
                      final isLowStock = stock < 10;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: product['images'] != null && (product['images'] as List).isNotEmpty
                                  ? Image.network(
                                      product['images'][0],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image, color: Colors.grey),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(product['price'] ?? 0),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isLowStock ? const Color(0xFFFFE5E5) : const Color(0xFFEBE3DF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isLowStock ? 'Low Stock: $stock' : 'Stock: $stock',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isLowStock ? Colors.red.shade700 : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Action Icons
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 22),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AdminProductFormScreen(product: product)),
                                    );
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.primary, size: 22),
                                  onPressed: () => _deleteProduct(context, product['id']),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  static const List<String> _statuses = [
    'Chờ xử lý',
    'Đã xác nhận',
    'Đang giao',
    'Hoàn thành',
    'Đã hủy',
  ];

  Future<void> _updateStatus(BuildContext context, String docId, String currentStatus) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cập nhật trạng thái', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, fontSize: 16)),
        children: _statuses.map((s) {
          final isCurrent = s == currentStatus;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, s),
            child: Row(
              children: [
                Icon(
                  isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isCurrent ? AppColors.primary : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(s, style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal, color: isCurrent ? AppColors.primary : AppColors.onSurface)),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selected == null || selected == currentStatus || !context.mounted) return;

    try {
      final orderRef = FirebaseFirestore.instance.collection('orders').doc(docId);
      final orderDoc = await orderRef.get();
      final userUid = orderDoc.data()?['user_uid'] as String?;

      await orderRef.update({
        'status': selected,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (userUid != null) {
        await NotificationService.push(
          userUid: userUid,
          title: NotificationService.orderStatusTitle(selected),
          body: NotificationService.orderStatusBody(selected, docId),
          type: 'order',
          extra: {'order_id': docId},
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật: $selected'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Hoàn thành': return Colors.green;
      case 'Đang giao': return Colors.orange;
      case 'Đã xác nhận': return Colors.blue;
      case 'Đã hủy': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Đã có lỗi xảy ra.', style: TextStyle(fontFamily: 'DM Sans')));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text('Chưa có đơn hàng nào.', style: TextStyle(fontFamily: 'DM Sans', color: AppColors.onSurfaceVariant)),
          );
        }

        final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final order = doc.data() as Map<String, dynamic>;
            final orderId = doc.id.substring(0, 8).toUpperCase();
            final status = order['status'] as String? ?? 'Chờ xử lý';
            final total = (order['total'] ?? 0) as num;
            final items = order['items'] as List? ?? [];
            final email = order['user_email'] as String? ?? '';
            final shippingInfo = order['shipping_info'] as Map<String, dynamic>?;
            final name = shippingInfo?['name'] as String? ?? order['receiver_name'] as String? ?? order['user_name'] as String? ?? '';
            final phone = shippingInfo?['phone'] as String? ?? '';
            final address = [shippingInfo?['district'], shippingInfo?['city']].where((e) => e != null && e.toString().isNotEmpty).join(', ');
            final createdAt = order['created_at'] as Timestamp?;
            final dateStr = createdAt != null
                ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate())
                : '';
            final statusColor = _statusColor(status);

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('#$orderId', style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.onSurface)),
                            if (dateStr.isNotEmpty)
                              Text(dateStr, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _updateStatus(context, doc.id, status),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(status, style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
                                const SizedBox(width: 4),
                                Icon(Icons.edit_outlined, size: 13, color: statusColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (name.isNotEmpty)
                          Row(children: [
                            const Icon(Icons.person_outline, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(child: Text(name, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w600))),
                          ]),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.phone_outlined, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(phone, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant)),
                          ]),
                        ],
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(child: Text(address, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant))),
                          ]),
                        ],
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(children: [
                            const Icon(Icons.email_outlined, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Expanded(child: Text(email, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant))),
                          ]),
                        ],
                        const SizedBox(height: 10),
                        Text('${items.length} sản phẩm', style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng tiền:', style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.onSurfaceVariant)),
                            Text(fmt.format(total), style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Quick action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateStatus(context, doc.id, status),
                                icon: const Icon(Icons.swap_horiz, size: 15),
                                label: const Text('Đổi trạng thái', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            if (status != 'Đã hủy' && status != 'Hoàn thành') ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    const newStatus = 'Đang giao';
                                    final orderRef = FirebaseFirestore.instance.collection('orders').doc(doc.id);
                                    final orderDoc = await orderRef.get();
                                    final userUid = orderDoc.data()?['user_uid'] as String?;
                                    await orderRef.update({
                                      'status': newStatus,
                                      'updated_at': FieldValue.serverTimestamp(),
                                    });
                                    if (userUid != null) {
                                      await NotificationService.push(
                                        userUid: userUid,
                                        title: NotificationService.orderStatusTitle(newStatus),
                                        body: NotificationService.orderStatusBody(newStatus, doc.id),
                                        type: 'order',
                                        extra: {'order_id': doc.id},
                                      );
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã chuyển sang Đang giao'), backgroundColor: Colors.orange),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.local_shipping_outlined, size: 15),
                                  label: const Text('Giao hàng', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CustomerSupportTab extends StatelessWidget {
  const _CustomerSupportTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Đã có lỗi xảy ra.', style: TextStyle(fontFamily: 'DM Sans')));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có cuộc trò chuyện nào.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans'),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final userId = data['userId'] as String? ?? docs[index].id;
            final userName = data['userName'] as String? ?? 'Khách hàng';
            final lastMessage = data['lastMessage'] as String? ?? '';
            final unread = (data['unreadByAdmin'] as num?)?.toInt() ?? 0;
            final lastTime = (data['lastMessageTime'] as Timestamp?)?.toDate();
            final timeStr = lastTime != null
                ? DateFormat('HH:mm dd/MM').format(lastTime)
                : '';

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminChatDetailScreen(userId: userId, userName: userName),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryFixed,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'K',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.onSurface,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                              Text(
                                timeStr,
                                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lastMessage.isEmpty ? 'Chưa có tin nhắn' : lastMessage,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: unread > 0 ? AppColors.onSurface : Colors.grey.shade600,
                                    fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                                    fontFamily: 'DM Sans',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (unread > 0)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unread',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
