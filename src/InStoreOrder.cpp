#include "InStoreOrder.h"

// Kế thừa từ Order
InStoreOrder::InStoreOrder(const QString &id, Customer *customer, const Seating &table)
    : Order(id, customer)
    , m_table(table)
{
    // TODO: Khởi tạo thông tin riêng cho đơn tại quán (ví dụ: Số bàn - tableNumber)
}

InStoreOrder::~InStoreOrder() {}

void InStoreOrder::calculate()
{
    this->m_totalPrice = 0.0;
}
// Gợi ý: Ghi đè hàm tính tiền (nếu không có phụ phí)
// double InStoreOrder::calculateTotal() {
//     // Tính tổng tiền các món
//     return 0.0;
// }