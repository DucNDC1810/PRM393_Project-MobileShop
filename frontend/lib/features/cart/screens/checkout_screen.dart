import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_mobileshop/core/utils/format_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/features/cart/providers/cart_provider.dart';
import 'package:project_mobileshop/features/wallet/services/payos_service.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';
import 'package:project_mobileshop/core/widgets/custom_toast.dart';
import 'package:project_mobileshop/features/order/screens/order_success_screen.dart';
import 'package:project_mobileshop/features/order/screens/payment_waiting_screen.dart';
import 'package:project_mobileshop/features/notification/services/notification_service.dart';

class CheckoutScreen extends StatefulWidget {
  final int discount;
  const CheckoutScreen({super.key, this.discount = 0});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'TP. Hồ Chí Minh');
  final _notesCtrl = TextEditingController();

  String _selectedDistrict = 'Quận 1';
  String _shippingMethod = 'standard'; // 'standard' or 'fast'
  String _paymentMethod = 'cod'; // 'cod', 'bank', or 'wallet'

  final List<String> _districts = [
    'Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5',
    'Quận 7', 'Quận 10', 'Quận 12', 'Bình Thạnh',
    'Gò Vấp', 'Phú Nhuận', 'Tân Bình', 'Thủ Đức'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillUserInfo());
  }

  List<Map<String, dynamic>> _savedAddresses = [];

  Future<void> _prefillUserInfo() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.user!.uid)
          .get();
      final data = doc.data();
      if (mounted) {
        setState(() {
          if (data != null && data['saved_addresses'] != null) {
            _savedAddresses = List<Map<String, dynamic>>.from(data['saved_addresses']);
          }
          
          if (_savedAddresses.isNotEmpty) {
            final latest = _savedAddresses.first;
            _nameCtrl.text = latest['name'] ?? '';
            _phoneCtrl.text = latest['phone'] ?? '';
            _selectedDistrict = latest['district'] ?? 'Quận 1';
            _cityCtrl.text = latest['city'] ?? 'TP. Hồ Chí Minh';
            _notesCtrl.text = latest['notes'] ?? '';
          } else {
            _nameCtrl.text = data?['name'] ?? auth.user!.displayName ?? '';
            _phoneCtrl.text = data?['phone'] ?? '';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _nameCtrl.text = auth.user!.displayName ?? '';
        });
      }
    }
  }

  void _showAddressBook() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),
                  const Text('Sổ địa chỉ đã lưu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'DM Sans', color: AppColors.onSurface)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _savedAddresses.isEmpty 
                    ? const Center(child: Text('Chưa có địa chỉ nào được lưu.', style: TextStyle(fontFamily: 'DM Sans', color: AppColors.onSurfaceVariant)))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _savedAddresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final addr = _savedAddresses[index];
                          return Dismissible(
                            key: UniqueKey(),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            onDismissed: (direction) async {
                              _savedAddresses.removeAt(index);
                              setSheetState((){});
                              setState((){});
                              
                              final auth = context.read<AuthProvider>();
                              if (auth.user != null) {
                                await FirebaseFirestore.instance.collection('users').doc(auth.user!.uid).update({
                                  'saved_addresses': _savedAddresses
                                });
                              }
                            },
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _nameCtrl.text = addr['name'] ?? '';
                                  _phoneCtrl.text = addr['phone'] ?? '';
                                  _selectedDistrict = addr['district'] ?? 'Quận 1';
                                  _cityCtrl.text = addr['city'] ?? 'TP. Hồ Chí Minh';
                                  _notesCtrl.text = addr['notes'] ?? '';
                                });
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.outlineVariant),
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.surfaceContainerLowest,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(addr['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'DM Sans', color: AppColors.onSurface)),
                                        const Spacer(),
                                        const Icon(Icons.phone_outlined, size: 16, color: AppColors.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(addr['phone'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'DM Sans', color: AppColors.onSurfaceVariant)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 18, color: AppColors.onSurfaceVariant),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${addr['notes']}, ${addr['district']}, ${addr['city']}',
                                            style: const TextStyle(fontFamily: 'DM Sans', color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.4),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_savedAddresses.length >= 6) {
                          CustomToast.showError(context, 'Sổ địa chỉ đã đầy (tối đa 6). Vui lòng vuốt sang trái để xóa bớt trước!');
                          return;
                        }
                        setState(() {
                          _nameCtrl.clear();
                          _phoneCtrl.clear();
                          _notesCtrl.clear();
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      label: const Text('Nhập địa chỉ mới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'DM Sans', color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _saveCurrentAddress() async {
    if (!_formKey.currentState!.validate()) return;
    
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.user == null) {
      CustomToast.showError(context, 'Vui lòng đăng nhập để lưu địa chỉ.');
      return;
    }

    final newAddress = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'district': _selectedDistrict,
      'city': _cityCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };
    
    bool exists = _savedAddresses.any((addr) => 
      addr['name'] == newAddress['name'] &&
      addr['phone'] == newAddress['phone'] &&
      addr['district'] == newAddress['district'] &&
      addr['notes'] == newAddress['notes']
    );

    if (exists) {
      CustomToast.showError(context, 'Địa chỉ này đã có sẵn trong Sổ địa chỉ.');
      return;
    }

    if (_savedAddresses.length >= 6) {
      CustomToast.showError(context, 'Sổ địa chỉ đã đầy (tối đa 6). Vui lòng vào "Sổ địa chỉ" vuốt xóa bớt trước!');
      return;
    }

    setState(() {
      _savedAddresses.insert(0, newAddress);
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(auth.user!.uid).update({
        'saved_addresses': _savedAddresses
      });
      if (mounted) {
        CustomToast.showSuccess(context, 'Đã lưu địa chỉ vào sổ thành công!');
      }
    } catch (_) {
      if (mounted) {
        CustomToast.showError(context, 'Đã có lỗi xảy ra khi lưu.');
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _generateOrderId() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final randomNum = (100 + (now.millisecond % 900)).toString(); // 100 to 999
    return '#BG$year$month$day$randomNum';
  }

  Future<void> _handlePlaceOrder(CartProvider cart) async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      CustomToast.showError(context, 'Vui lòng đăng nhập để thực hiện thanh toán.');
      return;
    }

    // Kiểm tra giới hạn địa chỉ TRƯỚC KHI tạo đơn hàng
    final newAddress = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'district': _selectedDistrict,
      'city': _cityCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };

    final bool addressExists = _savedAddresses.any((addr) =>
        addr['name'] == newAddress['name'] &&
        addr['phone'] == newAddress['phone'] &&
        addr['district'] == newAddress['district'] &&
        addr['notes'] == newAddress['notes']);

    if (!addressExists && auth.user != null && _savedAddresses.length >= 6) {
      CustomToast.showError(context, 'Sổ địa chỉ đã đầy (tối đa 6). Vui lòng chọn "Sổ địa chỉ" để xóa bớt trước khi đặt với địa chỉ mới!');
      return;
    }

    // Calculate total amount
    final cartItems = cart.itemsAsMap;
    final int subtotal = cart.totalAmount;
    final int shippingFee = _shippingMethod == 'standard' ? (subtotal > 500000 || subtotal == 0 ? 0 : 30000) : 60000;
    final int total = subtotal - widget.discount + shippingFee;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final user = auth.user;
      
      // Khúc xử lý thanh toán ví
      if (_paymentMethod == 'wallet' && user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final currentBalance = doc.data()?['wallet_balance'] ?? 0;
        if (currentBalance < total) {
          if (mounted) Navigator.of(context).pop();
          CustomToast.showError(context, 'Số dư ví không đủ. Vui lòng nạp thêm tiền!');
          return;
        }
      }

      final itemsData = cartItems.map((item) => {
        'id': item['id'],
        'name': item['name'],
        'brand': item['brand'],
        'price': item['price'],
        'quantity': item['quantity'],
        'emoji': item['emoji'],
        'images': item['images'],
        'image_url': item['image_url'],
      }).toList();

      final orderId = _generateOrderId();
      final int orderCode = DateTime.now().millisecondsSinceEpoch;

      final docRef = await FirebaseFirestore.instance.collection('orders').add({
        'order_id': orderId,
        'user_email': user?.email,
        'user_uid': user?.uid,
        'shipping_info': {
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'district': _selectedDistrict,
          'city': _cityCtrl.text.trim(),
          'notes': _notesCtrl.text.trim(),
        },
        'shipping_method': _shippingMethod == 'standard' ? 'Giao hàng tiêu chuẩn' : 'Giao hàng nhanh',
        'payment_method': _paymentMethod == 'cod'
            ? 'Thanh toán khi nhận hàng'
            : (_paymentMethod == 'payos' ? 'Thanh toán chuyển khoản' : 'Thanh toán bằng số dư ví'),
        'items': itemsData,
        'subtotal': subtotal,
        'discount': widget.discount,
        'shipping_fee': shippingFee,
        'total': total,
        'status': _paymentMethod == 'payos' ? 'Đang thanh toán' : 'Chờ xử lý',
        'order_code': _paymentMethod == 'payos' ? orderCode : null,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Gửi thông báo đặt hàng thành công
      if (user != null) {
        final short = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
        await NotificationService.push(
          userUid: user.uid,
          title: 'Đặt hàng thành công 🎉',
          body: 'Đơn hàng #$short của bạn đã được tiếp nhận và đang chờ xác nhận.',
          type: 'order',
          extra: {'order_id': orderId},
        );
      }

      if (!addressExists && user != null) {
        _savedAddresses.insert(0, newAddress);
        try {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'saved_addresses': _savedAddresses
          });
        } catch (e) {
          debugPrint('Failed to save address: $e');
        }
      }

      // Clear cart
      cart.clear();

      if (_paymentMethod == 'payos') {
        
        final payosData = await PayOSService.createPaymentLink(
          orderCode: orderCode,
          amount: total,
          description: 'Thanh toan don hang',
        );

        final checkoutUrl = payosData['checkoutUrl'] as String? ?? '';
        final qrCode = payosData['qrCode'] as String? ?? '';

        // Lưu lại checkoutUrl và qrCode để có thể resume sau
        await docRef.update({
          'checkout_url': checkoutUrl,
          'qr_code': qrCode,
        });

        // Tắt loading
        if (mounted) Navigator.of(context).pop();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentWaitingScreen(
                orderCode: orderCode,
                firebaseOrderId: orderId,
                firebaseDocId: docRef.id,
                checkoutUrl: checkoutUrl,
                qrCode: qrCode,
              ),
            ),
          );
        }
      } else {
        if (_paymentMethod == 'wallet' && user != null) {
          // Trừ tiền trong ví
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
            final snapshot = await transaction.get(userDocRef);
            int currentBalance = 0;
            if (snapshot.exists && snapshot.data()!.containsKey('wallet_balance')) {
              currentBalance = snapshot.get('wallet_balance');
            }
            transaction.update(userDocRef, {'wallet_balance': currentBalance - total});
          });

          // Lưu lịch sử
          await FirebaseFirestore.instance.collection('wallet_transactions').add({
            'user_uid': user.uid,
            'type': 'payment',
            'amount': total,
            'status': 'completed',
            'order_id': orderId,
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        // Tắt loading
        if (mounted) Navigator.of(context).pop();

        // Chuyển tới OrderSuccessScreen cho COD/Bank/Wallet
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(orderId: orderId),
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss loading
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        CustomToast.showError(context, 'Đã có lỗi xảy ra: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.itemsAsMap;

    final int subtotal = cart.totalAmount;
    
    // Calculate shipping fee: Standard is free if subtotal > 500k, else 30k. Fast is 60k.
    final int shippingFee = _shippingMethod == 'standard'
        ? (subtotal > 500000 || subtotal == 0 ? 0 : 30000)
        : 60000;
        
    final int total = subtotal - widget.discount + shippingFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: AppColors.surface,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── STEPPER/TIMELINE ────────────────────────────────────────────────
            _buildStepper(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── SHIPPING INFO CARD ──────────────────────────────────────────
                    _buildShippingInfoCard(),
                    const SizedBox(height: 16),

                    // ── SHIPPING METHOD CARD ────────────────────────────────────────
                    _buildShippingMethodCard(subtotal),
                    const SizedBox(height: 16),

                    // ── PAYMENT METHOD CARD ─────────────────────────────────────────
                    _buildPaymentMethodCard(),
                    const SizedBox(height: 16),

                    // ── ORDER REVIEW CARD ───────────────────────────────────────────
                    _buildOrderReviewCard(cartItems),
                    const SizedBox(height: 16),

                    // ── ORDER SUMMARY CARD ──────────────────────────────────────────
                    _buildOrderSummaryCard(subtotal, shippingFee, total),
                    const SizedBox(height: 18),

                    // ── TERMS AND CONDITIONS TEXT ───────────────────────────────────
                    _buildTermsText(),
                    const SizedBox(height: 24),

                    // ── PLACE ORDER BUTTON ──────────────────────────────────────────
                    _buildPlaceOrderButton(cart, cartItems, subtotal, shippingFee, total),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEPPER WIDGET ──────────────────────────────────────────────────────────

  Widget _buildStepper() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Step 1: Giao hàng (Completed)
          _stepNode(icon: Icons.check_rounded, label: 'Giao hàng', isCompleted: true, isActive: false),
          _stepDivider(isCompleted: true),
          // Step 2: Thanh toán (Active)
          _stepNode(number: '2', label: 'Thanh toán', isCompleted: false, isActive: true),
          _stepDivider(isCompleted: false),
          // Step 3: Xác nhận (Disabled)
          _stepNode(number: '3', label: 'Xác nhận', isCompleted: false, isActive: false),
        ],
      ),
    );
  }

  Widget _stepNode({
    IconData? icon,
    String? number,
    required String label,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color circleColor;
    Widget child;

    if (isCompleted) {
      circleColor = const Color(0xFF4CAF50); // Green
      child = Icon(icon, color: Colors.white, size: 16);
    } else if (isActive) {
      circleColor = AppColors.primary; // Pink
      child = Text(number ?? '', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13));
    } else {
      circleColor = AppColors.outlineVariant.withOpacity(0.5);
      child = Text(number ?? '', 
          style: const TextStyle(color: AppColors.outline, fontWeight: FontWeight.bold, fontSize: 13));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: child),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: (isActive || isCompleted) ? FontWeight.w700 : FontWeight.w500,
            color: isActive 
                ? AppColors.primary 
                : (isCompleted ? AppColors.onSurface : AppColors.onSurfaceVariant.withOpacity(0.6)),
            fontFamily: 'DM Sans',
          ),
        ),
      ],
    );
  }

  Widget _stepDivider({required bool isCompleted}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Divider(
          color: isCompleted ? const Color(0xFF4CAF50) : AppColors.outlineVariant.withOpacity(0.5),
          thickness: 1.5,
        ),
      ),
    );
  }

  // ── SHIPPING INFO CARD ──────────────────────────────────────────────────────

  Widget _buildShippingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Thông tin giao hàng',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showAddressBook,
                child: Row(
                  children: const [
                    Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Sổ địa chỉ',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Họ và tên
          _fieldLabel('Họ và tên'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameCtrl,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
            decoration: _inputDeco(hint: 'Nhập họ và tên...'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
          ),
          const SizedBox(height: 14),

          // Số điện thoại
          _fieldLabel('Số điện thoại'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
            decoration: _inputDeco(hint: 'Nhập số điện thoại...'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập số điện thoại';
              if (!RegExp(r'^[0-9\s+\-]{9,15}$').hasMatch(v)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Quận/Huyện + Tỉnh/Thành
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Quận/Huyện'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      items: _districts.map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d, style: const TextStyle(fontSize: 14, fontFamily: 'DM Sans')),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedDistrict = val ?? 'Quận 1'),
                      decoration: _inputDeco(hint: ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Tỉnh/Thành phố'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _cityCtrl,
                      style: const TextStyle(fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
                      decoration: _inputDeco(hint: ''),
                      validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tỉnh/thành' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ghi chú đơn hàng
          _fieldLabel('Ghi chú đơn hàng'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 2,
            style: const TextStyle(fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
            decoration: _inputDeco(hint: 'Giao hàng vào giờ hành chính...'),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _saveCurrentAddress,
              icon: const Icon(Icons.bookmark_border_rounded, size: 18, color: AppColors.primary),
              label: const Text(
                'Lưu thông tin địa chỉ này',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SHIPPING METHOD CARD ────────────────────────────────────────────────────

  Widget _buildShippingMethodCard(int subtotal) {
    final isFreeShipping = subtotal > 500000;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức vận chuyển',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),

          // Giao hàng tiêu chuẩn
          _shippingRadioOption(
            value: 'standard',
            title: '🚚 Giao hàng tiêu chuẩn',
            subtitle: '2-3 ngày làm việc',
            priceText: isFreeShipping ? '0đ' : '30.000đ',
            originalPriceText: isFreeShipping ? '30.000đ' : null,
          ),
          const SizedBox(height: 12),

          // Giao hàng nhanh
          _shippingRadioOption(
            value: 'fast',
            title: '⚡ Giao hàng nhanh',
            subtitle: 'Giao trong hôm nay',
            priceText: '60.000đ',
          ),
        ],
      ),
    );
  }

  Widget _shippingRadioOption({
    required String value,
    required String title,
    required String subtitle,
    required String priceText,
    String? originalPriceText,
  }) {
    final isSelected = _shippingMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _shippingMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Custom Radio Button
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontFamily: 'DM Sans',
                  ),
                ),
                if (originalPriceText != null)
                  Text(
                    originalPriceText,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                      fontFamily: 'DM Sans',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── PAYMENT METHOD CARD ─────────────────────────────────────────────────────

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),

          // COD
          _paymentRadioOption(
            value: 'cod',
            title: '💵 Thanh toán khi nhận hàng',
            isFree: true,
          ),
          const SizedBox(height: 12),

          // Wallet (số dư ví)
          _paymentRadioOption(
            value: 'wallet',
            title: '💳 Thanh toán bằng số dư ví',
          ),
          const SizedBox(height: 12),

          // PayOS (chuyển khoản)
          _paymentRadioOption(
            value: 'payos',
            title: '🏦 Thanh toán chuyển khoản',
          ),
        ],
      ),
    );
  }

  Widget _paymentRadioOption({
    required String value,
    required String title,
    bool isFree = false,
  }) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Custom Radio Button
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  if (isFree) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MIỄN PHÍ',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ORDER REVIEW CARD ───────────────────────────────────────────────────────

  Widget _buildOrderReviewCard(List<Map<String, dynamic>> cartItems) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Xem lại đơn hàng (${cartItems.length} sản phẩm)',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: cartItems.map((item) => _buildReviewItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> item) {
    final String name = item['name'] as String? ?? 'Sản phẩm';
    final String brand = item['brand'] as String? ?? '';
    final int price = item['price'] as int? ?? 0;
    final int quantity = item['quantity'] as int? ?? 0;
    final String emoji = item['emoji'] as String? ?? '✨';

    final images = item['images'];
    String? imageUrl;
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first?.toString();
    } else if (item['image_url'] != null) {
      imageUrl = item['image_url'].toString();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageUrl != null && imageUrl.startsWith('http')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  )
                : Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    fontFamily: 'DM Sans',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$brand  x$quantity',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'DM Sans',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${formatVnd(price * quantity)}đ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }

  // ── ORDER SUMMARY CARD ──────────────────────────────────────────────────────

  Widget _buildOrderSummaryCard(int subtotal, int shippingFee, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          _summaryRow('Tạm tính', subtotal),
          const SizedBox(height: 6),
          if (widget.discount > 0) ...[
            _summaryRow('Giảm giá', -widget.discount, isDiscount: true),
            const SizedBox(height: 6),
          ],
          _summaryRow('Phí vận chuyển', shippingFee, isFree: shippingFee == 0),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.outlineVariant),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'DM Sans',
                ),
              ),
              Text(
                '${formatVnd(total)}đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, int amount, {bool isDiscount = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
            fontFamily: 'DM Sans',
          ),
        ),
        isFree
            ? const Text(
                'Miễn phí',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              )
            : Text(
                '${isDiscount ? '-' : ''}${formatVnd(amount.abs())}đ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDiscount ? const Color(0xFF2E7D32) : AppColors.onSurface,
                  fontFamily: 'DM Sans',
                ),
              ),
      ],
    );
  }

  // ── TERMS TEXT WIDGET ───────────────────────────────────────────────────────

  Widget _buildTermsText() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'DM Sans',
              height: 1.4,
            ),
            children: [
              TextSpan(text: 'Bằng cách nhấn Đặt hàng, bạn đã đồng ý với '),
              TextSpan(
                text: 'Điều khoản & Điều kiện',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(text: ' của Beauty & Glow.'),
            ],
          ),
        ),
      ),
    );
  }

  // ── PLACE ORDER BUTTON ──────────────────────────────────────────────────────

  Widget _buildPlaceOrderButton(CartProvider cart, List<Map<String, dynamic>> cartItems, int subtotal, int shippingFee, int total) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => _handlePlaceOrder(cart),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
        ),
        child: const Text(
          'Đặt hàng ngay',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFamily: 'DM Sans',
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
          fontFamily: 'DM Sans',
        ),
      );

  InputDecoration _inputDeco({required String hint}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant, fontSize: 13, fontFamily: 'DM Sans'),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        errorStyle: const TextStyle(
            fontSize: 10, color: AppColors.error, fontFamily: 'DM Sans'),
      );

}
