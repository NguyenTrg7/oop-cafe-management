#include "GiangCoffeeSystem.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <utility>
// 1. Khởi tạo con trỏ tĩnh cho Singleton
GiangCoffeeSystem *GiangCoffeeSystem::m_instance = nullptr;

// 2. Phương thức getInstance() trả về instance duy nhất
GiangCoffeeSystem *GiangCoffeeSystem::getInstance()
{
    if (m_instance == nullptr) {
        m_instance = new GiangCoffeeSystem();
    }
    return m_instance;
}

// 3. Constructor
GiangCoffeeSystem::GiangCoffeeSystem(QObject *parent)
    : QObject(parent)
{
    m_address = "VNU-HCM University of Science";
    m_menuManager = new MenuManager(this);

    // 12 ban mac dinh (4 cot x 3 hang)
    m_tables.append(Seating(1,  4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(2,  4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(3,  4, false, QStringLiteral("Tròn")));
    m_tables.append(Seating(4,  4, false, QStringLiteral("Tròn")));
    m_tables.append(Seating(5,  4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(6,  4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(7,  4, false, QStringLiteral("Tròn")));
    m_tables.append(Seating(8,  4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(9,  4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(10, 4, false, QStringLiteral("Tròn")));
    m_tables.append(Seating(11, 4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(12, 4, false, QStringLiteral("Tròn")));

    qDebug() << "GiangCoffeeSystem initialized | Tables:" << m_tables.size();
}

// 4. Destructor
GiangCoffeeSystem::~GiangCoffeeSystem()
{
    for (auto *emp : qAsConst(m_employees_list)) {
        delete emp;
    }
    m_employees_list.clear();

    for (auto *order : qAsConst(m_orders)) {
        delete order;
    }
    m_orders.clear();
}

// =============================================================================
// TRIỂN KHAI CÁC HÀM QUẢN LÝ NHÂN VIÊN
// =============================================================================

void GiangCoffeeSystem::addEmployee(Employee *emp)
{
    if (emp) {
        m_employees_list.append(emp);
        qDebug() << "Da them nhan vien moi vao memory list.";
    }
}

void GiangCoffeeSystem::removeEmployee(const QString &empID)
{
    for (int i = 0; i < m_employees_list.size(); ++i) {
        if (m_employees_list[i]->getID() == empID) { // Giả sử class Employee có getId()
            delete m_employees_list[i];
            m_employees_list.removeAt(i);
            qDebug() << "Da xoa nhan vien:" << empID;
            break;
        }
    }
}

void GiangCoffeeSystem::updateEmployeeShift(const QString &id, const QString &shift)
{
    for (auto emp : m_employees_list) {
        emp->setShift(shift);
        qDebug() << "Cập nhật ca làm việc cho NV:" << id << "thành:" << shift;
        break;
    }
}

bool GiangCoffeeSystem::deleteEmployeeCSV(const QString &id)
{
    QFile file("data/employees.csv");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    QStringList lines;
    QTextStream in(&file);
    while (!in.atEnd()) {
        lines.append(in.readLine());
    }
    file.close();

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text))
        return false;
    QTextStream out(&file);
    for (const QString &line : lines) {
        QStringList fields = line.split(",");
        if (!fields.isEmpty() && fields[0].trimmed() == id) {
            continue; // Bỏ qua dòng có ID cần xóa
        }
        out << line << "\n";
    }
    file.close();
    return true;
}

QVariantList GiangCoffeeSystem::loadEmployees()
{
    QVariantList list;
    QFile file("data/employees.csv");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return list;

    QTextStream in(&file);
    in.readLine(); // Bỏ qua tiêu đề CSV

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty())
            continue;

        QStringList fields = line.split(",");
        if (fields.size() >= 5) {
            QVariantMap emp;
            emp["id"] = fields[0].trimmed();
            emp["name"] = fields[1].trimmed();
            emp["phone"] = fields[2].trimmed();
            emp["salary"] = fields[3].trimmed().toDouble();
            emp["shift"] = fields[4].trimmed();
            list.append(emp);
        }
    }
    file.close();
    return list;
}

bool GiangCoffeeSystem::addEmployeeCSV(const QString &id,
                                       const QString &name,
                                       const QString &phone,
                                       double salary,
                                       const QString &shift)
{
    QFile file("data/employees.csv");
    if (!file.open(QIODevice::Append | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << id << "," << name << "," << phone << "," << salary << "," << shift << "\n";
    file.close();
    return true;
}

bool GiangCoffeeSystem::updateEmployeeCSV(const QString &id,
                                          const QString &name,
                                          const QString &phone,
                                          double salary,
                                          const QString &shift)
{
    deleteEmployeeCSV(id);
    return addEmployeeCSV(id, name, phone, salary, shift);
}

// =============================================================================
// TRIỂN KHAI CÁC HÀM QUẢN LÝ MENU
// =============================================================================

void GiangCoffeeSystem::addItem(const Menu &item)
{
    m_menuItems.append(item);
    qDebug() << "Da them Menu item vao danh sach.";
}

void GiangCoffeeSystem::removeItem(const QString &itemId)
{
    // Logic xoa item khoi QList<Menu>
    qDebug() << "Da xoa item khoi menu:" << itemId;
}

Menu GiangCoffeeSystem::searchMenu(const QString &name)
{
    Menu emptyMenu;
    qDebug() << "Tim kiem mon:" << name;
    return emptyMenu;
}

void GiangCoffeeSystem::printMenu()
{
    qDebug() << "--- DANH SACH MENU GIANG COFFEE ---";
    for (const auto &menu : m_menuItems) {
        menu.displayMenu();
    }
}

// =============================================================================
// TRIỂN KHAI CÁC HÀM QUẢN LÝ KHO & NHÀ CUNG CẤP
// =============================================================================

void GiangCoffeeSystem::addIngredient(const Ingredient &ing)
{
    m_ingredients.append(ing);
}

void GiangCoffeeSystem::addSup(const Supplier &sup)
{
    m_suppliers.append(sup);
}

void GiangCoffeeSystem::createInventory()
{
    qDebug() << "Kiem ke va tao phieu nhap/hoan hang Tròng kho.";
}

// =============================================================================
// TRIỂN KHAI CÁC HÀM VẬN HÀNH QUÁN (ĐƠN HÀNG & BÀN VỊ)
// =============================================================================

void GiangCoffeeSystem::placeOrder(Order *order)
{
    if (order) {
        m_orders.append(order);
        qDebug() << "Da tao don hang moi va luu vao he thong.";
    }
}

void GiangCoffeeSystem::reserveTable(int tableNum)
{
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNum) {
            if (m_tables[i].isAvailable())
                m_tables[i].occupyTable();
            return;
        }
    }
}

void GiangCoffeeSystem::clearTable(int tableNum)
{
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNum) {
            m_tables[i].clearTable();
            return;
        }
    }
}

void GiangCoffeeSystem::mergeTable(int tableNum1, int tableNum2)
{
    if (tableNum1 == tableNum2)
        return;

    int idx1 = -1, idx2 = -1;
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNum1)
            idx1 = i;
        if (m_tables[i].getTableNumber() == tableNum2)
            idx2 = i;
    }
    if (idx1 < 0 || idx2 < 0)
        return;

    QList<int> orig1 = m_tables[idx1].getOriginalCapacities();
    if (orig1.isEmpty())
        orig1 << m_tables[idx1].getCapacity();

    QList<int> orig2 = m_tables[idx2].getOriginalCapacities();
    if (orig2.isEmpty())
        orig2 << m_tables[idx2].getCapacity();

    QList<int> mergedOrig = orig1 + orig2;

    const int mergedNumber = qMin(tableNum1, tableNum2);
    const int mergedCapacity = m_tables[idx1].getCapacity() + m_tables[idx2].getCapacity();
    const bool mergedOccupied = m_tables[idx1].isTableOccupied() || m_tables[idx2].isTableOccupied();
    const QString mergedShape = (tableNum1 < tableNum2)
                                    ? m_tables[idx1].getShape()
                                    : m_tables[idx2].getShape();

    Seating mergedTable(mergedNumber, mergedCapacity, mergedOccupied, mergedShape);
    mergedTable.setOriginalCapacities(mergedOrig);

    if (tableNum1 < tableNum2) {
        m_tables[idx1] = mergedTable;
        m_tables.removeAt(idx2);
    } else {
        m_tables[idx2] = mergedTable;
        m_tables.removeAt(idx1);
    }
}

bool GiangCoffeeSystem::undoMerge(int tableNumber)
{
    int idx = -1;
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNumber) {
            idx = i;
            break;
        }
    }
    if (idx < 0)
        return false;

    QList<int> origCaps = m_tables[idx].getOriginalCapacities();
    if (origCaps.size() <= 1)
        return false;

    m_tables[idx].setCapacity(origCaps[0]);
    m_tables[idx].clearOriginalCapacities();
    QString shp = m_tables[idx].getShape();

    for (int i = 1; i < origCaps.size(); ++i) {
        int newNumber = -1;
        for (int candidate = 1; candidate <= 30; ++candidate) {
            bool exists = false;
            for (const Seating &t : m_tables) {
                if (t.getTableNumber() == candidate) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                newNumber = candidate;
                break;
            }
        }
        if (newNumber == -1)
            break;

        m_tables.append(Seating(newNumber, origCaps[i], false, shp));
    }
    return true;
}

void GiangCoffeeSystem::editTable(int tableNumber, const QString &shape, int capacity)
{
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNumber) {
            m_tables[i].setShape(shape);
            if (capacity >= 1 && capacity <= 20)
                m_tables[i].setCapacity(capacity);
            return;
        }
    }
}

QVariantList GiangCoffeeSystem::getSeatingList() const
{
    QVariantList list;
    for (const Seating &table : m_tables) {
        QVariantMap map;
        map["tableNumber"] = table.getTableNumber();
        map["capacity"] = table.getCapacity();
        map["occupied"] = table.isTableOccupied();
        map["available"] = table.isAvailable();
        map["status"] = table.isTableOccupied() ? QStringLiteral("Da co khach")
                                                : QStringLiteral("Tròng");
        map["shape"] = table.getShape();
        list.append(map);
    }
    return list;
}

void GiangCoffeeSystem::generateReport(const QDateTime &date)
{
    qDebug() << "Xuat bao cao doanh thu cho ngay:" << date.toString("yyyy-MM-dd hh:mm:ss");
}

double GiangCoffeeSystem::checkDiscount(const QString &code, double totalAmount)
{
    QFile file("data/discounts.csv");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return 0.0;
    }

    QTextStream in(&file);
    in.readLine(); // Bỏ qua tiêu đề CSV

    while (!in.atEnd()) {
        QString line = in.readLine();
        QStringList fields = line.split(",");
        if (fields.size() >= 4) {
            QString csvCode = fields[0].trimmed();
            double percent = fields[1].toDouble();
            double maxDiscount = fields[2].toDouble();
            double minOrder = fields[3].toDouble();

            if (csvCode.compare(code, Qt::CaseInsensitive) == 0) {
                file.close();
                if (totalAmount < minOrder)
                    return -1.0; // Chưa đủ điều kiện áp mã
                double discount = totalAmount * (percent / 100.0);
                return (discount > maxDiscount) ? maxDiscount : discount;
            }
        }
    }
    file.close();
    return 0.0;
}




QVariantList GiangCoffeeSystem::loadFinance()
{
    QVariantList list;
    QFile file("data/finance.csv");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return list;

    QTextStream in(&file);
    in.readLine();

    while (!in.atEnd()) {
        QStringList fields = in.readLine().split(",");
        if (fields.size() >= 4) {
            QVariantMap record;
            record["date"] = fields[0];
            record["type"] = fields[1];
            record["amount"] = fields[2].toDouble();
            record["note"] = fields[3];
            list.append(record);
        }
    }
    file.close();
    return list;
}

bool GiangCoffeeSystem::addTransactionCSV(const QString &date,
                                          const QString &type,
                                          double amount,
                                          const QString &note)
{
    QFile file("data/finance.csv");
    if (!file.open(QIODevice::Append | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << date << "," << type << "," << amount << "," << note << "\n";
    file.close();
    return true;
}

void GiangCoffeeSystem::calculatePayroll()
{
    double totalSalary = 0.0;
    // Dùng qAsConst hoặc std::as_const để tránh detach
    for (auto *emp : qAsConst(m_employees_list)) {
        if (emp) {
            totalSalary += emp->calculateSalary();
        }
    }
    qDebug() << "Tong luong nhan vien Trong bo nho:" << totalSalary << "VND";
}

bool GiangCoffeeSystem::verifyEmployeePhone(const QString &phone)
{
    QString cleanPhone = phone.trimmed();
    if (cleanPhone.isEmpty()) return false;

    // Bỏ qua kiểm tra nếu là tài khoản quản trị hệ thống
    if (cleanPhone == "admin") return true;

    // Truy xuất danh sách nhân viên từ file employees.csv
    QVariantList employees = loadEmployees();
    for (const QVariant &item : employees) {
        QVariantMap emp = item.toMap();
        if (emp["phone"].toString().trimmed() == cleanPhone) {
            return true; // Tìm thấy SĐT hợp lệ trong file CSV
        }
    }
    return false; // Không tìm thấy
}

bool GiangCoffeeSystem::recordAttendanceCSV(const QString &phone, const QString &type, const QString &timestamp)
{
    QFile file("data/employees.csv");
    if (!file.open(QIODevice::Append | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << phone << "," << type << "," << timestamp << "\n";
    file.close();
    return true;
}