import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shop_logo.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import 'store_location_screen.dart';
import 'notifications_screen.dart';
import 'chat_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isLoggedIn = false});
  final bool isLoggedIn;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _orderCount = 0;
  int _loyaltyPoints = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user != null) _fetchStats(user.uid);
  }

  Future<void> _fetchStats(String uid) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .where('user_uid', isEqualTo: uid)
          .get();

      int points = 0;
      for (final doc in snap.docs) {
        final total = (doc.data()['total'] ?? 0) as num;
        points += (total / 1000).floor();
      }

      if (mounted) {
        setState(() {
          _orderCount = snap.docs.length;
          _loyaltyPoints = points;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (!authProvider.isLoggedIn) return _buildLoginPrompt(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProfileHeader(user),
                _buildLoyaltyCard(),
                _buildMenuSection('Tài khoản', [
                  _MenuItem(Icons.person_outline, 'Thông tin cá nhân', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  }),
                  _MenuItem(Icons.location_on_outlined, 'Hệ thống cửa hàng', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StoreLocationScreen()),
                    );
                  }),
                  _MenuItem(Icons.account_balance_wallet_outlined, 'Ví của tôi', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    );
                  }),
                  _MenuItem(Icons.payment_outlined, 'Phương thức thanh toán', () {}),
                ]),
                _buildMenuSection('Đơn hàng', [
                  _MenuItem(Icons.receipt_long_outlined, 'Lịch sử đơn hàng', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                    );
                  }),
                  _MenuItem(Icons.favorite_border, 'Danh sách yêu thích', () {}),
                  _MenuItem(Icons.star_border, 'Đánh giá của tôi', () {}),
                ]),
                _buildMenuSection('Cài đặt', [
                  _MenuItem(Icons.notifications_outlined, 'Thông báo', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  }),
                  _MenuItem(Icons.lock_outline, 'Bảo mật', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  }),
                  _MenuItem(Icons.help_outline, 'Hỗ trợ trực tuyến', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  }),
                ]),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'DM Sans'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline,
                      size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Đăng nhập để tiếp tục',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Đăng nhập để xem thông tin tài khoản, lịch sử đơn hàng và nhiều ưu đãi hơn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'DM Sans',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'DM Sans'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                    ),
                    child: const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'DM Sans'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 44)),
                ),
              ),
              // Brand logo badge
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(3),
                    child: ShopLogo(size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user?.displayName ?? 'Người dùng Beauty & Glow',
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(fontSize: 13, color: Colors.white70, fontFamily: 'DM Sans'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem('$_orderCount', 'Đơn hàng'),
              Container(width: 1, height: 32, color: Colors.white30),
              _statItem('0', 'Đánh giá'),
              Container(width: 1, height: 32, color: Colors.white30),
              _statItem('0', 'Yêu thích'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'DM Sans',
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'DM Sans'),
        ),
      ],
    );
  }

  Widget _buildLoyaltyCard() {
    // VIP levels: Bronze < 500, Silver < 2000, Gold < 5000, Platinum >= 5000
    String vipLabel;
    String nextLabel;
    int nextTarget;
    if (_loyaltyPoints < 500) {
      vipLabel = '🥉 Bronze';
      nextLabel = 'Silver';
      nextTarget = 500;
    } else if (_loyaltyPoints < 2000) {
      vipLabel = '💎 Silver';
      nextLabel = 'Gold';
      nextTarget = 2000;
    } else if (_loyaltyPoints < 5000) {
      vipLabel = '🥇 Gold';
      nextLabel = 'Platinum';
      nextTarget = 5000;
    } else {
      vipLabel = '💠 Platinum';
      nextLabel = '';
      nextTarget = 5000;
    }

    final prevTarget = _loyaltyPoints < 500 ? 0 : _loyaltyPoints < 2000 ? 500 : _loyaltyPoints < 5000 ? 2000 : 5000;
    final progress = nextTarget > prevTarget
        ? ((_loyaltyPoints - prevTarget) / (nextTarget - prevTarget)).clamp(0.0, 1.0)
        : 1.0;
    final percent = (progress * 100).round();
    final pointsFormatted = _loyaltyPoints.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF475569), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thẻ thành viên',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(vipLabel, style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'DM Sans')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pointsFormatted điểm',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: 'DM Sans',
                ),
              ),
              if (nextLabel.isNotEmpty)
                Text(
                  'Cần thêm ${nextTarget - _loyaltyPoints} điểm\nđể lên $nextLabel',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 11, color: Colors.white60, height: 1.4, fontFamily: 'DM Sans'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            nextLabel.isNotEmpty ? '$percent% đến $nextLabel' : 'Đã đạt hạng cao nhất',
            style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'DM Sans'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    dense: true,
                    leading: Icon(e.value.icon, color: AppColors.primary, size: 22),
                    title: Text(
                      e.value.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.onSurfaceVariant, size: 20),
                    onTap: e.value.onTap,
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 0,
                    indent: 56,
                    color: AppColors.outlineVariant,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.onTap);
}
