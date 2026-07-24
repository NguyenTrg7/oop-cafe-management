#ifndef ORDER_H
#define ORDER_H

#include <QString>
#include <QList>
#include <QDateTime>
#include "Menu.h"
#include "Customer.h"

class Order {
protected:
    QString m_ID;
    QDateTime m_date;
    Customer* m_customer;
    QList<Menu> m_items;
    double m_totalPrice;
    QString m_status;

public:
    Order(const QString& id, Customer* customer = nullptr);
    virtual ~Order() = default;

    void addItem(const Menu& item);
    void removeItem(const QString& itemId);
    void printInvoice() const;

    // Hàm ảo thuần túy (Pure Virtual Function) phục vụ tính Đa hình (InStoreOrder / DeliverOrder)
    virtual void calculate() = 0;

    // Getters
    QString getID() const { return m_ID; }
    double getTotalPrice() const { return m_totalPrice; }
    QString getStatus() const { return m_status; }
    QList<Menu> getItems() const { return m_items; }

    // Setters
    void setStatus(const QString& status) { m_status = status; }
};

#endif // ORDER_H