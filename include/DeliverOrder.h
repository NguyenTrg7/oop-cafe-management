#ifndef DELIVERORDER_H
#define DELIVERORDER_H
#include "Order.h"

class DeliverOrder : public Order {
private:
    QString m_shippingAddress; // shipping[cite: 2]
    double m_deliveryFee;      // deleveryFee[cite: 2]

public:
    DeliverOrder(const QString& id, Customer* customer, const QString& address, double fee);
    ~DeliverOrder();
    // Ghi đè: Đơn giao hàng = Tổng tiền món + m_deliveryFee[cite: 2]
    void calculate() override; //[cite: 2]
};
#endif // DELIVERORDER_H