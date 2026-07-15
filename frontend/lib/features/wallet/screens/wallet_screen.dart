import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/features/wallet/services/payos_service.dart';
import 'package:project_mobileshop/features/wallet/services/wallet_service.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/core/widgets/custom_toast.dart';
import 'package:project_mobileshop/features/order/screens/deposit_waiting_screen.dart';
import 'package:project_mobileshop/features/wallet/screens/bank_accounts_screen.dart';

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
      final balance = await WalletService.getBalance(auth.user!.uid);
      if (mounted) {
        setState(() {
          _balance = balance;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch wallet balance: $e');
      if (mounted) setState(() => _isLoading = false);
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
                    foregroundColor: Colors.white,
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
                  child: const Text('Tiếp tục', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600)),
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

  Future<void> _showWithdrawDialog() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    List<Map<String, dynamic>> savedAccounts = [];
    try {
      savedAccounts = await WalletService.getBankAccounts(auth.user!.uid);
    } catch (e) {
      debugPrint('Failed to load bank accounts: $e');
    }

    if (!mounted) return;

    // Step 1: Chọn tài khoản hoặc thêm mới
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BankAccountPickerSheet(
        savedAccounts: savedAccounts,
        balance: _balance,
        banks: _banks,
        userUid: auth.user!.uid,
        onManageAccounts: () async {
          Navigator.pop(context);
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const BankAccountsScreen()));
        },
      ),
    );

    if (result == null || !mounted) return;

    final amount = result['amount'] as int;
    final bankBin = result['bank_bin'] as String;
    final accountNumber = result['account_number'] as String;
    final accountName = result['account_name'] as String;

    _handleWithdraw(amount, bankBin, accountNumber, accountName);

  }

  static const List<Map<String, String>> _banks = [
    {'name': 'MB Bank', 'bin': '970422'},
    {'name': 'Techcombank', 'bin': '970407'},
    {'name': 'Vietcombank (VCB)', 'bin': '970436'},
    {'name': 'VietinBank', 'bin': '970415'},
    {'name': 'BIDV', 'bin': '970418'},
    {'name': 'Agribank', 'bin': '970405'},
    {'name': 'ACB', 'bin': '970416'},
    {'name': 'TPBank', 'bin': '970423'},
  ];

  Future<void> _handleWithdraw(int amount, String bankCode, String accountNumber, String accountName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      await PayOSService.createPayout(
        amount: amount,
        bankCode: bankCode,
        accountNumber: accountNumber,
        accountName: accountName,
        description: 'RutTienViBeautyGlow',
      );

      final auth = context.read<AuthProvider>();
      if (auth.user == null) throw Exception('Chưa đăng nhập');

      await WalletService.deductBalance(
          auth.user!.uid, amount, bankCode, accountNumber, accountName);

      if (mounted) Navigator.of(context).pop(); // dismiss loading
      if (mounted) CustomToast.showSuccess(context, 'Rút tiền thành công!');
      
      _fetchBalance();

    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) CustomToast.showError(context, 'Lỗi rút tiền: $e');
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
                        icon: Icons.account_balance_wallet_outlined,
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
                    stream: WalletService.transactionsStream(
                        context.read<AuthProvider>().user?.uid ?? ''),
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
                          } else if (type == 'payment') {
                            final orderId = data.containsKey('order_id') ? data['order_id'] : '';
                            title = 'Thanh toán đơn hàng ${orderId.toString().isNotEmpty ? "#$orderId" : ""}';
                            icon = Icons.shopping_bag_outlined;
                            color = Colors.red;
                            sign = '-';
                          } else if (type == 'withdraw') {
                            title = 'Rút tiền về ngân hàng';
                            icon = Icons.account_balance_wallet_outlined;
                            color = Colors.orange;
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

// ── Bottom sheet: chọn tài khoản ngân hàng hoặc nhập mới ──────────────────

class _BankAccountPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> savedAccounts;
  final int balance;
  final List<Map<String, String>> banks;
  final VoidCallback onManageAccounts;
  final String userUid;

  const _BankAccountPickerSheet({
    required this.savedAccounts,
    required this.balance,
    required this.banks,
    required this.onManageAccounts,
    required this.userUid,
  });

  @override
  State<_BankAccountPickerSheet> createState() => _BankAccountPickerSheetState();
}

class _BankAccountPickerSheetState extends State<_BankAccountPickerSheet> {
  // null = chưa chọn, -1 = nhập mới
  int? _selectedIndex;
  bool _showNewForm = false;

  final _amountCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  String? _selectedBankBin;

  @override
  void initState() {
    super.initState();
    if (widget.savedAccounts.isEmpty) _showNewForm = true;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    super.dispose();
  }

  String _bankName(String? bin) {
    if (bin == null) return '';
    return widget.banks.firstWhere(
      (b) => b['bin'] == bin,
      orElse: () => {'name': bin},
    )['name']!;
  }

  void _submit() {
    final amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền rút tối thiểu là 10.000đ!')),
      );
      return;
    }
    if (amount > widget.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số dư không đủ!')),
      );
      return;
    }

    String? bankBin;
    String accountNumber;
    String accountName;

    if (_showNewForm) {
      if (_selectedBankBin == null ||
          _accountNumberCtrl.text.trim().isEmpty ||
          _accountNameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
        );
        return;
      }
      bankBin = _selectedBankBin!;
      accountNumber = _accountNumberCtrl.text.trim();
      accountName = _accountNameCtrl.text.trim().toUpperCase();
    } else {
      if (_selectedIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn tài khoản!')),
        );
        return;
      }
      final acc = widget.savedAccounts[_selectedIndex!];
      bankBin = acc['bank_bin'] as String;
      accountNumber = acc['account_number'] as String;
      accountName = acc['account_name'] as String;
    }

    Navigator.pop(context, {
      'amount': amount,
      'bank_bin': bankBin,
      'account_number': accountNumber,
      'account_name': accountName,
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text('Rút tiền', style: TextStyle(fontFamily: 'DM Sans', fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
              ],
            ),
            const SizedBox(height: 20),

            // Số tiền
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số tiền rút (tối thiểu 10.000đ)',
                suffixText: 'Số dư: ${formatCurrency.format(widget.balance)}',
                suffixStyle: const TextStyle(fontFamily: 'DM Sans', fontSize: 11, color: AppColors.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Danh sách tài khoản đã lưu
            if (widget.savedAccounts.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tài khoản đã lưu', style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                  GestureDetector(
                    onTap: widget.onManageAccounts,
                    child: const Text('Quản lý', style: TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.savedAccounts.asMap().entries.map((entry) {
                final i = entry.key;
                final acc = entry.value;
                final selected = !_showNewForm && _selectedIndex == i;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedIndex = i;
                    _showNewForm = false;
                  }),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withOpacity(0.07) : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.outlineVariant,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.account_balance, color: Colors.blue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _bankName(acc['bank_bin'] as String?),
                                style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface),
                              ),
                              Text(
                                acc['account_number'] as String? ?? '',
                                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                acc['account_name'] as String? ?? '',
                                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 4),
            ],

            // Nút thêm tài khoản mới
            GestureDetector(
              onTap: () => setState(() {
                _showNewForm = !_showNewForm;
                _selectedIndex = null;
              }),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _showNewForm ? AppColors.primary.withOpacity(0.07) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _showNewForm ? AppColors.primary : AppColors.outlineVariant,
                    width: _showNewForm ? 2 : 1,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: _showNewForm ? AppColors.primary : AppColors.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Text(
                      'Thêm tài khoản ngân hàng mới',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _showNewForm ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form nhập tài khoản mới
            if (_showNewForm) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Ngân hàng',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedBankBin,
                items: widget.banks.map((b) => DropdownMenuItem<String>(
                  value: b['bin'],
                  child: Text(b['name']!, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14)),
                )).toList(),
                onChanged: (val) => setState(() => _selectedBankBin = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNumberCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tài khoản',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNameCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Tên chủ tài khoản',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            // Nút lưu tài khoản (chỉ hiện khi đang nhập mới)
            if (_showNewForm) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () async {
                    final number = _accountNumberCtrl.text.trim();
                    final name = _accountNameCtrl.text.trim().toUpperCase();
                    if (_selectedBankBin == null || number.isEmpty || name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin ngân hàng!')),
                      );
                      return;
                    }
                    try {
                      await WalletService.saveBankAccount(widget.userUid, {
                        'bank_bin': _selectedBankBin,
                        'account_number': number,
                        'account_name': name,
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã lưu tài khoản ngân hàng!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint('Failed to save bank account: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lưu tài khoản thất bại!'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Lưu tài khoản này', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                onPressed: _submit,
                child: const Text('Xác nhận rút tiền', style: TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
