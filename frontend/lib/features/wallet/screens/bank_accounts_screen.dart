import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/core/widgets/custom_toast.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;

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

  String _bankName(String? bin) {
    if (bin == null) return '';
    return _banks.firstWhere(
      (b) => b['bin'] == bin,
      orElse: () => {'name': bin ?? ''},
    )['name']!;
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.user!.uid)
          .get();
      final raw = doc.data()?['bank_accounts'];
      setState(() {
        _accounts = raw is List
            ? raw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
            : [];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAccounts() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.user!.uid)
        .update({'bank_accounts': _accounts});
  }

  void _showAddDialog() {
    String? selectedBin;
    final numberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Thêm tài khoản ngân hàng',
              style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Ngân hàng',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  value: selectedBin,
                  items: _banks.map((b) => DropdownMenuItem(
                    value: b['bin'],
                    child: Text(b['name']!, style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14)),
                  )).toList(),
                  onChanged: (v) => setD(() => selectedBin = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: numberCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số tài khoản',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Tên chủ tài khoản',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final number = numberCtrl.text.trim();
                final name = nameCtrl.text.trim().toUpperCase();
                if (selectedBin == null || number.isEmpty || name.isEmpty) {
                  CustomToast.showError(ctx, 'Vui lòng điền đầy đủ thông tin!');
                  return;
                }
                final alreadyExists = _accounts.any((a) =>
                    a['account_number'] == number && a['bank_bin'] == selectedBin);
                if (alreadyExists) {
                  CustomToast.showError(ctx, 'Tài khoản này đã được lưu!');
                  return;
                }
                Navigator.pop(ctx);
                setState(() {
                  _accounts.add({
                    'bank_bin': selectedBin,
                    'account_number': number,
                    'account_name': name,
                  });
                });
                await _saveAccounts();
                if (mounted) CustomToast.showSuccess(context, 'Đã lưu tài khoản!');
              },
              child: const Text('Lưu', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAccount(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa tài khoản?', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
        content: Text(
          'Xóa tài khoản ${_accounts[index]['account_number']} khỏi danh sách?',
          style: const TextStyle(fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _accounts.removeAt(index));
    await _saveAccounts();
    if (mounted) CustomToast.showSuccess(context, 'Đã xóa tài khoản!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tài khoản ngân hàng',
            style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddDialog,
            tooltip: 'Thêm tài khoản',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _accounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.account_balance_outlined, size: 64, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 16),
                      const Text('Chưa có tài khoản nào',
                          style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Thêm tài khoản để rút tiền nhanh hơn',
                          style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm tài khoản', style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _accounts.length,
                  itemBuilder: (context, index) {
                    final acc = _accounts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.account_balance, color: Colors.blue, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _bankName(acc['bank_bin'] as String?),
                                  style: const TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.onSurface),
                                ),
                                const SizedBox(height: 2),
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
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteAccount(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: _accounts.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: _showAddDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
