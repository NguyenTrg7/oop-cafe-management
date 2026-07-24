#include "Menu.h"
#include <iostream>
#include <QDebug>

Menu::Menu()
    : m_id(""), m_name(""), m_price(0.0), m_category("Coffee"), m_size("M"), m_status("Available") {}

Menu::Menu(const QString& id, const QString& name, double price, const QString& category, const QString& size, const QString& status)
    : m_id(id), m_name(name), m_price(price), m_category(category), m_size(size), m_status(status) {}

Menu::~Menu() {}

void Menu::displayMenu() const {
    std::cout << "[" << m_id.toStdString() << "] "
              << m_name.toStdString() << " - "
              << m_price << " VND ("
              << m_category.toStdString() << " | Size: "
              << m_size.toStdString() << ")" << std::endl;
}