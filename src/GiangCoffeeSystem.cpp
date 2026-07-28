#include "GiangCoffeeSystem.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

// 1. Khởi tạo con trỏ tĩnh cho Singleton
GiangCoffeeSystem* GiangCoffeeSystem::m_instance = nullptr;

// 2. Phương thức getInstance() trả về instance duy nhất
GiangCoffeeSystem* GiangCoffeeSystem::getInstance() {
    if (m_instance == nullptr) {
        m_instance = new GiangCoffeeSystem();
    }
    return m_instance;
}

// 3. Constructor
GiangCoffeeSystem::GiangCoffeeSystem(QObject *parent) : QObject(parent) {
    m_address = "VNU-HCM University of Science";
    m_menuManager = new MenuManager(this);
    qDebug() << "GiangCoffeeSystem initialized at address:" << m_address;
}

// 4. Destructor
GiangCoffeeSystem::~GiangCoffeeSystem() {
    for (auto emp : m_employees_list) {
        delete emp;
    }
    m_employees_list.clear();

    for (auto order : m_orders) {
        delete order;
    }
    m_orders.clear();
}

// =============================================================================
// TRIỂN KHAI CÁC HÀM QUẢN LÝ NHÂN VIÊN
// =============================================================================

void GiangCoffeeSystem::addEmployee(Employee* emp) {
    if (emp) {
        m_employees_list.append(emp);
        qDebug() << "Da them nhan vien moi vao memory list.";
    }
}

void GiangCoffeeSystem::removeEmployee(const QString& empID) {
    for (int i = 0; i < m_employees_list.size(); ++i) {
        if (m_employees_list[i]->getID() == empID) { // Giả sử class Employee có getId()
            delete m_employees_list[i];
            m_employees_list.removeAt(i);
            qDebug() << "Da xoa nhan vien:" << empID;
            break;
        }
    }
}

void GiangCoffeeSystem::updateEmployeeShift(const QString& id, const QString& shift) {
    for (auto emp : m_employees_list) {
        emp->setShift(shift);
        qDebug() << "Cập nhật ca làm việc cho NV:" << id << "thành:" << shift;
        break;
    }
}

bool GiangCoffeeSystem::deleteEmployeeCSV(const QString& id) {
    QFile file("data/employees.csv");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return false;

    QStringList lines;
    QTextStream in(&file);
    while (!in.atEnd()) {
        lines.append(in.readLine());
    }
    file.close();

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) return false;
    QTextStream out(&file);
    for (const QString& line : lines) {
        QStringList fields = line.split(",");
        if (!fields.isEmpty() && fields[0].trimmed() == id) {
            continue; // Bỏ qua dòng có ID cần xóa
        }
        out << line << "\n";
    }
    file.close();
    return true;
}

bool GiangCoffeeSystem::updateEmployeeCSV(const QString& id, const QString& name, const QString& pos, double salary, const QString& shift) {
    deleteEmployeeCSV(id); // Xóa dòng cũ
    return addEmployeeCSV(id, name, pos, salary, shift); // Thêm lại dòng mới đã cập nhật
}

void GiangCoffeeSystem::calculatePayroll() {
    double totalSalary = 0.0;
    for (auto emp : m_employees_list) {
        totalSalary += emp->calculateSalary();
    }
    qDebug() << "Tong luong nhan vien trong bo nho:" << totalSalary << "VND";
}

// =============================================================================
// TRIỂN KHAI CÁC HÀM QUẢN LÝ MENU
// =============================================================================

void GiangCoffeeSystem::addItem(const Menu& item) {
    m_menuItems.append(item);
    qDebug() << "Da them Menu item vao danh sach.";
}

void GiangCoffeeSystem::removeItem(const QString& itemId) {
    // Logic xoa item khoi QList<Menu>
    qDebug() << "Da xoa item khoi menu:" << itemId;
}

Menu GiangCoffeeSystem::searchMenu(const QString& name) {
    Menu emptyMenu;
    qDebug() << "Tim kiem mon:" << name;
    return emptyMenu;
}

void GiangCoffeeSystem::printMenu() {
    qDebug() << "--- DANH SACH MENU GIANG COFFEE ---";
    for (const auto& menu : m_menuItems) {
        menu.displayMenu();
    }
}

// =============================================================================
// TRIỂN KHAI CÁC HÀM QUẢN LÝ KHO & NHÀ CUNG CẤP
// =============================================================================

void GiangCoffeeSystem::addIngredient(const Ingredient& ing) {
    m_ingredients.append(ing);
}

void GiangCoffeeSystem::addSup(const Supplier& sup) {
    m_suppliers.append(sup);
}

void GiangCoffeeSystem::createInventory() {
    qDebug() << "Kiem ke va tao phieu nhap/hoan hang trong kho.";
}

// =============================================================================
// TRIỂN KHAI CÁC HÀM VẬN HÀNH QUÁN (ĐƠN HÀNG & BÀN VỊ)
// =============================================================================

void GiangCoffeeSystem::placeOrder(Order* order) {
    if (order) {
        m_orders.append(order);
        qDebug() << "Da tao don hang moi va luu vao he thong.";
    }
}

void GiangCoffeeSystem::reserveTable(int tableNum) {
    qDebug() << "Da dat giu ban so:" << tableNum;
}

void GiangCoffeeSystem::mergeTable(int num1, int num2) {
    qDebug() << "Gop ban so" << num1 << "va ban so" << num2;
}

void GiangCoffeeSystem::generateReport(const QDateTime& date) {
    qDebug() << "Xuat bao cao doanh thu cho ngay:" << date.toString("yyyy-MM-dd hh:mm:ss");
}


double GiangCoffeeSystem::checkDiscount(const QString& code, double totalAmount) {
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
                if (totalAmount < minOrder) return -1.0; // Chưa đủ điều kiện áp mã
                double discount = totalAmount * (percent / 100.0);
                return (discount > maxDiscount) ? maxDiscount : discount;
            }
        }
    }
    file.close();
    return 0.0;
}

QVariantList GiangCoffeeSystem::loadEmployees() {
    QVariantList list;
    QFile file("data/employees.csv");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return list;

    QTextStream in(&file);
    in.readLine();

    while (!in.atEnd()) {
        QStringList fields = in.readLine().split(",");
        if (fields.size() >= 5) {
            QVariantMap emp;
            emp["id"] = fields[0];
            emp["name"] = fields[1];
            emp["position"] = fields[2];
            emp["salary"] = fields[3].toDouble();
            emp["shift"] = fields[4];
            list.append(emp);
        }
    }
    file.close();
    return list;
}

bool GiangCoffeeSystem::addEmployeeCSV(const QString& id, const QString& name, const QString& pos, double salary, const QString& shift) {
    QFile file("data/employees.csv");
    if (!file.open(QIODevice::Append | QIODevice::Text)) return false;

    QTextStream out(&file);
    out << '\n';
    out << id << "," << name << "," << pos << "," << salary << "," << shift << "\n";
    file.close();
    return true;
}

QVariantList GiangCoffeeSystem::loadFinance() {
    QVariantList list;
    QFile file("data/finance.csv");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return list;

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

bool GiangCoffeeSystem::addTransactionCSV(const QString& date, const QString& type, double amount, const QString& note) {
    QFile file("data/finance.csv");
    if (!file.open(QIODevice::Append | QIODevice::Text)) return false;

    QTextStream out(&file);
    out << date << "," << type << "," << amount << "," << note << "\n";
    file.close();
    return true;
}