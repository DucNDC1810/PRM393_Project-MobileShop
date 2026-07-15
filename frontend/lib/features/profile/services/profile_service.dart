import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OrderStats {
  final int periodOrderCount;
  final double periodTotalSpent;
  final int monthlyOrderCount;
  final double monthlyTotalSpent;
  final DateTime periodStart;
  final DateTime periodEnd;

  const OrderStats({
    required this.periodOrderCount,
    required this.periodTotalSpent,
    required this.monthlyOrderCount,
    required this.monthlyTotalSpent,
    required this.periodStart,
    required this.periodEnd,
  });
}

class ProfileService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<OrderStats> fetchOrderStats(String uid) async {
    try {
      final now = DateTime.now();
      final isFirstHalf = now.month <= 6;
      final periodStart = DateTime(now.year, isFirstHalf ? 1 : 7, 1);
      final periodEnd = DateTime(now.year, isFirstHalf ? 7 : 13, 1);

      final snap = await _db
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

        if (!date.isBefore(periodStart) && date.isBefore(periodEnd)) {
          periodTotal += amount.toDouble();
          periodCount++;
        }

        if (date.year == now.year && date.month == now.month) {
          monthlyTotal += amount.toDouble();
          monthlyCount++;
        }
      }

      return OrderStats(
        periodOrderCount: periodCount,
        periodTotalSpent: periodTotal,
        monthlyOrderCount: monthlyCount,
        monthlyTotalSpent: monthlyTotal,
        periodStart: periodStart,
        periodEnd: DateTime(periodEnd.year, periodEnd.month - 1, 30),
      );
    } catch (e) {
      debugPrint('ProfileService.fetchOrderStats error: $e');
      final now = DateTime.now();
      return OrderStats(
        periodOrderCount: 0,
        periodTotalSpent: 0,
        monthlyOrderCount: 0,
        monthlyTotalSpent: 0,
        periodStart: now,
        periodEnd: now,
      );
    }
  }
}
