import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_toast.dart';
import '../widgets/shop_logo.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState<String>>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreed = false;
  _SubmitState _submitState = _SubmitState.idle;

  // Email validation state
  bool? _emailExists; // null = not checked, true = exists, false = doesn't exist
  bool _emailCheckLoading = false;
  Timer? _emailCheckTimer;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _emailCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_emailExists == true) {
      _showSnack('Email này đã được đăng ký.');
      return;
    }
    if (!_agreed) {
      _showSnack('Vui lòng đồng ý với Điều khoản & Chính sách bảo mật.');
      return;
    }
    setState(() => _submitState = _SubmitState.loading);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailCtrl.text,
      password: _passCtrl.text,
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _submitState = _SubmitState.success);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell(isLoggedIn: true)),
      );
    } else {
      setState(() => _submitState = _SubmitState.idle);
      _showSnack(authProvider.errorMessage ?? 'Đăng ký thất bại. Vui lòng thử lại.');
    }
  }

  void _checkEmailExists(String email) {
    _emailCheckTimer?.cancel();
    
    // Clear regex check
    final isValidFormat = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    
    if (email.isEmpty) {
      setState(() {
        _emailExists = null;
        _emailCheckLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _emailKey.currentState?.validate();
      });
      return;
    }

    if (!isValidFormat) {
      setState(() {
        _emailExists = null;
        _emailCheckLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _emailKey.currentState?.validate();
      });
      return;
    }

    // Valid format, show loading and debounce check
    setState(() {
      _emailExists = null;
      _emailCheckLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailKey.currentState?.validate();
    });
    
    _emailCheckTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final exists = await authProvider.checkEmailExists(email);
      if (mounted) {
        setState(() {
          _emailExists = exists;
          _emailCheckLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _emailKey.currentState?.validate();
        });
      }
    });
  }

  void _showSnack(String msg) {
    CustomToast.showError(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
        children: [
          // Background ornaments
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
              transform: Matrix4.translationValues(80, -80, 0),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHighest.withOpacity(0.4),
              ),
              transform: Matrix4.translationValues(-100, 100, 0),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildLogo(),
                      const SizedBox(height: 28),
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildCard(),
                      const SizedBox(height: 28),
                      _buildLoginLink(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ── LOGO ──────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: ShopLogo(size: 48),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          'Tạo tài khoản mới',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          'Tham gia cùng chúng tôi để nhận ưu đãi mỹ phẩm đặc quyền.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
            fontFamily: 'DM Sans',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── CARD ───────────────────────────────────────────────────────────────────

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainer),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full name
            _fieldLabel('Họ và tên'),
            const SizedBox(height: 6),
            _buildField(
              controller: _nameCtrl,
              hint: 'Nguyễn Văn A',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              action: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ và tên' : null,
            ),
            const SizedBox(height: 18),

            // Email
            _fieldLabel('Email'),
            const SizedBox(height: 6),
            _buildEmailField(),
            const SizedBox(height: 18),

            // Phone
            _fieldLabel('Số điện thoại'),
            const SizedBox(height: 6),
            _buildField(
              controller: _phoneCtrl,
              hint: '0123 456 789',
              prefixIcon: Icons.call_outlined,
              keyboardType: TextInputType.phone,
              action: TextInputAction.next,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập số điện thoại';
                if (!RegExp(r'^[0-9\s+\-]{9,15}$').hasMatch(v)) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Password row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Mật khẩu'),
                      const SizedBox(height: 6),
                      _buildPasswordField(
                        controller: _passCtrl,
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: _obscurePass,
                        onToggle: () =>
                            setState(() => _obscurePass = !_obscurePass),
                        action: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Nhập mật khẩu';
                          }
                          if (v.length < 6) return 'Tối thiểu 6 ký tự';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Xác nhận MK'),
                      const SizedBox(height: 6),
                      _buildPasswordField(
                        controller: _confirmCtrl,
                        hint: '••••••••',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        action: TextInputAction.done,
                        onSubmitted: (_) => _handleRegister(),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Xác nhận MK';
                          if (v != _passCtrl.text) return 'Không khớp';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Terms checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    side: const BorderSide(color: AppColors.outlineVariant),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'DM Sans',
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'Tôi đồng ý với '),
                          TextSpan(
                            text: 'Điều khoản',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' & '),
                          TextSpan(
                            text: 'Chính sách bảo mật',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Submit button
            _buildSubmitButton(),
            const SizedBox(height: 20),

            // Divider
            _buildDivider(),
            const SizedBox(height: 16),

            // Google button
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  // ── SUBMIT BUTTON ──────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    Widget child;
    Color bgColor;

    switch (_submitState) {
      case _SubmitState.loading:
        bgColor = AppColors.primary.withOpacity(0.8);
        child = const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text('Đang xử lý...',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans')),
          ],
        );
        break;
      case _SubmitState.success:
        bgColor = const Color(0xFF2E7D32);
        child = const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Hoàn tất!',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans')),
          ],
        );
        break;
      default:
        bgColor = AppColors.primary;
        child = const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Đăng ký',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans')),
            SizedBox(width: 6),
            Icon(Icons.chevron_right, color: Colors.white, size: 22),
          ],
        );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            _submitState == _SubmitState.idle ? _handleRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
        ),
        child: child,
      ),
    );
  }

  // ── DIVIDER ────────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'HOẶC',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant.withOpacity(0.8),
              letterSpacing: 0.8,
              fontFamily: 'DM Sans',
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 1)),
      ],
    );
  }

  // ── GOOGLE BUTTON ──────────────────────────────────────────────────────────

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceDim,
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _googleIcon(),
            const SizedBox(width: 12),
            const Text(
              'Tiếp tục với Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }

  // ── LOGIN LINK ─────────────────────────────────────────────────────────────

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã có tài khoản? ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
            fontFamily: 'DM Sans',
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: const Text(
            'Đăng nhập ngay',
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
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariant,
          fontFamily: 'DM Sans',
        ),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    TextInputAction? action,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: action,
        style: const TextStyle(
            fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
        decoration: _deco(hint: hint, prefix: prefixIcon),
        validator: validator,
      );

  Widget _buildEmailField() {
    // Build suffix indicator
    Widget? suffixIcon;
    if (_emailCheckLoading) {
      suffixIcon = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
      );
    } else if (_emailExists != null) {
      suffixIcon = _emailExists!
          ? Icon(Icons.close_rounded, color: Colors.red, size: 18)
          : Icon(Icons.check_rounded, color: Colors.green, size: 18);
    }

    return TextFormField(
      key: _emailKey,
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: _checkEmailExists,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(
          fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
      decoration: _deco(
        hint: 'example@beautyglow.com',
        prefix: Icons.mail_outline_rounded,
        suffix: suffixIcon,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Vui lòng nhập email';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
          return 'Email không hợp lệ';
        }
        if (_emailExists == true) {
          return 'Email này đã được đăng ký';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required bool obscure,
    required VoidCallback onToggle,
    TextInputAction? action,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: obscure,
        textInputAction: action,
        onFieldSubmitted: onSubmitted,
        style: const TextStyle(
            fontSize: 14, color: AppColors.onSurface, fontFamily: 'DM Sans'),
        decoration: _deco(
          hint: hint,
          prefix: prefixIcon,
          suffix: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.onSurfaceVariant,
              size: 18,
            ),
          ),
        ),
        validator: validator,
      );

  InputDecoration _deco({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant, fontSize: 14, fontFamily: 'DM Sans'),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: Icon(prefix, color: AppColors.onSurfaceVariant, size: 20),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 10), child: suffix)
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

enum _SubmitState { idle, loading, success }

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;

    void draw(String path, Color color) {
      final paint = Paint()..color = color;
      final p = Path();
      switch (path) {
        case 'blue':
          p.moveTo(22.56 * s, 12.25 * s);
          p.cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s,
              22.36 * s, 10.0 * s);
          p.lineTo(12 * s, 10.0 * s);
          p.lineTo(12 * s, 14.26 * s);
          p.lineTo(17.92 * s, 14.26 * s);
          p.cubicTo(17.66 * s, 15.63 * s, 16.88 * s, 16.79 * s,
              15.71 * s, 17.57 * s);
          p.lineTo(15.71 * s, 20.34 * s);
          p.lineTo(19.28 * s, 20.34 * s);
          p.cubicTo(21.36 * s, 18.42 * s, 22.56 * s, 15.6 * s,
              22.56 * s, 12.25 * s);
          break;
        case 'green':
          p.moveTo(12 * s, 23 * s);
          p.cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s,
              19.28 * s, 20.34 * s);
          p.lineTo(15.71 * s, 17.57 * s);
          p.cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s,
              12 * s, 18.63 * s);
          p.cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.7 * s,
              5.84 * s, 14.1 * s);
          p.lineTo(2.18 * s, 14.1 * s);
          p.lineTo(2.18 * s, 16.94 * s);
          p.cubicTo(3.99 * s, 20.53 * s, 7.7 * s, 23 * s, 12 * s, 23 * s);
          break;
        case 'yellow':
          p.moveTo(5.84 * s, 14.09 * s);
          p.cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s,
              5.49 * s, 12 * s);
          p.cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s,
              5.84 * s, 9.91 * s);
          p.lineTo(5.84 * s, 7.07 * s);
          p.lineTo(2.18 * s, 7.07 * s);
          p.cubicTo(1.43 * s, 8.55 * s, 1 * s, 10.22 * s,
              1 * s, 12 * s);
          p.cubicTo(1 * s, 13.78 * s, 1.43 * s, 15.45 * s,
              2.18 * s, 16.93 * s);
          p.lineTo(5.84 * s, 14.09 * s);
          break;
        case 'red':
          p.moveTo(12 * s, 5.38 * s);
          p.cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s,
              16.21 * s, 7.02 * s);
          p.lineTo(19.36 * s, 3.87 * s);
          p.cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1 * s,
              12 * s, 1 * s);
          p.cubicTo(7.7 * s, 1 * s, 3.99 * s, 3.47 * s,
              2.18 * s, 7.07 * s);
          p.lineTo(5.84 * s, 9.91 * s);
          p.cubicTo(6.71 * s, 7.31 * s, 9.14 * s, 5.38 * s,
              12 * s, 5.38 * s);
          break;
      }
      canvas.drawPath(p, paint);
    }

    draw('blue', const Color(0xFF4285F4));
    draw('green', const Color(0xFF34A853));
    draw('yellow', const Color(0xFFFBBC05));
    draw('red', const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
