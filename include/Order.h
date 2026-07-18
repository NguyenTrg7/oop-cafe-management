#ifndef ORDER_H
#define ORDER_H

#include <QString>
#include <QList>
#include <QDateTime>
#include "Menu.h" // Chứa class Menu (itemId, itemName, price, size, status)
#include "Customer.h"

class Order {
protected:
    QString m_ID;           //
    QDateTime m_date;       //[cite: 2]
    Customer* m_customer;   //[cite: 2]
    QList<Menu> m_items;    //[cite: 2]
    double m_totalPrice;    //[cite: 2]
    QString m_status;       //[cite: 2]

public:
    Order(const QString& id, Customer* customer);
    virtual ~Order() = default;

    void addItem(const Menu& item);         //[cite: 2]
    void removeItem(const QString& itemId); //[cite: 2]
    void printInvoice() const;              //[cite: 2]

    // Hàm ảo (Virtual function) để tính Đa hình[cite: 2]
    virtual void calculate() = 0;           //[cite: 2]

    double getTotalPrice() const { return m_totalPrice; }
};

#endif // ORDER_H