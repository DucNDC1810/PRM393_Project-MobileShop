import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:project_mobileshop/firebase_options.dart';
import 'package:project_mobileshop/features/auth/providers/auth_provider.dart';
import 'package:project_mobileshop/features/product/providers/product_provider.dart';
import 'package:project_mobileshop/features/cart/providers/cart_provider.dart';
import 'package:project_mobileshop/features/product/providers/favorites_provider.dart';
import 'package:project_mobileshop/features/admin/screens/admin_dashboard_screen.dart';
import 'package:project_mobileshop/features/auth/screens/login_screen.dart';
import 'package:project_mobileshop/features/auth/screens/register_screen.dart';
import 'package:project_mobileshop/features/cart/screens/cart_screen.dart';
import 'package:project_mobileshop/features/cart/screens/checkout_screen.dart';
import 'package:project_mobileshop/features/home/screens/main_shell.dart';
import 'package:project_mobileshop/features/home/screens/splash_screen.dart';
import 'package:project_mobileshop/features/notification/screens/notification_screen.dart';
import 'package:project_mobileshop/features/order/screens/my_orders_screen.dart';
import 'package:project_mobileshop/features/product/screens/products_screen.dart';
import 'package:project_mobileshop/features/product/services/product_service.dart';
import 'package:project_mobileshop/features/wallet/screens/wallet_screen.dart';
import 'package:project_mobileshop/features/wallet/screens/bank_accounts_screen.dart';
import 'package:project_mobileshop/core/theme/app_theme.dart';

import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).catchError((_) => Firebase.app());
  try {
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    debugPrint('GoogleSignIn initialization failed: $e');
  }

  await _seedIfNeeded();

  runApp(const MyApp());
}

Future<void> _seedIfNeeded() async {
  try {
    final service = ProductService();
    final products = await service.getProducts();
    if (products.length < 29) {
      await service.deleteAllProducts();
      await service.seedMockData();
      await service.seedAdditionalProducts();
    }
  } catch (_) {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Beauty & Glow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
        routes: {
          '/login':         (_) => const LoginScreen(),
          '/register':      (_) => const RegisterScreen(),
          '/home':          (_) => const MainShell(),
          '/admin':         (_) => const AdminDashboardScreen(),
          '/products':      (_) => const ProductsScreen(),
          '/cart':          (_) => const CartScreen(),
          '/checkout':      (_) => const CheckoutScreen(),
          '/orders':        (_) => const MyOrdersScreen(),
          '/wallet':        (_) => const WalletScreen(),
          '/bank-accounts': (_) => const BankAccountsScreen(),
          '/notifications': (_) => const NotificationScreen(),
        },
      ),
    );
  }
}
