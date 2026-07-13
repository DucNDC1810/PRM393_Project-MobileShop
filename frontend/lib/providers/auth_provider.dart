import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  String _role = 'customer';

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null && (_user!.emailVerified || _user!.providerData.any((p) => p.providerId != 'password'));
  bool get isLoading => _status == AuthStatus.loading;
  bool get isEmailVerified => _service.isEmailVerified;
  bool get isAdmin => _role == 'admin';

  AuthProvider() {
    _service.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        await _fetchRole(user.uid);
        _status = AuthStatus.authenticated;
      } else {
        _role = 'customer';
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _role = doc.data()?['role'] ?? 'customer';
      } else {
        _role = 'customer';
      }
    } catch (e) {
      _role = 'customer';
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _service.login(email, password);
      if (credential.user != null) {
        await _fetchRole(credential.user!.uid);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _service.signInWithGoogle();
      if (credential.user != null) {
        await _fetchRole(credential.user!.uid);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đăng nhập Google thất bại.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _service.signInWithFacebook();
      if (credential.user != null) {
        await _fetchRole(credential.user!.uid);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đăng nhập Facebook thất bại.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _service.sendPasswordResetEmail(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    }
  }

  /// Update user profile (name, phone, photoUrl)
  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    _errorMessage = null;
    try {
      await _service.updateProfile(name: name, phone: phone, photoUrl: photoUrl);
      // Refresh the user object so UI rebuilds with latest displayName
      _user = _service.currentUser;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Cập nhật thất bại. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }

  /// Change password (re-authenticates with current password first)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _errorMessage = null;
    try {
      await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapChangePasswordError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Đổi mật khẩu thất bại. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> sendVerificationEmail() async {
    try {
      await _service.sendVerificationEmail();
      return true;
    } catch (e) {
      _errorMessage = 'Không gửi được email xác thực. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reloadUser() async {
    try {
      await _service.reloadUser();
      _user = _service.currentUser;
      notifyListeners();
      return _user?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if email already exists (for real-time validation)
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _service.emailExists(email);
    } catch (e) {
      return false;
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu, cần ít nhất 6 ký tự.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      default:
        return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  String _mapChangePasswordError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mật khẩu hiện tại không đúng.';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu, cần ít nhất 6 ký tự.';
      case 'requires-recent-login':
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng xuất và đăng nhập lại.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      default:
        return 'Đổi mật khẩu thất bại. Vui lòng thử lại.';
    }
  }
}
