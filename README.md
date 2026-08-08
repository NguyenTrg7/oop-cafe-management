# ☕ Giang's Coffee - Management System v1.0

![Qt](https://img.shields.io/badge/Qt-%23217346.svg?style=for-the-badge&logo=Qt&logoColor=white)
![C++](https://img.shields.io/badge/c++-%2300599C.svg?style=for-the-badge&logo=c%2B%2B&logoColor=white)
![CMake](https://img.shields.io/badge/CMake-%23064F8C.svg?style=for-the-badge&logo=cmake&logoColor=white)

Hệ thống quản lý quán cà phê toàn diện được xây dựng bằng **C++** (Backend Logic) và **Qt/QML** (Frontend UI). Ứng dụng cung cấp giải pháp quản lý từ khâu bán hàng (POS), sơ đồ bàn, kho nguyên liệu, cho đến quản lý nhân sự và tài chính thu chi.


## Tính Năng Chính

Dự án được chia quyền sử dụng theo hai vai trò: **Quản lý** và **Nhân viên**.

*   **Bán hàng (POS) & Sơ đồ bàn:**
    *   Giao diện gọi món trực quan, phân loại Đồ uống/Món ăn.
    *   Quản lý sơ đồ bàn thực tế (mở bàn, ghép bàn, thanh toán).
    *   Tự động tính toán giá tiền, áp dụng mã giảm giá (Voucher).
    *   In hóa đơn chi tiết kèm mã QR thanh toán.
*   **Quản lý Kho hàng (Inventory):**
    *   Thiết lập định mức tồn kho và công thức pha chế.
    *   **Tự động trừ nguyên liệu** trong kho khi có đơn hàng mới.
    *   Cảnh báo nguyên liệu sắp hết (dưới mức tối thiểu).
*   **Quản lý Nhân sự & Điểm danh:**
    *   Tạo, sửa, xóa hồ sơ nhân viên.
    *   Lên lịch làm việc (Phân ca Part-time, Full-time).
    *   Hệ thống Check-in / Check-out tự động lưu thời gian thực.
    *   Bảng báo cáo điểm danh
*   **Quản lý Tài chính (Finance):**
    *   Theo dõi tổng thu, tổng chi và lợi nhuận ròng.
    *   Trực quan hóa dữ liệu bằng **Biểu đồ động** (thống kê theo Tuần/Tháng/Năm/Quý).
    *   Thêm các giao dịch thủ công (chi phí điện nước, mặt bằng, nhập hàng...).
*   **Chương trình Khách hàng thân thiết (Loyalty):**
    *   Tích điểm tự động dựa trên số lượng ly/món khách mua.
    *   Đổi điểm lấy mã giảm giá (Voucher 10%, 20%, 30%...).
*   **Lịch sử Giao dịch:**
    *   Lưu trữ toàn bộ lịch sử đơn hàng.
    *   Bộ lọc tìm kiếm thông minh theo Ngày, Tháng, Năm và Khung giờ.


## Công Nghệ Sử Dụng

*   **Ngôn ngữ lập trình:** C++ (OOP - Object Oriented Programming)
*   **Framework Giao diện:** Qt 6 / QML (Qt Quick)
*   **Hệ thống Build:** CMake
*   **Cơ sở dữ liệu:** File I/O (Lưu trữ bằng định dạng `.csv` và đọc xuất dữ liệu trực tiếp).
*   **Mã hóa:** SHA-256 (Bảo mật mật khẩu tài khoản).


## Cấu Trúc Thư Mục

```text
oop-cafe-management/
│
├── CMakeLists.txt        # File cấu hình build CMake
├── include/              # Thư mục chứa các file Header (.h)
├── src/                  # Thư mục chứa mã nguồn C++ (.cpp)
├── ui/                   # Thư mục chứa các file thiết kế giao diện QML (.qml)
├── data/                 # Thư mục chứa dữ liệu GỐC ban đầu (CSV, Hình ảnh)
│   ├── Drink/            # Hình ảnh đồ uống
│   ├── Food/             # Hình ảnh món ăn
│   └── *.csv             # Các file dữ liệu mẫu
└── saves/                # Thư mục tự động tạo khi build, chứa dữ liệu runtime