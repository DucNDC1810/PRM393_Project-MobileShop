import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../services/payos_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_toast.dart';
import 'deposit_waiting_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _balance = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(auth.user!.uid).get();
      if (mounted) {
        setState(() {
          _balance = doc.data()?['wallet_balance'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDepositDialog() {
    final amountCtrl = TextEditingController();
    final suggestions = [20000, 50000, 100000, 200000, 500000];
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Nạp tiền vào ví', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nhập số tiền (Tối thiểu 10.000đ)...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Gợi ý số tiền nạp:', style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions.map((amount) {
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            amountCtrl.text = amount.toString();
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            formatCurrency.format(amount),
                            style: const TextStyle(color: AppColors.primary, fontFamily: 'DM Sans', fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final amount = int.tryParse(amountCtrl.text.trim());
                    if (amount == null || amount < 10000) {
                      CustomToast.showError(context, 'Số tiền nạp tối thiểu là 10.000đ!');
                      return;
                    }
                    Navigator.pop(context); // Close dialog
                    _handleDeposit(amount);
                  },
                  child: const Text('Tiếp tục'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _handleDeposit(int amount) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final int orderCode = DateTime.now().millisecondsSinceEpoch;
      
      final payosData = await PayOSService.createPaymentLink(
        orderCode: orderCode,
        amount: amount,
        description: 'Nap tien vao vi',
      );

      final checkoutUrl = payosData['checkoutUrl'];
      final qrCode = payosData['qrCode'];
      
      if (mounted) Navigator.of(context).pop(); // dismiss loading

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DepositWaitingScreen(
              orderCode: orderCode,
              checkoutUrl: checkoutUrl,
              qrCode: qrCode,
              amount: amount,
              onSuccess: () {
                _fetchBalance(); // Refresh balance when successful
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) CustomToast.showError(context, 'Lỗi tạo giao dịch: $e');
    }
  }

  void _showWithdrawDialog() {
    final amountCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final accountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rút tiền về tài khoản ngân hàng', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Nhập số tiền cần rút...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Họ và tên chủ tài khoản',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tên Ngân hàng',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Gợi ý ngân hàng:', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant))
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.start,
                  children: ['MB Bank', 'Vietcombank', 'Techcombank', 'TPBank', 'Agribank', 'BIDV'].map((bank) {
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          bankCtrl.text = bank;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Text(
                          bank,
                          style: const TextStyle(color: AppColors.primary, fontFamily: 'DM Sans', fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Số tài khoản',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.credit_card),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final amount = int.tryParse(amountCtrl.text.trim());
                if (amount == null || amount <= 0) {
                  CustomToast.showError(context, 'Số tiền rút không hợp lệ');
                  return;
                }
                if (amount > _balance) {
                  CustomToast.showError(context, 'Số dư không đủ để rút');
                  return;
                }
                if (nameCtrl.text.trim().isEmpty || bankCtrl.text.trim().isEmpty || accountCtrl.text.trim().isEmpty) {
                  CustomToast.showError(context, 'Vui lòng nhập đầy đủ thông tin rút tiền');
                  return;
                }
                Navigator.pop(context); // Close dialog
                _handleWithdraw(amount, '${nameCtrl.text.trim()} | ${bankCtrl.text.trim()} | ${accountCtrl.text.trim()}');
              },
              child: const Text('Rút tiền'),
            ),
          ],
        );
          }
        );
      },
    );
  }

  Future<void> _handleWithdraw(int amount, String bankInfo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final auth = context.read<AuthProvider>();
      final newBalance = _balance - amount;
      
      // Update balance
      await FirebaseFirestore.instance.collection('users').doc(auth.user!.uid).update({
        'wallet_balance': newBalance
      });
      
      // Save transaction
      await FirebaseFirestore.instance.collection('wallet_transactions').add({
        'user_uid': auth.user!.uid,
        'type': 'withdraw',
        'amount': amount,
        'bank_info': bankInfo,
        'status': 'completed', // Mô phỏng rút tiền thành công ngay lập tức
        'created_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        _balance = newBalance;
      });

      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        CustomToast.showSuccess(context, 'Rút tiền thành công! Tiền đã được chuyển thẳng về thẻ ngân hàng của bạn.');
      }
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) CustomToast.showError(context, 'Đã có lỗi xảy ra.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ví của tôi', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, color: AppColors.primary)),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFFA7C4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Số dư khả dụng',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'DM Sans', fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatCurrency.format(_balance),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontFamily: 'DM Sans', fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Nạp tiền',
                        color: Colors.green.shade600,
                        onTap: _showDepositDialog,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.remove_circle_outline,
                        label: 'Rút tiền',
                        color: Colors.orange.shade600,
                        onTap: _showWithdrawDialog,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Transaction History
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Lịch sử giao dịch', style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('wallet_transactions')
                        .where('user_uid', isEqualTo: context.read<AuthProvider>().user?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }
                      
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Đã có lỗi xảy ra khi tải lịch sử.', style: TextStyle(color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans')),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Chưa có giao dịch nào.', style: TextStyle(color: AppColors.onSurfaceVariant, fontFamily: 'DM Sans')),
                        );
                      }

                      // Sắp xếp danh sách trong bộ nhớ để tránh lỗi thiếu Composite Index của Firestore
                      final docs = snapshot.data!.docs.toList();
                      docs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTime = aData['created_at'] as Timestamp?;
                        final bTime = bData['created_at'] as Timestamp?;
                        if (aTime == null || bTime == null) return 0;
                        return bTime.compareTo(aTime);
                      });

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.outlineVariant),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final type = data['type'] as String? ?? '';
                          final amount = data['amount'] as int? ?? 0;
                          final createdAt = data['created_at'] as Timestamp?;
                          final dateStr = createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate()) : '';

                          String title = '';
                          IconData icon = Icons.receipt_long;
                          Color color = Colors.grey;
                          String sign = '';

                          if (type == 'deposit') {
                            title = 'Nạp tiền vào ví';
                            icon = Icons.add_circle_outline;
                            color = Colors.green;
                            sign = '+';
                          } else if (type == 'withdraw') {
                            title = 'Rút tiền về thẻ ngân hàng';
                            icon = Icons.remove_circle_outline;
                            color = Colors.orange;
                            sign = '-';
                          } else if (type == 'payment') {
                            final orderId = data.containsKey('order_id') ? data['order_id'] : '';
                            title = 'Thanh toán đơn hàng ${orderId.toString().isNotEmpty ? "#$orderId" : ""}';
                            icon = Icons.shopping_bag_outlined;
                            color = Colors.red;
                            sign = '-';
                          }

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            title: Text(title, style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(dateStr, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant)),
                            trailing: Text(
                              '$sign${formatCurrency.format(amount)}',
                              style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, fontSize: 14, color: color),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
