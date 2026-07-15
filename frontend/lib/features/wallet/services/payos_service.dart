import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:project_mobileshop/core/constants/payos_config.dart';

class PayOSService {
  static const String _baseUrl = 'https://api-merchant.payos.vn';

  // Tạo link thanh toán
  static Future<Map<String, dynamic>> createPaymentLink({
    required int orderCode,
    required int amount,
    required String description,
  }) async {
    // 1. Tạo chuỗi dữ liệu để tính signature
    // Các tham số phải được sắp xếp theo alphabet: amount, cancelUrl, description, orderCode, returnUrl
    final String dataStr = 'amount=$amount&cancelUrl=${PayOSConfig.cancelUrl}&description=$description&orderCode=$orderCode&returnUrl=${PayOSConfig.returnUrl}';

    // 2. Tính chữ ký HMAC_SHA256
    final hmac = Hmac(sha256, utf8.encode(PayOSConfig.checksumKey));
    final signature = hmac.convert(utf8.encode(dataStr)).toString();

    // 3. Chuẩn bị payload
    final body = {
      "orderCode": orderCode,
      "amount": amount,
      "description": description,
      "returnUrl": PayOSConfig.returnUrl,
      "cancelUrl": PayOSConfig.cancelUrl,
      "signature": signature,
    };

    // 4. Gọi API
    final url = Uri.parse('$_baseUrl/v2/payment-requests');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': PayOSConfig.clientId,
        'x-api-key': PayOSConfig.apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['code'] == '00') {
        return json['data']; // Chứa checkoutUrl, paymentLinkId, qrCode...
      } else {
        throw Exception(json['desc'] ?? 'Lỗi từ PayOS');
      }
    } else {
      throw Exception('Lỗi gọi API PayOS: ${response.statusCode}');
    }
  }

  // Lấy thông tin đầy đủ của payment link (checkoutUrl, qrCode, status...)
  static Future<Map<String, dynamic>> getPaymentInfo(int orderCode) async {
    final url = Uri.parse('$_baseUrl/v2/payment-requests/$orderCode');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': PayOSConfig.clientId,
        'x-api-key': PayOSConfig.apiKey,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['code'] == '00') {
        return json['data'] as Map<String, dynamic>;
      } else {
        throw Exception(json['desc'] ?? 'Lỗi từ PayOS');
      }
    } else {
      throw Exception('Lỗi gọi API PayOS: ${response.statusCode}');
    }
  }

  // Kiểm tra trạng thái thanh toán của đơn hàng
  static Future<String> getPaymentStatus(int orderCode) async {
    final data = await getPaymentInfo(orderCode);
    return data['status'] as String? ?? 'PENDING';
  }

  // Tạo lệnh rút tiền (Chi hộ / Payout)
  static Future<Map<String, dynamic>> createPayout({
    required int amount,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required String description,
  }) async {
    final String referenceId = "REF${DateTime.now().millisecondsSinceEpoch}";

    // Payload — không gửi category (gây lỗi signature)
    final body = {
      "referenceId": referenceId,
      "amount": amount,
      "description": description,
      "toBin": bankCode,
      "toAccountNumber": accountNumber,
    };

    // Signature: các field non-array sắp xếp alphabet
    final String dataStr =
        'amount=$amount&description=$description&referenceId=$referenceId&toAccountNumber=$accountNumber&toBin=$bankCode';

    final hmac = Hmac(sha256, utf8.encode(PayOSConfig.payoutChecksumKey));
    final signature = hmac.convert(utf8.encode(dataStr)).toString();

    final url = Uri.parse('$_baseUrl/v1/payouts');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': PayOSConfig.payoutClientId,
        'x-api-key': PayOSConfig.payoutApiKey,
        'x-idempotency-key': DateTime.now().millisecondsSinceEpoch.toString(),
        'x-signature': signature,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['code'] == '00') {
        return json['data'] ?? {};
      } else {
        throw Exception('${json['desc']} - Chi tiết: ${response.body}');
      }
    } else {
      throw Exception('Lỗi gọi API Payout PayOS: ${response.statusCode}\n${response.body}');
    }
  }
}
