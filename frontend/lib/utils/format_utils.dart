import 'package:intl/intl.dart';

/// Utility functions for formatting values consistently across the app.
final _currencyFormatter = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

String formatPrice(num price) => _currencyFormatter.format(price);

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
}
