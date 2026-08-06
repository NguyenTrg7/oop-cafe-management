#ifndef MENU_H
#define MENU_H

#include <QString>
#include <QStringList>

class Menu {
private:
    QString m_id;
    QString m_name;
    double m_price;
    QString m_category; // "Coffee", "Tea", "Cake"...
    QStringList m_sizes;     // "S", "M", "L"
    QString m_status;   // "Available", "OutOfStock"

public:

    Menu();
    Menu(const QString& id, const QString& name,
         const QString& category, double price , const QStringList& sizes, const QString& status);
    ~Menu();

    double calculatePriceForSize(const QString& size) const;

    // Getters
    QString getId() const { return m_id; }
    QString getName() const { return m_name; }
    double getPrice() const { return m_price; }
    QString getCategory() const { return m_category; }
    QStringList getSizes() const { return m_sizes; }
    QString getStatus() const { return m_status; }

    // Setters
    void setId(const QString& id) { m_id = id; }
    void setName(const QString& name) { m_name = name; }
    void setPrice(double price) { m_price = price; }
    void setCategory(const QString& category) { m_category = category; }
    void setSizes(const QStringList& size) { m_sizes = size; }
    void setStatus(const QString& status) { m_status = status; }

    // Phương thức hiển thị món
    void displayMenu() const;
};

#endif // MENU_H