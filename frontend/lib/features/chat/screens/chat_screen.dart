import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.orderInfo});

  /// Nếu truyền vào, màn hình sẽ tự động gửi tin nhắn kèm thông tin đơn hàng
  final Map<String, dynamic>? orderInfo;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _userId => context.read<AuthProvider>().user?.uid ?? '';
  String get _userName => context.read<AuthProvider>().user?.displayName ?? 'Khách hàng';

  CollectionReference get _messagesRef =>
      _db.collection('conversations').doc(_userId).collection('messages');

  @override
  void initState() {
    super.initState();
    _ensureConversationExists().then((_) {
      if (widget.orderInfo != null) {
        _sendOrderSupportMessage(widget.orderInfo!);
      } else {
        _checkAndSendReminder();
      }
    });
  }

  Future<void> _checkAndSendReminder() async {
    if (!mounted) return;
    final convRef = _db.collection('conversations').doc(_userId);
    final convDoc = await convRef.get();
    if (!convDoc.exists) return;

    final data = convDoc.data() as Map<String, dynamic>;
    final lastReminderAt = (data['lastReminderAt'] as Timestamp?)?.toDate();
    final now = DateTime.now();

    // Chỉ gửi nhắc nếu chưa gửi trong 3 tiếng gần nhất
    if (lastReminderAt != null && now.difference(lastReminderAt).inHours < 3) return;

    // Lấy tin nhắn cuối cùng
    final lastMsgSnap = await _messagesRef
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (lastMsgSnap.docs.isEmpty) return;

    final lastMsg = lastMsgSnap.docs.first.data() as Map<String, dynamic>;
    final lastMsgRole = lastMsg['senderRole'] as String? ?? '';
    final lastMsgTime = (lastMsg['createdAt'] as Timestamp?)?.toDate();

    if (lastMsgTime == null) return;

    // Nếu tin nhắn cuối từ user và đã hơn 3 tiếng → nhắc
    if (lastMsgRole == 'user' && now.difference(lastMsgTime).inHours >= 3) {
      await _messagesRef.add({
        'text': 'Yêu cầu của bạn vẫn chưa được phản hồi. Chúng tôi xin lỗi vì sự chậm trễ và sẽ liên hệ với bạn sớm nhất!',
        'senderId': 'system',
        'senderRole': 'system',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await convRef.update({'lastReminderAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> _ensureConversationExists() async {
    final doc = await _db.collection('conversations').doc(_userId).get();
    if (!doc.exists) {
      await _db.collection('conversations').doc(_userId).set({
        'userId': _userId,
        'userName': _userName,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadByAdmin': 0,
      });
    }
  }

  Future<void> _sendOrderSupportMessage(Map<String, dynamic> orderInfo) async {
    if (!mounted) return;
    final batch = _db.batch();

    final msgRef = _messagesRef.doc();
    batch.set(msgRef, {
      'text': 'Tôi cần hỗ trợ về đơn hàng #${orderInfo['orderId']}',
      'senderId': _userId,
      'senderRole': 'user',
      'type': 'order_support',
      'orderInfo': orderInfo,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('conversations').doc(_userId), {
      'lastMessage': 'Yêu cầu hỗ trợ đơn hàng #${orderInfo['orderId']}',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadByAdmin': FieldValue.increment(1),
    });

    await batch.commit();
    _scrollToBottom();

    // Tin nhắn xác nhận hệ thống
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _messagesRef.add({
      'text': 'Yêu cầu hỗ trợ đơn hàng của bạn đã được gửi. Nhân viên sẽ phản hồi sớm nhất!',
      'senderId': 'system',
      'senderRole': 'system',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    final batch = _db.batch();

    final msgRef = _messagesRef.doc();
    batch.set(msgRef, {
      'text': text,
      'senderId': _userId,
      'senderRole': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('conversations').doc(_userId), {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadByAdmin': FieldValue.increment(1),
    });

    await batch.commit();
    _scrollToBottom();

    // Tin nhắn tự động xác nhận từ hệ thống
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final hasAdminReply = await _messagesRef
        .where('senderRole', isEqualTo: 'admin')
        .limit(1)
        .get()
        .then((s) => s.docs.isNotEmpty);

    if (!hasAdminReply) {
      await _messagesRef.add({
        'text': 'Nhân viên đã nhận được tin nhắn của bạn. Vui lòng chờ phản hồi trong giây lát!',
        'senderId': 'system',
        'senderRole': 'system',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
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
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryFixed,
              child: Icon(Icons.support_agent, color: AppColors.primary, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hỗ trợ khách hàng',
                  style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Beauty & Glow',
                  style: TextStyle(fontFamily: 'DM Sans', color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
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
                      'Gửi tin nhắn để bắt đầu trò chuyện với admin.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans'),
                      textAlign: TextAlign.center,
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
                    final isUser = role == 'user';
                    final isSystem = role == 'system';
                    final time = (data['createdAt'] as Timestamp?)?.toDate();
                    final timeStr = time != null
                        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                        : '';

                    // Tin nhắn hệ thống — căn giữa, style khác
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
                                style: const TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(child: Divider(color: AppColors.outlineVariant)),
                          ],
                        ),
                      );
                    }

                    final isOrderSupport = data['type'] == 'order_support';
                    final orderInfo = isOrderSupport ? data['orderInfo'] as Map<String, dynamic>? : null;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
                        child: Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            // Card đơn hàng
                            if (isOrderSupport && orderInfo != null)
                              _OrderSupportCard(orderInfo: orderInfo, timeStr: timeStr),

                            // Bubble text thường
                            if (!isOrderSupport)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isUser ? AppColors.primary : AppColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                                    bottomRight: Radius.circular(isUser ? 4 : 16),
                                  ),
                                  border: isUser ? null : Border.all(color: AppColors.outlineVariant),
                                ),
                                child: Column(
                                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!isUser)
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Text('Admin', style: TextStyle(fontFamily: 'DM Sans', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                      ),
                                    Text(
                                      data['text'] ?? '',
                                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: isUser ? Colors.white : AppColors.onSurface, height: 1.4),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(timeStr, style: TextStyle(fontFamily: 'DM Sans', fontSize: 9, color: isUser ? Colors.white70 : Colors.grey)),
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
                                hintText: 'Nhập tin nhắn...',
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

class _OrderSupportCard extends StatelessWidget {
  final Map<String, dynamic> orderInfo;
  final String timeStr;

  const _OrderSupportCard({required this.orderInfo, required this.timeStr});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final items = orderInfo['items'] as List? ?? [];
    final total = (orderInfo['total'] as num?)?.toDouble() ?? 0;
    final status = orderInfo['status'] as String? ?? '';
    final orderId = orderInfo['orderId'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Yêu cầu hỗ trợ đơn hàng',
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                Text(timeStr, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 9, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mã đơn: #$orderId', style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(status, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Danh sách sản phẩm (tối đa 2)
                ...items.take(2).map((item) {
                  final m = item as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, size: 6, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${m['name'] ?? ''} x${m['quantity'] ?? 1}',
                            style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (items.length > 2)
                  Text('... và ${items.length - 2} sản phẩm khác', style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.onSurfaceVariant)),
                const Divider(height: 16, color: AppColors.outlineVariant),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng cộng:', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant)),
                    Text(fmt.format(total), style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
