**TIÊU CHÍ CHẤM CODE ỨNG DỤNG MOBILE**

_Gợi ý rubric đánh giá chất lượng lập trình cho project Flutter/mobile_

| **Mục tiêu:** Khi chấm ứng dụng mobile, không nên chỉ đánh giá app có chạy được hay không. Cần đánh giá thêm cấu trúc project, khả năng bảo trì, cách quản lý state, xử lý lỗi, hiệu năng cơ bản và mức độ chuyên nghiệp của code. |

# 1. Cấu trúc project rõ ràng

Sinh viên cần tổ chức thư mục hợp lý, không để toàn bộ code trong một file main.dart. Cấu trúc project tốt giúp giảng viên dễ review, nhóm dễ chia việc và ứng dụng dễ mở rộng.

lib/
main.dart
core/
constants/
themes/
routes/
features/
auth/
screens/
widgets/
product/
screens/
widgets/
models/
cart/
screens/
widgets/

- Có chia màn hình, widget, model, service rõ ràng.
- Không gom toàn bộ UI, logic và dữ liệu vào một file.
- Tên thư mục phản ánh đúng chức năng.
- Dễ tìm code khi cần sửa hoặc review.

# 2. Code dễ đọc, dễ hiểu

Code cần rõ ràng để người khác đọc được, không chỉ riêng người viết hiểu. Đây là tiêu chí phản ánh tác phong lập trình chuyên nghiệp.

- Tên biến, tên class, tên hàm có ý nghĩa.
- Không dùng tên mơ hồ như a, b, data1, screen2.
- Format code thống nhất.
- Không có đoạn code quá dài hoặc quá rối.
- Có comment ở những phần xử lý quan trọng.

// Chưa tốt
var x = getData();

// Tốt hơn
final productList = getProductList();

# 3. Tách UI thành các widget nhỏ

Đây là tiêu chí rất quan trọng trong Flutter. Không nên viết một màn hình dài hàng trăm dòng trong một hàm build().

ProductDetailScreen
├── ProductImage
├── ProductInfo
├── PriceSection
├── QuantitySelector
└── AddToCartButton

- Có tách các phần UI thành widget con.
- Widget con có nhiệm vụ rõ ràng.
- Widget có thể tái sử dụng ở nhiều màn hình.
- Hàm build() không quá dài.
- Không lặp lại cùng một đoạn UI ở nhiều nơi.

# 4. Tách logic khỏi UI

Một lỗi phổ biến là viết toàn bộ xử lý trong màn hình UI. Cách tốt hơn là đưa logic vào service, provider, controller hoặc view model.

// Không nên đặt quá nhiều xử lý trong onPressed
onPressed: () {
// validate form
// gọi API
// xử lý response
// lưu token
// chuyển màn hình
}

- UI chủ yếu chịu trách nhiệm hiển thị.
- Logic xử lý nghiệp vụ được tách riêng.
- Gọi API không viết trực tiếp lộn xộn trong widget.
- Dữ liệu được xử lý qua model/service/repository nếu project đủ lớn.

# 5. Quản lý state hợp lý

Ứng dụng mobile thường có nhiều trạng thái: loading, success, error, empty data, selected item, login state, cart state.

- Biết dùng setState() cho trường hợp đơn giản.
- Biết dùng Provider, Bloc, Riverpod hoặc GetX nếu project có nhiều màn hình.
- Không lạm dụng biến global.
- Khi dữ liệu thay đổi, UI cập nhật đúng.
- Có xử lý trạng thái loading, lỗi và dữ liệu rỗng.

Loading → đang tải dữ liệu
Success → hiển thị dữ liệu
Empty → không có dữ liệu
Error → hiển thị thông báo lỗi

# 6. Xử lý navigation đúng

Ứng dụng cần chuyển màn hình rõ ràng, truyền dữ liệu đúng và hoạt động ổn định khi người dùng bấm nút quay lại.

- Có cấu hình route rõ ràng.
- Không điều hướng lộn xộn.
- Biết truyền tham số giữa các màn hình.
- Back button hoạt động đúng.
- Không bị lỗi khi quay lại màn hình trước.

Navigator.pushNamed(
context,
'/product-detail',
arguments: productId,
);

# 7. Quản lý dữ liệu bằng model

Sinh viên không nên xử lý dữ liệu bằng Map tùy tiện ở mọi nơi. Nên tạo model cho các entity chính như Product, User, CartItem, Order.

// Chưa tốt
product\['name'\];
product\['price'\];
product\['image'\];

// Tốt hơn
product.name;
product.price;
product.imageUrl;

- Có tạo class model cho các entity chính.
- Model có tên rõ ràng.
- Có xử lý chuyển đổi JSON nếu có gọi API.
- Dữ liệu được truyền giữa các màn hình có cấu trúc rõ ràng.

# 8. Xử lý lỗi và ngoại lệ

Ứng dụng không nên bị crash khi có lỗi mạng, dữ liệu rỗng hoặc người dùng nhập sai.

- Có validate form.
- Có thông báo lỗi thân thiện.
- Có try-catch khi gọi API hoặc xử lý dữ liệu nguy cơ lỗi.
- Không để app crash khi dữ liệu null.
- Có xử lý khi không có Internet hoặc server lỗi.

try {
final products = await productService.getProducts();
} catch (e) {
showErrorMessage('Không thể tải danh sách sản phẩm');
}

# 9. Giao diện responsive và không bị overflow

Với Flutter, lỗi rất phổ biến là giao diện bị tràn màn hình. Sinh viên cần kiểm thử trên nhiều kích thước màn hình khác nhau.

- Không bị lỗi RenderFlex overflowed.
- Có dùng Expanded, Flexible, SingleChildScrollView, ListView đúng chỗ.
- Giao diện chạy tốt trên nhiều kích thước màn hình.
- Không hard-code quá nhiều chiều rộng, chiều cao.
- Có dùng SafeArea khi cần.

SafeArea(
child: SingleChildScrollView(
child: Column(
children: \[...\],
),
),
)

# 10. Tái sử dụng code

Code tốt là code không bị lặp lại quá nhiều. Các phần dùng chung nên được đưa vào widget, constants hoặc utility riêng.

- Các widget dùng nhiều lần được tách riêng.
- Các hằng số như màu sắc, text, route, padding được quản lý tập trung.
- Không copy-paste cùng một đoạn code sang nhiều màn hình.
- Có file quản lý AppStrings, AppColors, AppRoutes, AppSizes.

class AppStrings {
static const String login = 'Đăng nhập';
static const String addToCart = 'Thêm vào giỏ hàng';
}

# 11. Quản lý tài nguyên tốt

Ứng dụng mobile cần quản lý ảnh, icon, font, API endpoint và các tài nguyên khác rõ ràng.

- Asset được khai báo đúng trong pubspec.yaml.
- Không để đường dẫn ảnh rải rác khắp code.
- Không hard-code URL API ở nhiều nơi.
- Có file cấu hình riêng cho endpoint, asset, icon.
- Không đưa thông tin nhạy cảm trực tiếp vào source code.

# 12. Hiệu năng cơ bản

Với project sinh viên, không cần tối ưu quá sâu nhưng cần tránh các lỗi hiệu năng cơ bản.

- Dùng ListView.builder() cho danh sách dài.
- Dùng const constructor khi có thể.
- Không gọi API lặp lại không cần thiết trong build().
- Không rebuild toàn bộ màn hình khi chỉ một phần nhỏ thay đổi.
- Ảnh tải từ mạng có kích thước hợp lý.

// Không nên gọi API trực tiếp trong build
Widget build(BuildContext context) {
fetchProducts();
return ...;
}

# 13. Code có khả năng mở rộng

Một ứng dụng tốt cần có khả năng phát triển thêm chức năng mà không làm vỡ cấu trúc cũ.

- Thêm màn hình mới không làm vỡ cấu trúc cũ.
- Thêm API mới không phải sửa quá nhiều nơi.
- Thêm loại sản phẩm, trạng thái đơn hàng hoặc phương thức thanh toán mới dễ dàng.
- Code không bị phụ thuộc chặt giữa các màn hình.

# 14. Tuân thủ coding convention

Sinh viên cần tuân thủ quy ước viết code của Dart/Flutter.

- Tên class dùng PascalCase: ProductCard.
- Tên biến, hàm dùng camelCase: productName, getProducts().
- Tên file dùng snake\_case: product\_detail\_screen.dart.
- Không có warning nghiêm trọng.
- Code đã được format bằng Dart formatter.

# 15. Có kiểm thử hoặc kiểm tra chức năng cơ bản

Với project môn học, có thể không yêu cầu test phức tạp, nhưng cần có kiểm tra chức năng rõ ràng.

- Các chức năng chính đã được test thủ công.
- Form validation hoạt động đúng.
- Navigation không lỗi.
- Dữ liệu thêm/sửa/xóa đúng.
- Có thể có unit test hoặc widget test nếu yêu cầu cao hơn.

# Bảng tiêu chí chấm gợi ý

| **Nhóm tiêu chí** | **Nội dung chấm** | **Tỷ trọng gợi ý** |
| Cấu trúc project | Chia thư mục, file, module rõ ràng | 10% |
| Chất lượng code | Dễ đọc, tên biến rõ, format tốt | 10% |
| Tách widget | UI được chia nhỏ, dễ tái sử dụng | 10% |
| Tách logic khỏi UI | Có service/model/provider/controller | 10% |
| Quản lý state | State cập nhật đúng, không dùng global bừa bãi | 10% |
| Navigation | Chuyển màn hình, truyền dữ liệu, back đúng | 8% |
| Model & dữ liệu | Có model, xử lý JSON/dữ liệu rõ ràng | 8% |
| Xử lý lỗi | Validate, try-catch, thông báo lỗi | 8% |
| Responsive UI | Không overflow, chạy trên nhiều màn hình | 8% |
| Tái sử dụng & constants | Không lặp code, quản lý strings/routes/colors | 6% |
| Hiệu năng cơ bản | ListView.builder, const, không gọi API trong build | 6% |
| Hoàn thiện & test | Chạy ổn định, ít bug, test chức năng chính | 6% |

# Các lỗi nên trừ điểm mạnh

- Viết gần như toàn bộ app trong main.dart.
- Một hàm build() quá dài, khó đọc.
- Copy-paste code UI ở nhiều màn hình.
- Không có model, toàn dùng Map hoặc biến rời rạc.
- Gọi API trực tiếp trong build().
- Không xử lý lỗi mạng, lỗi dữ liệu rỗng.
- App crash khi nhập sai hoặc thiếu dữ liệu.
- Navigation bị lỗi hoặc back không đúng.
- Giao diện bị overflow trên màn hình nhỏ.
- Code có nhiều warning/error nhưng vẫn nộp.

# Kết luận

Khi chấm code ứng dụng mobile, không nên chỉ hỏi “app có chạy không?”. Cần đánh giá thêm các yếu tố sau:

Code có sạch không?
Có dễ đọc không?
Có dễ sửa không?
Có tách widget tốt không?
Có quản lý state đúng không?
Có xử lý lỗi không?
Có thể mở rộng tiếp không?

Với project Flutter của sinh viên, ba tiêu chí nên được xem là quan trọng nhất là:

1\. Cấu trúc project rõ ràng
2\. Tách UI thành widget nhỏ
3\. Tách logic xử lý khỏi UI

| **Kết luận ngắn:** Ba tiêu chí này thể hiện rõ sinh viên có biết lập trình ứng dụng mobile một cách bài bản hay chỉ làm cho ứng dụng “chạy được”. |
