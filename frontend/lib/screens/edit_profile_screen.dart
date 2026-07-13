import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isFetching = true;
  bool _isUploadingAvatar = false;
  String? _email;

  Future<String?> _uploadAvatar(XFile file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('avatar.jpg');

      final bytes = await file.readAsBytes();
      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Firebase Storage upload failed: $e. Falling back to Base64...');
      try {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } catch (err) {
        print('Base64 fallback failed: $err');
      }
      return null;
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 75,
      );
      if (image == null) return;

      setState(() => _isUploadingAvatar = true);

      final photoUrl = await _uploadAvatar(image);
      if (photoUrl != null) {
        final authProvider = context.read<AuthProvider>();
        final success = await authProvider.updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          photoUrl: photoUrl,
        );
        if (success) {
          _showSuccess('Cập nhật ảnh đại diện thành công!');
        } else {
          _showError(authProvider.errorMessage ?? 'Không thể lưu ảnh đại diện.');
        }
      } else {
        _showError('Không thể tải lên hình ảnh.');
      }
    } catch (e) {
      _showError('Đã xảy ra lỗi khi chọn ảnh.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isFetching = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      _nameController.text = data?['name'] ?? user.displayName ?? '';
      _phoneController.text = data?['phone'] ?? user.phoneNumber ?? '';
      _email = user.email ?? '';
    } catch (_) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _email = user.email ?? '';
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSuccess('Cập nhật thông tin thành công!');
        Navigator.of(context).pop(true);
      } else {
        _showError(authProvider.errorMessage ?? 'Cập nhật thất bại.');
      }
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontFamily: 'DM Sans'))),
          ],
        ),
        backgroundColor: const Color(0xFF065F46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontFamily: 'DM Sans'))),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          if (!_isFetching)
            TextButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Text(
                      'Lưu',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
            ),
        ],
      ),
      body: _isFetching
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _isUploadingAvatar ? null : _pickAndUploadImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryContainer],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: _isUploadingAvatar
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                                        ? Image.network(
                                            user.photoURL!,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Text('👤', style: TextStyle(fontSize: 48)),
                                              );
                                            },
                                          )
                                        : const Center(
                                            child: Text('👤', style: TextStyle(fontSize: 48)),
                                          ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingAvatar ? null : _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Card thông tin
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                            child: Text(
                              'THÔNG TIN CƠ BẢN',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          // Họ và tên
                          _buildField(
                            controller: _nameController,
                            label: 'Họ và tên',
                            icon: Icons.person_outline,
                            hintText: 'Nhập họ và tên của bạn',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }
                              if (v.trim().length < 2) {
                                return 'Tên phải có ít nhất 2 ký tự';
                              }
                              return null;
                            },
                            showDivider: true,
                          ),
                          // Email (readonly)
                          _buildReadonlyField(
                            value: _email ?? '',
                            label: 'Email',
                            icon: Icons.email_outlined,
                            showDivider: true,
                          ),
                          // Số điện thoại
                          _buildField(
                            controller: _phoneController,
                            label: 'Số điện thoại',
                            icon: Icons.phone_outlined,
                            hintText: 'Nhập số điện thoại',
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v != null && v.isNotEmpty) {
                                final phoneRegex = RegExp(r'^[0-9]{9,11}$');
                                if (!phoneRegex.hasMatch(v.replaceAll(' ', ''))) {
                                  return 'Số điện thoại không hợp lệ';
                                }
                              }
                              return null;
                            },
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Note về email
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryFixedDim),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Email không thể thay đổi. Để thay đổi mật khẩu, vui lòng sử dụng chức năng "Đổi mật khẩu" trong mục Bảo mật.',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
              labelStyle: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 0,
            indent: 56,
            color: AppColors.outlineVariant,
          ),
      ],
    );
  }

  Widget _buildReadonlyField({
    required String value,
    required String label,
    required IconData icon,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value.isEmpty ? '---' : value,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Không thể sửa',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Container(),
        ),
        if (showDivider)
          const Divider(
            height: 0,
            indent: 56,
            color: AppColors.outlineVariant,
          ),
      ],
    );
  }
}
