class PayOSConfig {
  // Lấy các thông tin này từ trang Kênh Thanh Toán -> Thông tin API của PayOS
  // THAY THẾ BẰNG THÔNG TIN THẬT CỦA BẠN TRƯỚC KHI CHẠY
  static const String clientId = "f65c6bbb-24e4-4887-92de-97519bf4cfa8";
  static const String apiKey = "9e17f04c-4662-46c7-99b8-4106133a91a2";
  static const String checksumKey =
      "2ee1dda13caa65db64ea511a7f54411c031a4375361674165ab6ba6fe96447a7";

  // URL trả về sau khi thanh toán (Dùng tạm URL web nếu chưa có deep link)
  static const String returnUrl = "https://hub.payos.vn";
  static const String cancelUrl = "https://hub.payos.vn";
}
