import 'package:intl/intl.dart';

/// Utility functions for formatting values consistently across the app.
final _currencyFormatter = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

String formatPrice(num price) => _currencyFormatter.format(price);

/// Returns price formatted with dots as thousand separators, e.g. "1.000.000"
/// Use this when the caller appends "đ" manually, e.g. '${formatVnd(price)}đ'
String formatVnd(int price) => price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

/// Resolves an emoji representation for a product based on its data map.
String resolveProductEmoji(Map<String, dynamic> product) {
  if (product['emoji'] != null) return product['emoji'] as String;
  final category = (product['category'] ?? '').toString().toLowerCase();
  final name = (product['name'] ?? '').toString().toLowerCase();

  if (category.contains('skincare') || name.contains('serum') || name.contains('toner') || name.contains('kem dưỡng')) return '🧴';
  if (category.contains('makeup') || name.contains('son') || name.contains('phấn') || name.contains('mascara') || name.contains('lipstick')) return '💄';
  if (category.contains('perfume') || name.contains('nước hoa') || name.contains('parfum') || name.contains('cologne')) return '🌸';
  if (name.contains('cleanser') || name.contains('rửa mặt') || name.contains('tẩy trang') || name.contains('wash')) return '🫧';
  if (name.contains('mask') || name.contains('mặt nạ')) return '🎭';
  if (category.contains('accessories') || name.contains('headband') || name.contains('towel') || name.contains('sponge') || name.contains('brush') || name.contains('mirror') || name.contains('organizer')) return '🛍️';
  return '✨';
}
