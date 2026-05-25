# BeautyShop - Ứng Dụng Mua Sắm Mỹ Phẩm

Ứng dụng di động mua sắm mỹ phẩm trực tuyến được xây dựng bằng Flutter & Firebase, mang đến trải nghiệm mua sắm mượt mà trên cả Android và iOS.

---

## Tính Năng Chính

- **Duyệt sản phẩm** — Xem danh sách mỹ phẩm theo danh mục (son môi, kem dưỡng, nước hoa, make-up,...)
- **Tìm kiếm & lọc** — Tìm theo tên, thương hiệu, mức giá, đánh giá
- **Chi tiết sản phẩm** — Ảnh, mô tả, thành phần, hướng dẫn sử dụng
- **Giỏ hàng** — Thêm/xoá sản phẩm, cập nhật số lượng
- **Đặt hàng & thanh toán** — Chọn địa chỉ giao hàng, phương thức thanh toán
- **Theo dõi đơn hàng** — Xem trạng thái đơn hàng theo thời gian thực
- **Đánh giá sản phẩm** — Viết nhận xét, chấm sao
- **Yêu thích** — Lưu sản phẩm yêu thích
- **Xác thực người dùng** — Đăng ký / đăng nhập bằng Email hoặc Google

---

## Công Nghệ Sử Dụng

| Layer | Công nghệ |
|---|---|
| Frontend | Flutter (Dart) |
| Backend / Database | Firebase Firestore |
| Xác thực | Firebase Authentication |
| Lưu trữ ảnh | Firebase Cloud Storage |
| State Management | _(Provider / Riverpod / BLoC)_ |
| Target Platform | Android, iOS |

---

## Cấu Trúc Dự Án

```
project_mobileshop/
├── frontend/                  # Flutter App
│   ├── lib/
│   │   ├── main.dart          # Entry point
│   │   ├── firebase_options.dart
│   │   ├── models/            # Data models (Product, Order, User,...)
│   │   ├── screens/           # Màn hình UI
│   │   ├── widgets/           # Widget dùng chung
│   │   ├── services/          # Firebase services
│   │   └── utils/             # Hàm tiện ích, constants
│   ├── android/
│   ├── ios/
│   ├── assets/                # Ảnh, font, icon
│   └── pubspec.yaml
├── backend/
│   └── firebase.json          # Firebase project config
├── .gitignore
└── README.md
```

---

## Yêu Cầu Môi Trường

- Flutter SDK `>= 3.11.5`
- Dart SDK `>= 3.0.0`
- Android Studio / Xcode (để build native)
- Tài khoản Firebase

---

## Cài Đặt & Chạy

### 1. Clone repository

```bash
git clone https://github.com/<your-username>/project_mobileshop.git
cd project_mobileshop
```

### 2. Cài dependencies

```bash
cd frontend
flutter pub get
```

### 3. Cấu hình Firebase

Đảm bảo các file sau đã có trong dự án:

- `frontend/android/app/google-services.json` — Firebase Android config
- `frontend/ios/Runner/GoogleService-Info.plist` — Firebase iOS config
- `frontend/lib/firebase_options.dart` — Generated bởi FlutterFire CLI

Nếu chưa có, chạy lại FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 4. Chạy ứng dụng

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Chọn thiết bị cụ thể
flutter devices
flutter run -d <device-id>
```

---

## Cấu Trúc Database (Firestore)

```
/users/{userId}
    name, email, phone, address, createdAt

/products/{productId}
    name, brand, category, price, discount
    description, ingredients, images[]
    rating, reviewCount, stock

/orders/{orderId}
    userId, items[], totalPrice
    status, shippingAddress, createdAt

/reviews/{reviewId}
    productId, userId, rating, comment, createdAt

/categories/{categoryId}
    name, icon, slug
```

---

## Thành Viên Nhóm

| Họ tên | MSSV | Vai trò |
|---|---|---|
| | | |
| | | |
| | | |

---

## Giấy Phép

Dự án này được xây dựng cho mục đích học tập tại **FPT Education - PRM393**.
