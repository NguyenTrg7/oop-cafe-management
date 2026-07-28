#include "Order.h"
#include <iostream>
#include <iomanip>

// Khởi tạo constructor mặc định
Order::Order(const QString &id, Customer *customer)
{
    // TODO: Khởi tạo các giá trị mặc định cho đơn hàng (ví dụ: trạng thái, mã đơn, v.v.)
// Constructor khởi tạo đầy đủ thuộc tính ban đầu
Order::Order(const QString& id, Customer* customer)
    : m_ID(id), m_customer(customer), m_totalPrice(0.0), m_status("Pending")
{
    m_date = QDateTime::currentDateTime();
}

// Thêm món vào danh sách đơn hàng
void Order::addItem(const Menu& item) {
    m_items.append(item);
    m_totalPrice += item.getPrice();
}

// Xóa món khỏi danh sách đơn hàng theo ID món
void Order::removeItem(const QString& itemId) {
    for (int i = 0; i < m_items.size(); ++i) {
        if (m_items[i].getId() == itemId) {
            m_totalPrice -= m_items[i].getPrice();
            if (m_totalPrice < 0) m_totalPrice = 0;
            m_items.removeAt(i);
            break;
        }
    }
}

void Order::printInvoice() const {
    std::cout << "\n========================================" << std::endl;
    std::cout << "           HOA DON GIANG COFFEE         " << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "Ma don hang : " << m_ID.toStdString() << std::endl;
    std::cout << "Thoi gian   : " << m_date.toString("yyyy-MM-dd hh:mm:ss").toStdString() << std::endl;

    if (m_customer) {
        std::cout << "Khach hang  : " << m_customer->getName().toStdString() << std::endl;
    } else {
        std::cout << "Khach hang  : Khach vang lai" << std::endl;
    }

    std::cout << "----------------------------------------" << std::endl;
    std::cout << "Danh sach mon:" << std::endl;
    for (const auto& item : m_items) {
        std::cout << " - " << item.getName().toStdString()
        << " (" << item.getSizes().join("|").toStdString() << ") : "
        << item.getPrice() << " VND" << std::endl;
    }
    std::cout << "----------------------------------------" << std::endl;
    std::cout << "Tong tien   : " << m_totalPrice << " VND" << std::endl;
    std::cout << "Trang thai  : " << m_status.toStdString() << std::endl;
    std::cout << "========================================\n" << std::endl;
}