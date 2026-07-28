#include "Menu.h"
#include <iostream>
#include <QDebug>

Menu::Menu()
    : m_id(""), m_name(""), m_price(0.0), m_category("Coffee"), m_sizes({"M"}), m_status("Available") {}

Menu::Menu(const QString& id, const QString& name, const QString& category, double price, const QStringList& sizes, const QString& status)
    : m_id(id), m_name(name), m_price(price), m_category(category), m_sizes(sizes), m_status(status) {}

Menu::~Menu() {}

double Menu::calculatePriceForSize(const QString& size) const{
    double finalPrice = m_price;
    QString upperSize = size.trimmed().toUpper();

    if (upperSize == "M"){
        finalPrice += 5000.0;
    }
    else if (upperSize == "L"){
        finalPrice += 10000.0;
    }
    return finalPrice;
}

void Menu::displayMenu() const {
    std::cout << "[" << m_id.toStdString() << "] "
              << m_name.toStdString() << " - "
              << m_price << " VND ("
              << m_category.toStdString() << " | Size: "
              << m_sizes.join("|").toStdString() << ")" << std::endl;
}