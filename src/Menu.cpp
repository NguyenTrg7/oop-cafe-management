#include "Menu.h"
#include <algorithm> // Thư viện hỗ trợ hàm xóa (remove_if)
#include <iostream>

Menu::Menu()
{
    // Khởi tạo sẵn một vài món signature của Giang Coffee khi chạy chương trình
    addMenuItem("C01", "Ca phe sua da", 29000, "Coffee");
    addMenuItem("C02", "Ca phe den", 25000, "Coffee");
    addMenuItem("T01", "Tra dao cam sa", 35000, "Tea");
    addMenuItem("T02", "Tra vai", 35000, "Tea");
}

Menu::~Menu()
{
    // Dọn dẹp bộ nhớ (nếu có)
}

void Menu::addMenuItem(const std::string &id,
                       const std::string &name,
                       double price,
                       const std::string &category)
{
    items.push_back({id, name, price, category});
    // std::cout << "[Menu] Da them: " << name << std::endl;
}

void Menu::removeMenuItem(const std::string &id)
{
    // Sử dụng erase-remove idiom của C++ để tìm và xóa món nước theo ID
    items.erase(std::remove_if(items.begin(),
                               items.end(),
                               [&id](const MenuItem &item) { return item.id == id; }),
                items.end());
    // std::cout << "[Menu] Da xoa mon co ID: " << id << std::endl;
}

void Menu::displayMenu() const
{
    std::cout << "\n--- MENU GIANG COFFEE ---" << std::endl;
    for (const auto &item : items) {
        std::cout << "[" << item.id << "] " << item.name << " - " << item.price << " VND ("
                  << item.category << ")" << std::endl;
    }
    std::cout << "-------------------------\n";
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