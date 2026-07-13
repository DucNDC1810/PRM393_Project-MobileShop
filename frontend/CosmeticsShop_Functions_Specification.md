**✿ MOBILE APPLICATION ✿**

**Đặc Tả Chức Năng Chính**

**Ứng Dụng Bán Mỹ Phẩm**

Beauty & Glow Cosmetics Shop

Môn học: PRM393 – Mobile Application Development (Flutter)

Học kỳ: Hè 2025 – 2026

# **1\. Thiết Kế Cơ Sở Dữ Liệu / Cấu Trúc API**

Nhóm cần thiết kế cấu trúc dữ liệu hoặc API để phục vụ toàn bộ ứng dụng bán mỹ phẩm. Có thể sử dụng SQLite, Firebase Firestore hoặc REST API backend.

## ▸ **Các nhóm dữ liệu chính**

| **Nhóm dữ liệu** | **Mô tả** |
| --- | --- |
| User / Customer | Lưu thông tin tài khoản khách hàng: họ tên, email, số điện thoại, địa chỉ giao hàng, mật khẩu đã mã hóa hoặc thông tin đăng nhập Firebase. |
| Product | Lưu thông tin sản phẩm mỹ phẩm: tên sản phẩm, thương hiệu, hình ảnh, giá bán, giá khuyến mãi, mô tả, thành phần, dung tích, loại da phù hợp, tồn kho. |
| Category / Brand | Lưu danh mục hoặc thương hiệu như Innisfree, The Face Shop, L'Oréal, Maybelline, MAC, Laneige. |
| Cart | Lưu các sản phẩm khách hàng đã thêm vào giỏ hàng: sản phẩm, số lượng, người dùng. |
| Order | Lưu thông tin đơn hàng: khách hàng, sản phẩm, tổng tiền, địa chỉ giao hàng, trạng thái đơn hàng. |
| Notification | Lưu thông báo khuyến mãi, cập nhật đơn hàng, sản phẩm mới về, thông báo hệ thống. |
| Store Location | Lưu thông tin vị trí cửa hàng để hiển thị trên bản đồ: tên, địa chỉ, tọa độ, hotline, giờ mở cửa. |
| Message / Chat | Lưu nội dung trao đổi giữa khách hàng và cửa hàng: tin nhắn, người gửi, thời gian. |

## ▸ **Nhóm cần trình bày rõ**

- Sơ đồ database hoặc mô tả collection/table.
- Quan hệ giữa các bảng hoặc collection.
- API endpoint nếu dùng REST API.
- Cách ứng dụng đọc, ghi, cập nhật và xóa dữ liệu.
- Cách dữ liệu được sử dụng trong từng màn hình.

# **2\. Màn Hình Đăng Nhập (Login Screen)**

Chức năng này cho phép khách hàng đăng nhập vào ứng dụng để sử dụng các chức năng cá nhân như giỏ hàng, đặt hàng, xem đơn hàng và nhận thông báo.

## ▸ **Mục đích**

Đảm bảo chỉ người dùng đã có tài khoản mới có thể thực hiện các thao tác liên quan đến mua hàng và quản lý thông tin cá nhân.

## ▸ **Mô tả xử lý**

Khi mở ứng dụng, người dùng được đưa đến màn hình đăng nhập nếu chưa đăng nhập trước đó. Người dùng nhập email/số điện thoại và mật khẩu, sau đó bấm nút Login.

Ứng dụng sẽ kiểm tra:

- Người dùng đã nhập đủ thông tin hay chưa.
- Email hoặc số điện thoại có đúng định dạng không.
- Mật khẩu có hợp lệ không (tối thiểu 6 ký tự).
- Tài khoản có tồn tại trong hệ thống không.

Nếu thông tin hợp lệ, ứng dụng chuyển người dùng đến màn hình chính. Nếu sai, hiển thị thông báo lỗi rõ ràng, ví dụ: "Email hoặc mật khẩu không đúng".

## ▸ **Input / Output**

| **Loại** | **Nội dung** |
| --- | --- |
| Input | Email hoặc số điện thoại; Mật khẩu. |
| Output | Đăng nhập thành công → chuyển sang màn hình chính; Hoặc hiển thị thông báo lỗi. |

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Có kiểm tra dữ liệu nhập vào (validation). | ☐ |
| 2 | Có hiển thị lỗi cụ thể khi nhập sai thông tin. | ☐ |
| 3 | Có lưu trạng thái đăng nhập (không cần đăng nhập lại). | ☐ |
| 4 | Có phân biệt người dùng đã đăng nhập và chưa đăng nhập. | ☐ |
| 5 | Giao diện rõ ràng, dễ sử dụng, phù hợp với thương hiệu mỹ phẩm. | ☐ |

# **3\. Màn Hình Danh Sách Sản Phẩm (Product List Screen)**

Chức năng này hiển thị danh sách các sản phẩm mỹ phẩm đang được bán trong cửa hàng.

## ▸ **Mục đích**

Giúp khách hàng xem nhanh các sản phẩm hiện có, tìm kiếm sản phẩm phù hợp và chọn sản phẩm để xem chi tiết.

## ▸ **Mô tả xử lý**

Khi người dùng truy cập màn hình danh sách, ứng dụng lấy dữ liệu sản phẩm từ database hoặc API và hiển thị thành danh sách hoặc dạng lưới.

Mỗi sản phẩm nên hiển thị:

- Hình ảnh sản phẩm mỹ phẩm.
- Tên sản phẩm và thương hiệu.
- Giá bán và giá khuyến mãi (nếu có).
- Trạng thái còn hàng hoặc hết hàng.

Ứng dụng nên có chức năng tìm kiếm hoặc lọc sản phẩm theo:

- Tên sản phẩm.
- Thương hiệu (Innisfree, L'Oréal, MAC...).
- Khoảng giá.
- Loại sản phẩm (skincare, makeup, perfume...).
- Sản phẩm khuyến mãi hoặc còn hàng.

## ▸ **Input / Output**

| **Loại** | **Nội dung** |
| --- | --- |
| Input | Danh sách sản phẩm từ database/API; Từ khóa tìm kiếm; Điều kiện lọc. |
| Output | Danh sách sản phẩm hiển thị; Kết quả sau lọc/tìm; Điều hướng sang màn hình chi tiết. |

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Có hiển thị danh sách sản phẩm từ dữ liệu thật. | ☐ |
| 2 | Có hình ảnh, tên, thương hiệu và giá sản phẩm. | ☐ |
| 3 | Có xử lý trạng thái loading khi tải dữ liệu. | ☐ |
| 4 | Có xử lý trường hợp không có sản phẩm. | ☐ |
| 5 | Có chức năng tìm kiếm hoặc lọc sản phẩm. | ☐ |
| 6 | Có điều hướng sang màn hình chi tiết sản phẩm. | ☐ |

# **4\. Màn Hình Chi Tiết Sản Phẩm (Product Detail Screen)**

Chức năng này hiển thị thông tin chi tiết của một sản phẩm mỹ phẩm được khách hàng chọn từ danh sách.

## ▸ **Mục đích**

Giúp khách hàng hiểu rõ sản phẩm trước khi quyết định thêm vào giỏ hàng hoặc mua hàng.

## ▸ **Mô tả xử lý**

Khi người dùng chọn một sản phẩm, ứng dụng mở màn hình chi tiết và hiển thị đầy đủ thông tin:

- Hình ảnh sản phẩm (có thể swipe nhiều ảnh).
- Tên sản phẩm và thương hiệu.
- Giá bán và giá khuyến mãi (nếu có).
- Mô tả sản phẩm và công dụng.
- Thành phần chính (key ingredients).
- Dung tích / Trọng lượng.
- Loại da phù hợp (da dầu, da khô, da hỗn hợp...).
- Hướng dẫn sử dụng.
- Tình trạng còn hàng.
- Chính sách đổi trả.
- Nút Thêm vào giỏ hàng (Add to Cart).

Nếu sản phẩm hết hàng, nút Add to Cart bị ẩn hoặc vô hiệu hóa kèm thông báo rõ ràng.

## ▸ **Input / Output**

| **Loại** | **Nội dung** |
| --- | --- |
| Input | Mã sản phẩm hoặc đối tượng sản phẩm được chọn; Số lượng người dùng muốn mua. |
| Output | Hiển thị thông tin chi tiết; Thêm vào giỏ hàng nếu hợp lệ; Thông báo thành công hoặc lỗi. |

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Hiển thị đầy đủ thông tin sản phẩm mỹ phẩm. | ☐ |
| 2 | Có thông tin thành phần và loại da phù hợp. | ☐ |
| 3 | Có xử lý trạng thái còn hàng / hết hàng. | ☐ |
| 4 | Có nút Thêm vào giỏ hàng. | ☐ |
| 5 | Có cập nhật giỏ hàng sau khi thêm sản phẩm. | ☐ |
| 6 | Có thông báo phản hồi cho người dùng. | ☐ |

# **5\. Màn Hình Giỏ Hàng (Shopping Cart Screen)**

Chức năng này cho phép khách hàng xem và quản lý các sản phẩm đã thêm vào giỏ hàng.

## ▸ **Mục đích**

Giúp khách hàng kiểm tra lại sản phẩm muốn mua trước khi tiến hành thanh toán.

## ▸ **Mô tả xử lý**

Khi người dùng mở màn hình giỏ hàng, ứng dụng hiển thị danh sách sản phẩm đã thêm. Mỗi dòng sản phẩm nên có:

- Hình ảnh sản phẩm.
- Tên sản phẩm và thương hiệu.
- Giá bán.
- Số lượng và nút tăng/giảm số lượng.
- Thành tiền.
- Nút xóa sản phẩm khỏi giỏ hàng.

Khi số lượng thay đổi, ứng dụng tự động cập nhật lại tổng tiền. Nếu giỏ hàng rỗng, hiển thị thông báo phù hợp như "Giỏ hàng của bạn đang trống".

## ▸ **Input / Output**

| **Loại** | **Nội dung** |
| --- | --- |
| Input | Danh sách sản phẩm trong giỏ; Thao tác tăng/giảm số lượng; Xóa sản phẩm; Chuyển sang thanh toán. |
| Output | Giỏ hàng được cập nhật; Tổng tiền tính lại; Chuyển sang màn hình Checkout. |

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Hiển thị đúng sản phẩm đã thêm vào giỏ. | ☐ |
| 2 | Có cập nhật số lượng sản phẩm. | ☐ |
| 3 | Có xóa sản phẩm khỏi giỏ hàng. | ☐ |
| 4 | Có tính tổng tiền chính xác. | ☐ |
| 5 | Có xử lý trường hợp giỏ hàng rỗng. | ☐ |
| 6 | Có điều hướng sang màn hình Checkout. | ☐ |

# **6\. Màn Hình Thanh Toán (Checkout / Billing Screen)**

Chức năng này cho phép khách hàng xác nhận đơn hàng và thực hiện bước đặt mua sản phẩm mỹ phẩm.

## ▸ **Mục đích**

Hoàn tất quá trình mua hàng bằng cách thu thập thông tin giao hàng, phương thức thanh toán và tạo đơn hàng trong hệ thống.

## ▸ **Mô tả xử lý**

Khi người dùng bấm Checkout, ứng dụng mở màn hình thanh toán hiển thị:

- Danh sách sản phẩm và số lượng.
- Tổng tiền hàng và phí giao hàng (nếu có).
- Tổng tiền thanh toán.

Người dùng cần nhập thông tin giao hàng:

- Họ tên người nhận.
- Số điện thoại.
- Địa chỉ giao hàng.
- Ghi chú (nếu có).

Người dùng chọn phương thức thanh toán:

- Thanh toán khi nhận hàng (COD).
- Chuyển khoản ngân hàng.
- Ví điện tử giả lập (nếu nhóm muốn minh họa).

Sau khi bấm Đặt Hàng, hệ thống tạo đơn hàng mới, lưu vào database, xóa giỏ hàng và hiển thị thông báo thành công.

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Có hiển thị tóm tắt đơn hàng. | ☐ |
| 2 | Có nhập và kiểm tra thông tin giao hàng. | ☐ |
| 3 | Có chọn phương thức thanh toán. | ☐ |
| 4 | Có tạo đơn hàng trong database/API. | ☐ |
| 5 | Có xóa giỏ hàng sau khi đặt hàng thành công. | ☐ |
| 6 | Có thông báo kết quả cho người dùng. | ☐ |

# **7\. Màn Hình Thông Báo (Notifications Screen)**

Chức năng này hiển thị các thông báo liên quan đến khách hàng, sản phẩm mỹ phẩm và đơn hàng.

## ▸ **Mục đích**

Giúp khách hàng nhận được thông tin mới từ cửa hàng như khuyến mãi, sản phẩm mới về, xác nhận đơn hàng hoặc cập nhật trạng thái giao hàng.

## ▸ **Mô tả xử lý**

Ứng dụng hiển thị danh sách thông báo từ database hoặc Firebase Cloud Messaging. Thông báo có thể gồm:

- Thông báo khuyến mãi mỹ phẩm (Flash Sale, giảm giá theo mùa...).
- Thông báo sản phẩm mới nhập về.
- Thông báo đơn hàng đã được xác nhận.
- Thông báo đơn hàng đang giao / đã hoàn tất.
- Thông báo từ cửa hàng (tin tức làm đẹp, tips skincare...).

Mỗi thông báo nên có: tiêu đề, nội dung ngắn, thời gian gửi, trạng thái đã đọc hoặc chưa đọc.

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Có danh sách thông báo. | ☐ |
| 2 | Có tiêu đề, nội dung và thời gian thông báo. | ☐ |
| 3 | Có phân biệt đã đọc / chưa đọc. | ☐ |
| 4 | Có xử lý khi không có thông báo. | ☐ |
| 5 | Có thể mở chi tiết thông báo. | ☐ |
| 6 | Dữ liệu thông báo phù hợp với ngữ cảnh cửa hàng mỹ phẩm. | ☐ |

# **8\. Màn Hình Bản Đồ Cửa Hàng (Map Store Location Screen)**

Chức năng này hiển thị vị trí cửa hàng mỹ phẩm trên bản đồ.

## ▸ **Mục đích**

Giúp khách hàng biết địa chỉ cửa hàng, xem vị trí trên bản đồ và tìm đường đến cửa hàng dễ dàng.

## ▸ **Mô tả xử lý**

Khi người dùng mở màn hình bản đồ, ứng dụng hiển thị vị trí cửa hàng trên Google Map hoặc thư viện bản đồ phù hợp trong Flutter.

Thông tin cửa hàng mẫu:

| **Thông tin** | **Chi tiết** |
| --- | --- |
| Tên cửa hàng | Beauty & Glow Cosmetics |
| Địa chỉ | 456 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh |
| Hotline | 0909 888 777 |
| Giờ mở cửa | 9:00 – 22:00 (Thứ 2 – Chủ Nhật) |
| Website | www.beautyandglow.vn |

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Có hiển thị bản đồ. | ☐ |
| 2 | Có marker đánh dấu vị trí cửa hàng. | ☐ |
| 3 | Có thông tin địa chỉ và liên hệ. | ☐ |
| 4 | Có thể mở ứng dụng bản đồ bên ngoài để chỉ đường (nếu triển khai thêm). | ☐ |
| 5 | Có xử lý quyền truy cập vị trí nếu dùng vị trí hiện tại của người dùng. | ☐ |

# **9\. Màn Hình Nhắn Tin / Tư Vấn (Messaging / Chat Screen)**

Chức năng này cho phép khách hàng nhắn tin với cửa hàng để hỏi thông tin sản phẩm mỹ phẩm hoặc hỗ trợ đơn hàng.

## ▸ **Mục đích**

Tạo kênh tư vấn làm đẹp và hỗ trợ khách hàng ngay trong ứng dụng, giúp khách hàng hỏi nhanh về sản phẩm, thành phần, cách dùng, tình trạng còn hàng hoặc trạng thái đơn hàng.

## ▸ **Mô tả xử lý**

Khi người dùng mở màn hình chat, ứng dụng hiển thị khung hội thoại. Người dùng có thể nhập và gửi tin nhắn. Nội dung chat phù hợp với cửa hàng mỹ phẩm:

- Hỏi sản phẩm phù hợp với loại da.
- Hỏi thành phần có gây kích ứng không.
- Hỏi chính sách đổi trả, bảo quản sản phẩm.
- Hỏi chương trình khuyến mãi hiện tại.
- Hỏi thông tin đơn hàng đang giao.

_💡 Nếu không xây dựng phần quản trị cho nhân viên, có thể triển khai chat giả lập (auto-reply). Nhóm vẫn cần lưu lịch sử tin nhắn để chứng minh có xử lý dữ liệu._

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Có giao diện chat rõ ràng. | ☐ |
| 2 | Có gửi và hiển thị tin nhắn. | ☐ |
| 3 | Có lưu lịch sử tin nhắn. | ☐ |
| 4 | Có phân biệt tin nhắn của khách hàng và cửa hàng. | ☐ |
| 5 | Có hiển thị thời gian gửi. | ☐ |
| 6 | Có xử lý trường hợp người dùng gửi tin nhắn rỗng. | ☐ |
| 7 | Có phản hồi từ cửa hàng hoặc phản hồi mẫu (auto-reply). | ☐ |

# **10\. Quản Lý Trạng Thái – State Management (Provider / Bloc)**

Chức năng này yêu cầu nhóm áp dụng cơ chế quản lý trạng thái trong Flutter, ví dụ Provider hoặc Bloc, để quản lý dữ liệu và trạng thái của toàn bộ ứng dụng.

## ▸ **Mục đích**

Giúp ứng dụng hoạt động ổn định, dễ bảo trì và dễ mở rộng. State management giúp dữ liệu được cập nhật đồng bộ giữa các màn hình – ví dụ khi thêm sản phẩm vào giỏ hàng thì badge số lượng giỏ hàng cập nhật ngay.

## ▸ **Các phương pháp được chấp nhận**

- Provider (khuyến nghị cho người mới).
- Bloc / Cubit.
- Riverpod (nếu được giảng viên chấp nhận).

## ▸ **Các State cần quản lý**

| **State** | **Mô tả** |
| --- | --- |
| Authentication State | Quản lý trạng thái đã đăng nhập / chưa đăng nhập. |
| Product State | Quản lý danh sách sản phẩm mỹ phẩm, trạng thái loading, lỗi tải dữ liệu. |
| Cart State | Quản lý sản phẩm trong giỏ hàng, số lượng, tổng tiền. |
| Order State | Quản lý quá trình tạo đơn hàng và trạng thái đặt hàng. |
| Notification State | Quản lý danh sách thông báo và trạng thái đã đọc. |
| Chat State | Quản lý danh sách tin nhắn và trạng thái gửi. |

## ▸ **Tiêu chí đánh giá**

| **STT** | **Tiêu chí đánh giá** | **Đạt** |
| --- | --- | --- |
| 1 | Có sử dụng Provider hoặc Bloc rõ ràng, có thể nhận biết trong code. | ☐ |
| 2 | Không xử lý toàn bộ logic trực tiếp trong UI widget. | ☐ |
| 3 | Có tách logic xử lý ra khỏi màn hình (separation of concerns). | ☐ |
| 4 | Có cập nhật UI khi dữ liệu thay đổi (reactive). | ☐ |
| 5 | Có quản lý trạng thái loading, success, error. | ☐ |
| 6 | Áp dụng vào ít nhất các chức năng: Login, Product List, Cart, Checkout. | ☐ |

**Luồng Demo Bắt Buộc**

**Login → Danh sách mỹ phẩm → Chi tiết sản phẩm → Thêm vào giỏ hàng → Cập nhật giỏ hàng → Checkout → Tạo đơn hàng → Nhận thông báo / Tư vấn chat / Xem vị trí cửa hàng**
