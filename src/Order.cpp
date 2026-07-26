#include "Order.h"


// Khởi tạo constructor mặc định
Order::Order(const QString& id, Customer* customer) {
    // TODO: Khởi tạo các giá trị mặc định cho đơn hàng (ví dụ: trạng thái, mã đơn, v.v.)
}

// Hàm hủy (Virtual Destructor) rất quan trọng trong đa hình (Polymorphism)

// Gợi ý: Nếu trong Order.h bạn có khai báo các hàm tính tiền, hãy viết ở đây
// double Order::calculateTotal() {
//     return 0.0;
// }