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
import 'my_reviews_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isLoggedIn = false});
  final bool isLoggedIn;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Số liệu 6 tháng gần nhất (để xét rank)
  int _orderCount = 0;
  double _totalSpent = 0;
  // Số liệu tháng hiện tại (để xét duy trì)
  int _monthlyOrderCount = 0;
  double _monthlySpent = 0;
  // Chu kỳ 6 tháng hiện tại (để hiển thị ngày reset)
  DateTime _periodStart = DateTime.now();
  DateTime _periodEnd = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user != null) _fetchStats(user.uid);
  }

  Future<void> _fetchStats(String uid) async {
    try {
      final now = DateTime.now();

      // Xác định chu kỳ 6 tháng hiện tại (Jan-Jun hoặc Jul-Dec)
      final isFirstHalf = now.month <= 6;
      final periodStart = DateTime(now.year, isFirstHalf ? 1 : 7, 1);
      final periodEnd = DateTime(now.year, isFirstHalf ? 7 : 13, 1);

      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .where('user_uid', isEqualTo: uid)
          .get();

      double periodTotal = 0;
      int periodCount = 0;
      double monthlyTotal = 0;
      int monthlyCount = 0;

      for (final doc in snap.docs) {
        final amount = (doc.data()['total'] ?? 0) as num;
        final createdAt = doc.data()['created_at'];
        if (createdAt == null) continue;

        final date = (createdAt as Timestamp).toDate();

        // Đơn trong chu kỳ 6 tháng hiện tại → xét rank
        if (!date.isBefore(periodStart) && date.isBefore(periodEnd)) {
          periodTotal += amount.toDouble();
          periodCount++;
        }

        // Đơn trong tháng hiện tại → xét duy trì
        if (date.year == now.year && date.month == now.month) {
          monthlyTotal += amount.toDouble();
          monthlyCount++;
        }
      }

      if (mounted) {
        setState(() {
          _orderCount = periodCount;
          _totalSpent = periodTotal;
          _monthlyOrderCount = monthlyCount;
          _monthlySpent = monthlyTotal;
          _periodStart = periodStart;
          _periodEnd = DateTime(periodEnd.year, periodEnd.month - 1, 30);
        });
      }
    } catch (_) {}
  }

  // Rank dựa trên số liệu 6 tháng gần nhất
  _MemberRank get _currentRank {
    if (_orderCount >= 50 && _totalSpent >= 25000000) return _MemberRank.diamond;
    if (_orderCount >= 25 && _totalSpent >= 5000000) return _MemberRank.gold;
    if (_orderCount >= 5 && _totalSpent >= 1000000) return _MemberRank.silver;
    return _MemberRank.bronze;
  }

  // Duy trì Vàng: 10 đơn + 1 triệu/tháng
  bool get _maintainsGold =>
      _currentRank == _MemberRank.gold &&
      _monthlyOrderCount >= 10 &&
      _monthlySpent >= 1000000;

  // Duy trì Kim Cương: 50 đơn + 5 triệu/tháng
  bool get _maintainsDiamond =>
      _currentRank == _MemberRank.diamond &&
      _monthlyOrderCount >= 50 &&
      _monthlySpent >= 5000000;

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
                  _MenuItem(Icons.payment_outlined, 'Phương thức thanh toán', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    );
                  }),
                ]),
                _buildMenuSection('Đơn hàng', [
                  _MenuItem(Icons.receipt_long_outlined, 'Lịch sử đơn hàng', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                    );
                  }),
                  _MenuItem(Icons.favorite_border, 'Danh sách yêu thích', () {}),
                  _MenuItem(Icons.star_border, 'Đánh giá của tôi', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
                    );
                  }),
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
    final rank = _currentRank;
    final cfg = _rankConfig(rank);
    final next = _nextRankConfig(rank);

    final fmt = (double v) {
      if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}tr';
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
      return v.toStringAsFixed(0);
    };

    final resetStr =
        '${_periodEnd.day.toString().padLeft(2, '0')}/${_periodEnd.month.toString().padLeft(2, '0')}/${_periodEnd.year}';

    // Tiến độ lên hạng tiếp theo
    double progress = 1.0;
    String progressLabel = 'Đã đạt hạng cao nhất';
    if (next != null) {
      final op = (_orderCount / next.orderTarget).clamp(0.0, 1.0);
      final sp = (_totalSpent / next.spentTarget).clamp(0.0, 1.0);
      progress = (op + sp) / 2;
      final ol = (next.orderTarget - _orderCount).clamp(0, next.orderTarget);
      final sl = ((next.spentTarget - _totalSpent) / 1000000).clamp(0.0, 999.0);
      progressLabel = (ol > 0 || sl > 0)
          ? 'Còn ${ol > 0 ? "$ol đơn" : ""}${ol > 0 && sl > 0 ? " & " : ""}${sl > 0 ? "${sl.toStringAsFixed(1)}tr" : ""} để lên ${next.label}'
          : 'Sẵn sàng lên ${next.label}!';
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: cfg.gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: cfg.gradientColors.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: tên rank + ngày reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thẻ thành viên', style: TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: Text('${cfg.icon} ${cfg.label}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Chu kỳ reset: $resetStr', style: const TextStyle(fontSize: 10, color: Colors.white54, fontFamily: 'DM Sans')),
          const SizedBox(height: 14),

          // Thống kê 6 tháng
          Row(
            children: [
              Expanded(child: _statChip(Icons.shopping_bag_outlined, '$_orderCount đơn', '6 tháng qua')),
              const SizedBox(width: 10),
              Expanded(child: _statChip(Icons.paid_outlined, fmt(_totalSpent), '6 tháng qua')),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar lên hạng
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
          Text(progressLabel, style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'DM Sans')),

          // Duy trì Vàng
          if (rank == _MemberRank.gold) ...[
            const SizedBox(height: 12),
            _maintainBanner(
              maintained: _maintainsGold,
              maintainedText: 'Đang duy trì hạng Vàng tháng này ✓',
              warningText: 'Duy trì Vàng: 10 đơn & 1tr/tháng\nTháng này: $_monthlyOrderCount đơn, ${fmt(_monthlySpent)}',
              fmt: fmt,
            ),
          ],

          // Duy trì Kim Cương
          if (rank == _MemberRank.diamond) ...[
            const SizedBox(height: 12),
            _maintainBanner(
              maintained: _maintainsDiamond,
              maintainedText: 'Đang duy trì hạng Kim Cương tháng này ✓',
              warningText: 'Duy trì Kim Cương: 50 đơn & 5tr/tháng\nTháng này: $_monthlyOrderCount đơn, ${fmt(_monthlySpent)}',
              fmt: fmt,
            ),
          ],

          // Điều kiện lên hạng tiếp
          if (next != null) ...[
            const SizedBox(height: 10),
            Text(
              'Lên ${next.label}: ${next.orderTarget} đơn & ${fmt(next.spentTarget.toDouble())} trong 6 tháng',
              style: const TextStyle(fontSize: 11, color: Colors.white54, fontFamily: 'DM Sans'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _maintainBanner({
    required bool maintained,
    required String maintainedText,
    required String warningText,
    required String Function(double) fmt,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(
            maintained ? Icons.verified : Icons.warning_amber_rounded,
            color: maintained ? Colors.greenAccent : Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              maintained ? maintainedText : warningText,
              style: const TextStyle(fontSize: 11, color: Colors.white, fontFamily: 'DM Sans', height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'DM Sans')),
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'DM Sans')),
            ],
          ),
        ],
      ),
    );
  }

  _RankConfig _rankConfig(_MemberRank rank) {
    switch (rank) {
      case _MemberRank.bronze:
        return _RankConfig('Đồng', '🥉', [const Color(0xFF8D6E63), const Color(0xFF5D4037)], 0, 0);
      case _MemberRank.silver:
        return _RankConfig('Bạc', '🥈', [const Color(0xFF78909C), const Color(0xFF37474F)], 5, 1000000);
      case _MemberRank.gold:
        return _RankConfig('Vàng', '🥇', [const Color(0xFFF9A825), const Color(0xFFE65100)], 25, 5000000);
      case _MemberRank.diamond:
        return _RankConfig('Kim Cương', '💎', [const Color(0xFF1565C0), const Color(0xFF0D47A1)], 50, 25000000);
    }
  }

  _RankConfig? _nextRankConfig(_MemberRank rank) {
    switch (rank) {
      case _MemberRank.bronze:
        return _RankConfig('Bạc', '🥈', [const Color(0xFF78909C), const Color(0xFF37474F)], 5, 1000000);
      case _MemberRank.silver:
        return _RankConfig('Vàng', '🥇', [const Color(0xFFF9A825), const Color(0xFFE65100)], 25, 5000000);
      case _MemberRank.gold:
        return _RankConfig('Kim Cương', '💎', [const Color(0xFF1565C0), const Color(0xFF0D47A1)], 50, 25000000);
      case _MemberRank.diamond:
        return null;
    }
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

enum _MemberRank { bronze, silver, gold, diamond }

class _RankConfig {
  final String label;
  final String icon;
  final List<Color> gradientColors;
  final int orderTarget;
  final double spentTarget;
  const _RankConfig(this.label, this.icon, this.gradientColors, this.orderTarget, this.spentTarget);
}
