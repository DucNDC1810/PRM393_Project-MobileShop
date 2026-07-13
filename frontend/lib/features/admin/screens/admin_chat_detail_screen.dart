import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

class AdminChatDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AdminChatDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _messagesRef =>
      _db.collection('conversations').doc(widget.userId).collection('messages');

  @override
  void initState() {
    super.initState();
    _markAsRead();
    _checkAndNotifyAdmin();
  }

  Future<void> _checkAndNotifyAdmin() async {
    final convRef = _db.collection('conversations').doc(widget.userId);
    final convDoc = await convRef.get();
    if (!convDoc.exists) return;

    final data = convDoc.data() as Map<String, dynamic>;
    final lastAdminReminderAt = (data['lastAdminReminderAt'] as Timestamp?)?.toDate();
    final now = DateTime.now();

    // Chỉ gửi nhắc nếu chưa gửi trong 3 tiếng gần nhất
    if (lastAdminReminderAt != null && now.difference(lastAdminReminderAt).inHours < 3) return;

    // Lấy tin nhắn cuối
    final lastMsgSnap = await _db
        .collection('conversations')
        .doc(widget.userId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (lastMsgSnap.docs.isEmpty) return;

    final lastMsg = lastMsgSnap.docs.first.data() as Map<String, dynamic>;
    final lastMsgRole = lastMsg['senderRole'] as String? ?? '';
    final lastMsgTime = (lastMsg['createdAt'] as Timestamp?)?.toDate();

    if (lastMsgTime == null) return;

    // Nếu tin nhắn cuối từ user và đã hơn 3 tiếng → gửi nhắc admin
    if (lastMsgRole == 'user' && now.difference(lastMsgTime).inHours >= 3) {
      await _db
          .collection('conversations')
          .doc(widget.userId)
          .collection('messages')
          .add({
        'text': '⚠️ Khách hàng ${widget.userName} đã chờ phản hồi hơn 3 tiếng. Vui lòng phản hồi sớm!',
        'senderId': 'system',
        'senderRole': 'system',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await convRef.update({'lastAdminReminderAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> _markAsRead() async {
    await _db.collection('conversations').doc(widget.userId).update({
      'unreadByAdmin': 0,
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    final adminId = context.read<AuthProvider>().user!.uid;
    final batch = _db.batch();

    final msgRef = _messagesRef.doc();
    batch.set(msgRef, {
      'text': text,
      'senderId': adminId,
      'senderRole': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('conversations').doc(widget.userId), {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadByAdmin': 0,
    });

    await batch.commit();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryFixed,
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'K',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesRef.orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có tin nhắn nào.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans'),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final role = data['senderRole'] as String? ?? 'user';
                    final isAdmin = role == 'admin';
                    final isSystem = role == 'system';
                    final isOrderSupport = data['type'] == 'order_support';
                    final time = (data['createdAt'] as Timestamp?)?.toDate();
                    final timeStr = time != null
                        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                        : '';

                    // Tin nhắn hệ thống
                    if (isSystem) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                        child: Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.outlineVariant)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                data['text'] ?? '',
                                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(child: Divider(color: AppColors.outlineVariant)),
                          ],
                        ),
                      );
                    }

                    // Card đơn hàng
                    if (isOrderSupport) {
                      final orderInfo = data['orderInfo'] as Map<String, dynamic>?;
                      if (orderInfo != null) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                            child: _AdminOrderCard(orderInfo: orderInfo, userName: widget.userName, timeStr: timeStr),
                          ),
                        );
                      }
                    }

                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isAdmin ? AppColors.primary : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                            bottomRight: Radius.circular(isAdmin ? 4 : 16),
                          ),
                          border: isAdmin ? null : Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isAdmin)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(widget.userName, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ),
                            Text(
                              data['text'] ?? '',
                              style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: isAdmin ? Colors.white : AppColors.onSurface, height: 1.4),
                            ),
                            const SizedBox(height: 4),
                            Text(timeStr, style: TextStyle(fontFamily: 'DM Sans', fontSize: 9, color: isAdmin ? Colors.white70 : Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.outlineVariant)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
                              decoration: const InputDecoration(
                                hintText: 'Trả lời...',
                                hintStyle: TextStyle(color: AppColors.outline, fontSize: 14, fontFamily: 'DM Sans'),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> orderInfo;
  final String userName;
  final String timeStr;

  const _AdminOrderCard({required this.orderInfo, required this.userName, required this.timeStr});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final items = orderInfo['items'] as List? ?? [];
    final total = (orderInfo['total'] as num?)?.toDouble() ?? 0;
    final status = orderInfo['status'] as String? ?? '';
    final orderId = orderInfo['orderId'] as String? ?? '';
    final date = orderInfo['date'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Icon(Icons.support_agent, color: Colors.orange.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$userName cần hỗ trợ đơn hàng',
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange.shade800),
                  ),
                ),
                Text(timeStr, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 9, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID + Status + Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mã đơn: #$orderId', style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                        if (date.isNotEmpty)
                          Text(date, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(status, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Danh sách sản phẩm
                const Text('Sản phẩm:', style: TextStyle(fontFamily: 'DM Sans', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 6),
                ...items.map((item) {
                  final m = item as Map<String, dynamic>;
                  final price = (m['price'] as num?)?.toInt() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, size: 5, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${m['name'] ?? ''} x${m['quantity'] ?? 1}',
                            style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          fmt.format(price * ((m['quantity'] as num?)?.toInt() ?? 1)),
                          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 16, color: AppColors.outlineVariant),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    Text(fmt.format(total), style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
