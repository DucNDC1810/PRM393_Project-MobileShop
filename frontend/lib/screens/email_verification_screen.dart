import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_toast.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _checkTimer;
  bool _resending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final auth = context.read<AuthProvider>();
      final verified = await auth.reloadUser();
      if (verified && mounted) {
        _checkTimer?.cancel();
        await auth.logout();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(registeredEmail: widget.email),
          ),
        );
      }
    });
  }

  Future<void> _resend() async {
    if (_resendCooldown > 0) return;

    setState(() => _resending = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendVerificationEmail();
    if (!mounted) return;
    setState(() => _resending = false);

    if (ok) {
      CustomToast.showSuccess(context, 'Email xác thực đã được gửi lại.');
      _startCooldown(60);
    } else {
      CustomToast.showError(context, auth.errorMessage ?? 'Gửi thất bại. Vui lòng thử lại.');
    }
  }

  void _startCooldown(int seconds) {
    setState(() => _resendCooldown = seconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) t.cancel();
      });
    });
  }

  Future<void> _cancel() async {
    _checkTimer?.cancel();
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen(registeredEmail: widget.email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Xác thực email của bạn',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DM Sans',
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Chúng tôi đã gửi email xác thực đến\n${widget.email}\n\nVui lòng mở email và nhấn vào đường dẫn để kích hoạt tài khoản.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'DM Sans',
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Đang chờ xác thực...',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_resending || _resendCooldown > 0) ? null : _resend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                  ),
                  child: _resending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          _resendCooldown > 0
                              ? 'Gửi lại sau ${_resendCooldown}s'
                              : 'Gửi lại email xác thực',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: _cancel,
                child: const Text(
                  'Quay lại đăng nhập',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'DM Sans',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
