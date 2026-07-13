import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_toast.dart';
import '../widgets/shop_logo.dart';
import 'email_verification_screen.dart';
import 'main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess, this.registeredEmail});

  final VoidCallback? onLoginSuccess;
  final String? registeredEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  // Floating element animation
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  // Card slide-up animation
  late AnimationController _cardController;
  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _cardSlideAnim;

  @override
  void initState() {
    super.initState();
    if (widget.registeredEmail != null) {
      _emailController.text = widget.registeredEmail!;
    }

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(parent: _floatController, curve: Curves.easeInOut);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardFadeAnim = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _cardController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _cardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final verified = await authProvider.reloadUser();
      if (!mounted) return;
      if (!verified) {
        final email = _emailController.text.trim();
        await authProvider.logout();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(email: email),
          ),
        );
        return;
      }
      if (authProvider.isAdmin) {
        Navigator.of(context).pushNamedAndRemoveUntil('/admin', (route) => false);
      } else if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell(isLoggedIn: true)),
        );
      }
    } else {
      CustomToast.showError(
        context,
        authProvider.errorMessage ?? 'Đăng nhập thất bại.',
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (authProvider.isAdmin) {
        Navigator.of(context).pushNamedAndRemoveUntil('/admin', (route) => false);
      } else if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell(isLoggedIn: true)),
        );
      }
    } else {
      CustomToast.showError(
        context,
        authProvider.errorMessage ?? 'Đăng nhập Google thất bại.',
      );
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithFacebook();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      if (authProvider.isAdmin) {
        Navigator.of(context).pushNamedAndRemoveUntil('/admin', (route) => false);
      } else if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell(isLoggedIn: true)),
        );
      }
    } else {
      CustomToast.showError(
        context,
        authProvider.errorMessage ?? 'Đăng nhập Facebook thất bại.',
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      CustomToast.showError(
        context,
        'Vui lòng nhập email trước.',
      );
      return;
    }
    final success = await context.read<AuthProvider>().sendPasswordReset(email);
    if (!mounted) return;
    if (success) {
      CustomToast.showSuccess(
        context,
        'Đã gửi email đặt lại mật khẩu.',
        icon: Icons.mail_outline_rounded,
      );
    } else {
      CustomToast.showError(
        context,
        context.read<AuthProvider>().errorMessage ?? 'Lỗi gửi email.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ── Hero section (38% of screen) ──
            Expanded(
              flex: 38,
              child: _buildHero(),
            ),
            // ── Login card (62%) ──
            Expanded(
              flex: 62,
              child: FadeTransition(
                opacity: _cardFadeAnim,
                child: SlideTransition(
                  position: _cardSlideAnim,
                  child: _buildLoginCard(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HERO ──────────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Color(0xFFFFF5F8), Color(0xFFFDEAF0)], // Soft blush pink radial gradient
        ),
      ),
      child: Stack(
        children: [
          // Floating beauty elements
          _buildFloatingIcon(
            top: 48, left: 24,
            icon: Icons.spa,
            size: 36,
            color: AppColors.primary,
            delay: 0.0,
          ),
          _buildFloatingIcon(
            bottom: 56, right: 28,
            icon: Icons.brush,
            size: 32,
            color: AppColors.secondary,
            delay: 0.33,
          ),
          _buildFloatingIcon(
            top: 72, right: 56,
            icon: Icons.local_florist,
            size: 26,
            color: AppColors.primary,
            delay: 0.16,
          ),

          // Brand identity — centered
          SafeArea(
            bottom: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo circle
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: ShopLogo(size: 48),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Beauty & Glow',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Thế giới mỹ phẩm & chăm sóc sắc đẹp chính hãng',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
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

  Widget _buildFloatingIcon({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required IconData icon,
    required double size,
    required Color color,
    required double delay,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (_, __) {
          // Offset each element by its delay phase
          final phase = (_floatController.value + delay) % 1.0;
          final offset = math.sin(phase * math.pi * 2) * 8.0;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Icon(icon, size: size, color: color.withOpacity(0.25)),
          );
        },
      ),
    );
  }

  // ── LOGIN CARD ─────────────────────────────────────────────────────────────

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0F62FE),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chào mừng trở lại! Vui lòng đăng nhập để tiếp tục.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 24),

              // Email hoặc Username
              _fieldLabel('Email hoặc tên người dùng'),
              const SizedBox(height: 6),
              _emailField(),
              const SizedBox(height: 16),

              // Password
              _fieldLabel('Mật khẩu'),
              const SizedBox(height: 6),
              _passwordField(),
              const SizedBox(height: 14),

              // Remember me + Forgot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(color: AppColors.outline),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Nhớ tài khoản',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Divider
              Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: AppColors.outlineVariant, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'hoặc đăng nhập với',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant.withOpacity(0.8),
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(
                          color: AppColors.outlineVariant, thickness: 1)),
                ],
              ),
              const SizedBox(height: 16),

              // Social buttons
              Row(
                children: [
                  Expanded(child: _socialBtn('Google', '🇬', onTap: _handleGoogleLogin)),
                  const SizedBox(width: 12),
                  Expanded(child: _socialBtn('Facebook', '🇫', onTap: _handleFacebookLogin)),
                ],
              ),
              const SizedBox(height: 20),

              // Sign up link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Chưa có tài khoản? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'DM Sans',
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onLoginSuccess == null) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    ),
                    child: const Text(
                      'Tiếp tục không đăng nhập',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'DM Sans',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          fontFamily: 'DM Sans',
        ),
      );

  Widget _emailField() => TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(
            fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
        decoration: _inputDeco(
          hint: 'email@domain.com hoặc tên người dùng',
          prefix: Icons.person_outline_rounded,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Vui lòng nhập email hoặc tên người dùng';
          return null;
        },
      );

  Widget _passwordField() => TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _handleLogin(),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(
            fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
        decoration: _inputDeco(
          hint: 'Nhập mật khẩu',
          prefix: Icons.lock_outline_rounded,
          suffix: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
          if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
          return null;
        },
      );

  InputDecoration _inputDeco({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant, fontSize: 14, fontFamily: 'DM Sans'),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        prefixIcon: Icon(prefix, color: AppColors.onSurfaceVariant, size: 20),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.outlineVariant)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2)),
        errorStyle: const TextStyle(
            fontSize: 11, color: AppColors.error, fontFamily: 'DM Sans'),
      );

  Widget _socialBtn(String label, String emoji, {VoidCallback? onTap}) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outlineVariant),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'DM Sans')),
          ],
        ),
      );
}
