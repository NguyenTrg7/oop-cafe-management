#ifndef GIANGCOFFEESYSTEM_H
#define GIANGCOFFEESYSTEM_H

#include <QObject>
#include <QList>
#include <QDateTime>
#include <QVariantList>
#include <QVariantMap>

#include "Employee.h"
#include "Menu.h"
#include "Ingredient.h"
#include "Supplier.h"
#include "Order.h"
#include "Seating.h"
#include "Account.h"
#include "MenuManager.h"

class GiangCoffeeSystem : public QObject {
    Q_OBJECT
    Q_PROPERTY(MenuManager* menuManager READ getMenuManager CONSTANT)

private:
    explicit GiangCoffeeSystem(QObject *parent = nullptr);
    static GiangCoffeeSystem* m_instance;

    MenuManager* m_menuManager;
    QString m_address;
    QList<Employee*> m_employees_list;
    QList<Menu> m_menuItems;
    QList<Ingredient> m_ingredients;
    QList<Supplier> m_suppliers;
    QList<Order*> m_orders;
    QList<Seating> m_tables;

    void updateEmployeeInShifts(const QString &id, const QString &newName, const QString &newPhone);
    void deleteEmployeeShifts(const QString &id);
    void initializeSavesDirectory();

    double parseShiftDurationHours(const QString &timeStr);
    double getNetWorkingHours(const QString &timeStr);
    bool validateShiftTimeBounds(const QString &timeStr);

public:
    static GiangCoffeeSystem* getInstance();
    MenuManager* getMenuManager() const { return m_menuManager; }
    ~GiangCoffeeSystem() override;

    // Helper trỏ đường dẫn đồng nhất tới thư mục save/
    static QString getSaveFilePath(const QString &fileName);

    Q_INVOKABLE void addEmployee(Employee* emp);
    Q_INVOKABLE void removeEmployee(const QString& empID);

    Q_INVOKABLE QVariantList calculateMonthlyPayroll(int month, int year);

    Q_INVOKABLE void addItem(const Menu& item);
    Q_INVOKABLE void removeItem(const QString& itemId);
    Q_INVOKABLE Menu searchMenu(const QString& name);
    Q_INVOKABLE void printMenu();

    void addIngredient(const Ingredient& ing);
    void addSup(const Supplier& sup);
    void createInventory();

    Q_INVOKABLE void saveSeating();
    Q_INVOKABLE void loadSeating();

    Q_INVOKABLE void placeOrder(Order* order);
    Q_INVOKABLE void reserveTable(int tableNum);
    Q_INVOKABLE void setTableNote(int tableNumber, const QString &note);
    Q_INVOKABLE void clearTable(int tableNum);
    Q_INVOKABLE void mergeTable(int num1, int num2);
    Q_INVOKABLE bool undoMerge(int tableNumber);
    Q_INVOKABLE void editTable(int tableNumber, const QString& shape, int capacity);
    Q_INVOKABLE QVariantList getSeatingList() const;

    Q_INVOKABLE void generateReport(const QDateTime& date);
    Q_INVOKABLE double checkDiscount(const QString& code, double totalAmount);

    Q_INVOKABLE QVariantList loadEmployees();

    Q_INVOKABLE bool addEmployeeCSV(const QString &id,
                                    const QString &name,
                                    const QString &phone,
                                    double salary,
                                    const QString &gender,
                                    const QString &jobRole,
                                    const QString &dob = "01/01/2000",
                                    const QString &cccd = "",
                                    const QString &shiftDate = "",
                                    const QString &shiftTime = "",
                                    const QString &avatar = "",
                                    const QString &cccdFront = "",
                                    const QString &cccdBack = "");

    Q_INVOKABLE bool updateEmployeeCSV(const QString &id,
                                       const QString &name,
                                       const QString &phone,
                                       double salary,
                                       const QString &gender,
                                       const QString &jobRole,
                                       const QString &dob = "01/01/2000",
                                       const QString &cccd = "",
                                       const QString &shiftDate = "",
                                       const QString &shiftTime = "",
                                       const QString &avatar = "",
                                       const QString &cccdFront = "",
                                       const QString &cccdBack = "");

    Q_INVOKABLE QVariantList loadFinance();
    Q_INVOKABLE bool addTransactionCSV(const QString& date, const QString& type, double amount, const QString& note);
    Q_INVOKABLE bool deleteEmployeeCSV(const QString& id);
    Q_INVOKABLE QVariantList loadShifts(const QString &dateStr);

    Q_INVOKABLE bool addShift(const QString &id, const QString &name, const QString &phone, const QString &dateStr, const QString &time, int repeatMonths);
    Q_INVOKABLE bool removeShift(const QString &id, const QString &dateStr, const QString &time);

    Q_INVOKABLE QVariantMap importEmployeesNoDuplicate(const QString &filePath);
    Q_INVOKABLE bool exportEmployeesCSV(const QString &filePath);

    Q_INVOKABLE bool verifyEmployeePhone(const QString &phone);
    Q_INVOKABLE bool recordAttendanceCSV(const QString &identifier, const QString &type, const QString &timestamp);
    Q_INVOKABLE bool verifyEmployeeID(const QString &id);
    Q_INVOKABLE QVariantList loadAttendance();
};

#endif // GIANGCOFFEESYSTEM_H