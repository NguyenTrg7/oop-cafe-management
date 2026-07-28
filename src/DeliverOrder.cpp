#include "DeliverOrder.h"

// Gọi constructor của lớp cha (Order)
DeliverOrder::DeliverOrder(const QString& id, Customer* customer, const QString& address, double fee) :
    Order(id,customer),m_shippingAddress(address)
{

    // Cài đặt các thông số riêng cho đơn giao hàng
    // Ví dụ: deliveryFee = 15000.0;
    //        driverName = "Giao hàng tiết kiệm";
}

DeliverOrder::~DeliverOrder() {}

void DeliverOrder::calculate(){

}

// Gợi ý hàm tính tổng tiền (ghi đè từ lớp Order):
// double DeliverOrder::calculateTotal() {
//     // Tính tiền món + tiền ship
//     return 0.0;
// }