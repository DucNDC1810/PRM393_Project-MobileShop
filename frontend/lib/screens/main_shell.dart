import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.isLoggedIn = false});

  // kept for backward compat with pushReplacement calls, but AuthProvider is source of truth
  final bool isLoggedIn;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTabTapped(int index, bool isLoggedIn) {
    final requiresAuth = index == 2 || index == 3;
    if (requiresAuth && !isLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            onLoginSuccess: () => setState(() => _currentIndex = index),
          ),
        ),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  List<Widget> _screens(bool isLoggedIn) => [
    const HomeScreen(),
    const ProductsScreen(),
    CartScreen(onShopNowPressed: () {
      print('Shop Now pressed - changing index to 1');
      setState(() => _currentIndex = 1);
    }),
    ProfileScreen(isLoggedIn: isLoggedIn),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    final cartCount = context.watch<CartProvider>().itemCount;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens(isLoggedIn),
      ),
      bottomNavigationBar: _buildBottomNav(isLoggedIn, cartCount),
    );
  }

  Widget _buildBottomNav(bool isLoggedIn, int cartCount) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_outlined, Icons.home, 'Home', isLoggedIn: isLoggedIn),
              _navItem(1, Icons.grid_view_outlined, Icons.grid_view, 'Products', isLoggedIn: isLoggedIn),
              _navItem(2, Icons.shopping_bag_outlined, Icons.shopping_bag, 'Cart',
                  badge: cartCount > 0 ? cartCount : null, isLoggedIn: isLoggedIn),
              _navItem(3, Icons.person_outline, Icons.person, 'Profile', isLoggedIn: isLoggedIn),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label, {
    int? badge,
    required bool isLoggedIn,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index, isLoggedIn),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFixed : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                  size: 24,
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.secondary,
                fontFamily: 'DM Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
