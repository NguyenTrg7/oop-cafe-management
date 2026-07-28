#ifndef GIANGCOFFEESYSTEM_H
#define GIANGCOFFEESYSTEM_H

#include <QObject>
#include <QList>
#include "Employee.h"
#include "Menu.h"
#include "Ingredient.h"
#include "Supplier.h"
#include "Order.h"
#include "Seating.h"
#include "Account.h"

// Sử dụng Singleton Pattern
class GiangCoffeeSystem : public QObject {
    Q_OBJECT

private:
    // Private Constructor để ngăn tạo đối tượng tự do
    explicit GiangCoffeeSystem(QObject *parent = nullptr);
    static GiangCoffeeSystem* m_instance;

    // Các danh sách quản lý theo UML[cite: 2]
    QString m_address;
    QList<Employee*> m_employees_list;
    QList<Menu> m_menuItems;
    QList<Ingredient> m_ingredients;
    QList<Supplier> m_suppliers;
    QList<Order*> m_orders;
    QList<Seating> m_tables;
    QList<Account> m_accounts;
    QList<QString> m_receipts;

public:
    // Phương thức truy xuất Instance duy nhất (Singleton)
    static GiangCoffeeSystem* getInstance();
    ~GiangCoffeeSystem();
    // -- Employee Management[cite: 2] --
    Q_INVOKABLE void addEmployee(Employee* emp);
    Q_INVOKABLE void removeEmployee(const QString& empID);
    Q_INVOKABLE void updateEmployeeShift(const QString& id, const QString& shift);
    Q_INVOKABLE void calculatePayroll(); // calulate()[cite: 2]

    // -- Menu Management[cite: 2] --
    Q_INVOKABLE void addItem(const Menu& item);
    Q_INVOKABLE void removeItem(const QString& itemId);
    Q_INVOKABLE Menu searchMenu(const QString& name);
    Q_INVOKABLE void printMenu();

    // -- Inventory Management[cite: 2] --
    void addIngredient(const Ingredient& ing);
    void addSup(const Supplier& sup);
    void createInventory(); // Nhận hoặc hoàn hàng[cite: 2]

    // -- Table Management[cite: 2] --
    Q_INVOKABLE void placeOrder(Order* order);
    Q_INVOKABLE void reserveTable(int tableNum); // reserve(int TableNum)[cite: 2]
    Q_INVOKABLE void mergeTable(int num1, int num2);
    Q_INVOKABLE QVariantList getSeatingList() const;

    // Sửa thông tin bàn (vị trí + hình dạng)
   Q_INVOKABLE void editTable(int tableNumber, const QString& shape, int capacity);

    Q_INVOKABLE void clearTable(int tableNum);   // Hủy đặt bàn
    // Đổi số bàn
    Q_INVOKABLE bool renameTable(int oldNumber, int newNumber);

    // Hủy gộp bàn (tách bàn có sức chứa > 4 thành 2 bàn 4 ghế)
    Q_INVOKABLE bool undoMerge(int tableNumber);


    // -- Financial Management[cite: 2] --
    Q_INVOKABLE void generateReport(const QDateTime& date);
};

#endif // GIANGCOFFEESYSTEM_H