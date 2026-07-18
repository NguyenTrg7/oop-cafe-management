#ifndef INSTOREORDER_H
#define INSTOREORDER_H
#include "Order.h"
#include "Seating.h" // Chứa thông tin tableNum, status, capacity[cite: 2]

class InStoreOrder : public Order {
private:
    Seating m_table; //[cite: 2]

public:
    InStoreOrder(const QString& id, Customer* customer, const Seating& table);
    ~InStoreOrder();
    // Ghi đè hàm tính toán tiền: Đơn tại quán có thể tính thêm phí VAT nhưng không có phí ship
    void calculate() override; //[cite: 2]
};
#endif // INSTOREORDER_H