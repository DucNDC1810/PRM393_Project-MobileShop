import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const String _messagesKey = 'chat_messages_history';
  
  List<Map<String, dynamic>> _messages = [
    {
      'sender': 'bot',
      'text': 'Xin chào! Cảm ơn bạn đã liên hệ với bộ phận hỗ trợ khách hàng của Beauty & Glow. Bạn cần chúng tôi tư vấn về dòng mỹ phẩm nào ạ? 💄',
      'time': '20:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString(_messagesKey);
    if (messagesJson != null) {
      final List<dynamic> decodedList = json.decode(messagesJson);
      setState(() {
        _messages.clear();
        for (var item in decodedList) {
          _messages.add(Map<String, dynamic>.from(item));
        }
      });
      // Đợi giao diện render xong để scroll
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String messagesJson = json.encode(_messages);
    await prefs.setString(_messagesKey, messagesJson);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'time': _getCurrentTime(),
      });
    });
    _saveMessages();
    _scrollToBottom();

    // Mock bot reply after 1.2 second
    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': _generateBotResponse(text),
          'time': _getCurrentTime(),
        });
      });
      _saveMessages();
      _scrollToBottom();
    });
  }

  String _generateBotResponse(String userText) {
    final t = userText.toLowerCase();
    if (t.contains('skincare') || t.contains('dưỡng da') || t.contains('cream') || t.contains('mụn')) {
      return 'Beauty & Glow đang có sẵn các bộ dưỡng da phục hồi và trị mụn cao cấp với ưu đãi giảm đến 20%. Da bạn thuộc loại da nào ạ (dầu, khô, nhạy cảm)?';
    }
    if (t.contains('kích ứng') || t.contains('thành phần')) {
      return 'Dạ các sản phẩm bên shop đều có bảng thành phần lành tính. Nếu bạn có làn da nhạy cảm, shop khuyến khích chọn dòng mỹ phẩm chiết xuất thiên nhiên. Bạn muốn xem chi tiết thành phần sản phẩm nào ạ?';
    }
    if (t.contains('đổi trả') || t.contains('bảo quản')) {
      return 'Shop có chính sách đổi trả miễn phí trong vòng 7 ngày nếu sản phẩm bị lỗi từ nhà sản xuất. Bạn nên bảo quản mỹ phẩm nơi khô ráo, tránh ánh nắng trực tiếp nhé.';
    }
    if (t.contains('son') || t.contains('makeup') || t.contains('trang điểm')) {
      return 'Dòng son thỏi Dior Addict và phấn nước Laneige Neo Cushion đang là best-seller của shop với bảng màu đầy đủ cực kỳ thời thượng đó ạ!';
    }
    if (t.contains('giá') || t.contains('bao nhiêu') || t.contains('km') || t.contains('khuyến mãi')) {
      return 'Dạ hiện tại shop đang chạy chương trình giảm giá lên đến 40% cho các dòng mỹ phẩm chính hãng nhân dịp ra mắt, và miễn phí vận chuyển cho đơn hàng từ 500k ạ!';
    }
    if (t.contains('đơn hàng') || t.contains('giao') || t.contains('status')) {
      return 'Bạn vui lòng cung cấp mã đơn hàng để đội ngũ Beauty & Glow kiểm tra tình trạng giao hàng ngay lập tức nhé.';
    }
    return 'Dạ, yêu cầu của bạn đã được tiếp nhận. Đội ngũ tư vấn viên Beauty & Glow sẽ liên hệ hỗ trợ bạn trực tiếp ngay ạ!';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
              child: Text('🤖'),
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
                  'Trực tuyến',
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
          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
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
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            color: isUser ? Colors.white : AppColors.onSurface,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 9,
                            color: isUser ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message input bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.outlineVariant),
                ),
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
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurface,
                                fontFamily: 'DM Sans',
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Nhập tin nhắn...',
                                hintStyle: TextStyle(
                                  color: AppColors.outline,
                                  fontSize: 14,
                                  fontFamily: 'DM Sans',
                                ),
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
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
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
