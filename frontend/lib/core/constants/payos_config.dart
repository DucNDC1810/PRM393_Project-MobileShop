class PayOSConfig {
  // ==========================================
  // KÊNH THU TIỀN (COLLECTION) - Dùng để nạp tiền
  // ==========================================
  static const String clientId = "f65c6bbb-24e4-4887-92de-97519bf4cfa8";
  static const String apiKey = "9e17f04c-4662-46c7-99b8-4106133a91a2";
  static const String checksumKey =
      "2ee1dda13caa65db64ea511a7f54411c031a4375361674165ab6ba6fe96447a7";

  // ==========================================
  // KÊNH CHI TIỀN (PAYOUT) - Dùng để rút tiền
  // LƯU Ý BẢO MẬT: Trong dự án thực tế, các key này phải để ở Backend. 
  // Để tạm ở Flutter chỉ dành cho mục đích demo môn học.
  // ==========================================
  static const String payoutClientId = "8d95381f-2ea5-45da-8a29-cdae63252c02";
  static const String payoutApiKey = "a15d9d16-2713-4f19-bf0f-bffe66f04fdc";
  static const String payoutChecksumKey = "00b0479b736e30fb832b4c480d3ce4cd845b0b81548d889becca6656fae3cadb";

  // URL trả về sau khi thanh toán (Dùng tạm URL web nếu chưa có deep link)
  static const String returnUrl = "https://hub.payos.vn";
  static const String cancelUrl = "https://hub.payos.vn";
}
