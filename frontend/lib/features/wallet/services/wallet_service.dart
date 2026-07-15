import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class WalletService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<int> getBalance(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['wallet_balance'] as num? ?? 0).toInt();
  }

  static Future<List<Map<String, dynamic>>> getBankAccounts(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final raw = doc.data()?['bank_accounts'];
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  static Future<void> saveBankAccount(String uid, Map<String, dynamic> account) async {
    try {
      final existing = await getBankAccounts(uid);
      final alreadyExists = existing.any((a) =>
          a['account_number'] == account['account_number'] &&
          a['bank_bin'] == account['bank_bin']);
      if (!alreadyExists) {
        existing.add(account);
        await _db.collection('users').doc(uid).update({'bank_accounts': existing});
      }
    } catch (e) {
      debugPrint('WalletService.saveBankAccount error: $e');
      rethrow;
    }
  }

  static Future<void> deductBalance(String uid, int amount, String bankCode,
      String accountNumber, String accountName) async {
    await _db.runTransaction((transaction) async {
      final userRef = _db.collection('users').doc(uid);
      final snapshot = await transaction.get(userRef);
      final currentBalance = snapshot.data()?['wallet_balance'] ?? 0;
      if (currentBalance < amount) {
        throw Exception('Số dư không đủ để thực hiện giao dịch.');
      }
      transaction.update(userRef, {'wallet_balance': currentBalance - amount});
      final txRef = _db.collection('wallet_transactions').doc();
      transaction.set(txRef, {
        'user_uid': uid,
        'type': 'withdraw',
        'amount': amount,
        'created_at': FieldValue.serverTimestamp(),
        'bank_code': bankCode,
        'account_number': accountNumber,
        'account_name': accountName,
        'status': 'success',
      });
    });
  }

  static Stream<QuerySnapshot> transactionsStream(String uid) {
    return _db
        .collection('wallet_transactions')
        .where('user_uid', isEqualTo: uid)
        .snapshots();
  }
}
