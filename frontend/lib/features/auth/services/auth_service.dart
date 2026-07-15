import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<UserCredential> login(String emailOrUsername, String password) async {
    String email = emailOrUsername.trim();

    // Nếu không phải email thì tìm email qua username trong Firestore
    if (!email.contains('@')) {
      final query = await _db
          .collection('users')
          .where('name', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Không tìm thấy tài khoản với tên người dùng này.',
        );
      }
      email = query.docs.first.data()['email'] as String;
    }

    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email.trim(),
      'phone': phone ?? '',
      'created_at': FieldValue.serverTimestamp(),
    });

    await credential.user?.sendEmailVerification();

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    // 1. Trigger the Google Authentication flow (opens account selector pop-up)
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Đăng nhập Google bị hủy bởi người dùng.',
      );
    }

    // 2. Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    // 3. Try to get access token; fall back gracefully if scopes already granted
    String? accessToken;
    try {
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
      accessToken = clientAuth.accessToken;
    } catch (_) {
      // accessToken is optional when idToken is present
    }

    if (idToken == null && accessToken == null) {
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'Không lấy được thông tin xác thực từ Google.',
      );
    }

    // 4. Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: accessToken,
      idToken: idToken,
    );

    // 4. Authenticate with Firebase using the Google credential
    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    // 5. Store / update user profile in Firestore
    if (userCredential.user != null) {
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'name': userCredential.user!.displayName ?? googleUser.displayName ?? 'Google User',
        'email': userCredential.user!.email ?? googleUser.email,
        'phone': userCredential.user!.phoneNumber ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return userCredential;
  }

  Future<UserCredential> signInWithFacebook() async {
    // 1. Trigger the Facebook login flow
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status != LoginStatus.success) {
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: result.message ?? 'Đăng nhập Facebook thất bại.',
      );
    }

    // 2. Get the AccessToken from Facebook login result
    final AccessToken accessTokenObj = result.accessToken!;

    // 3. Create a credential for Firebase Auth
    final OAuthCredential credential = FacebookAuthProvider.credential(accessTokenObj.tokenString);

    // 4. Authenticate with Firebase using the credential
    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    // 5. Save/Update user profile in Firestore
    if (userCredential.user != null) {
      final Map<String, dynamic> userData = await FacebookAuth.instance.getUserData();
      final String name = userData['name'] ?? userCredential.user!.displayName ?? 'Facebook User';
      final String email = userData['email'] ?? userCredential.user!.email ?? 'facebook.user@beautyglow.com';

      await _db.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': userCredential.user!.phoneNumber ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return userCredential;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Update display name, phone, and optional photoUrl in Firestore + Firebase Auth
  Future<void> updateProfile({
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập.');

    // Update displayName in Firebase Auth
    await user.updateDisplayName(name);

    // Update photoURL if provided
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    // Update Firestore document
    final Map<String, dynamic> updateData = {
      'name': name,
      'phone': phone,
      'updated_at': FieldValue.serverTimestamp(),
    };
    if (photoUrl != null) {
      updateData['photo_url'] = photoUrl;
    }

    await _db.collection('users').doc(user.uid).set(updateData, SetOptions(merge: true));

    // Reload user to get fresh data
    await user.reload();
  }

  Future<bool> emailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email.trim());
      if (methods.isNotEmpty) return true;
    } catch (_) {}

    try {
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Firestore email check error: $e');
      return false;
    }
  }

  /// Re-authenticate then change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập.');
    if (user.email == null) throw Exception('Tài khoản không có email.');

    // Re-authenticate first
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }
}
