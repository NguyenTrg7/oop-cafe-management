#include "Customer.h"
#include <QDebug>

Customer::Customer(const QString& id, const QString& name, int points, QObject *parent)
    : User(id, name, parent), m_loyaltyPoints(points) {}

int Customer::loyaltyPoints() const { return m_loyaltyPoints; }

void Customer::setLoyaltyPoints(int points) {
    if (m_loyaltyPoints != points) {
        m_loyaltyPoints = points;
        emit loyaltyPointsChanged();
    }
}

QString Customer::role() const {
    return "Customer";
}

void Customer::displayInfo() const {
    qDebug() << "Khách hàng:" << m_name << "| Điểm:" << m_loyaltyPoints;
}