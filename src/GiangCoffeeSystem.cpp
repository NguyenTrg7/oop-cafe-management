#include "GiangCoffeeSystem.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

GiangCoffeeSystem* GiangCoffeeSystem::m_instance = nullptr;

GiangCoffeeSystem::GiangCoffeeSystem(QObject *parent)
    : QObject(parent)
{
    // 12 bàn với vị trí cố định
    m_tables.append(Seating(1,  4, false, "Vuông"));
    m_tables.append(Seating(2,  4, false, "Vuông"));
    m_tables.append(Seating(3,  4, false, "Tròn"));
    m_tables.append(Seating(4,  4, false, "Tròn"));
    m_tables.append(Seating(5,  4, false, "Vuông"));
    m_tables.append(Seating(6,  4, false, "Vuông"));
    m_tables.append(Seating(7,  4, false, "Tròn"));
    m_tables.append(Seating(8,  4, false, "Vuông"));
    m_tables.append(Seating(9,  4, false, "Vuông"));
    m_tables.append(Seating(10, 4, false, "Tròn"));
    m_tables.append(Seating(11, 4, false, "Tròn"));
    m_tables.append(Seating(12, 4, false, "Tròn"));
}

GiangCoffeeSystem::~GiangCoffeeSystem()
{
    // Hàm hủy hệ thống
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

void GiangCoffeeSystem::addEmployee(Employee *emp)
{
    // TODO: Thêm nhân viên vào danh sách quản lý
}

void GiangCoffeeSystem::removeEmployee(const QString &empID)
{
    // TODO: Xóa nhân viên theo ID
}

void GiangCoffeeSystem::updateEmployeeShift(const QString &empID, const QString &newShift)
{
    // TODO: Cập nhật ca làm việc mới cho nhân viên
}

void GiangCoffeeSystem::calculatePayroll()
{
    // TODO: Tính tổng lương phải trả cho nhân viên
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

void GiangCoffeeSystem::addItem(const Menu &menu)
{
    // TODO: Thêm món mới vào thực đơn
}

void GiangCoffeeSystem::removeItem(const QString &itemID)
{
    // TODO: Xóa món khỏi thực đơn theo ID
}

Menu GiangCoffeeSystem::searchMenu(const QString &keyword)
{
    // TODO: Tìm kiếm món ăn/nước uống
    Menu m1;
    return m1;
}

void GiangCoffeeSystem::printMenu()
{
    // TODO: In toàn bộ thực đơn ra màn hình console
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

void GiangCoffeeSystem::placeOrder(Order *order)
{
    // TODO: Xử lý đặt đơn hàng mới
}

void GiangCoffeeSystem::reserveTable(int tableNum)
{
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNum) {
            if (m_tables[i].isAvailable()) {
                m_tables[i].occupyTable();
            }
            return;   // Đã tìm thấy bàn → thoát
        }
    }
    // Không tìm thấy bàn thì không làm gì
}

// =========================================================
// HỦY ĐẶT BÀN
// =========================================================
void GiangCoffeeSystem::clearTable(int tableNum)
{
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNum) {
            m_tables[i].clearTable();   // Gọi hàm clearTable() của Seating
            return;
        }
    }
}

void GiangCoffeeSystem::mergeTable(int tableNum1, int tableNum2)
{
    if (tableNum1 == tableNum2) {
        return;
    }

    auto firstIt = std::find_if(m_tables.begin(), m_tables.end(),
                                [tableNum1](const Seating& t) {
                                    return t.getTableNumber() == tableNum1;
                                });

    auto secondIt = std::find_if(m_tables.begin(), m_tables.end(),
                                 [tableNum2](const Seating& t) {
                                     return t.getTableNumber() == tableNum2;
                                 });

    if (firstIt == m_tables.end() || secondIt == m_tables.end()) {
        return;   // Không tìm thấy một trong hai bàn
    }

    // Thu thập sức chứa gốc (nếu bàn đã từng được gộp thì lấy danh sách gốc, ngược lại lấy capacity hiện tại)
    QList<int> orig1 = firstIt->getOriginalCapacities();
    if (orig1.isEmpty())
        orig1 << firstIt->getCapacity();

    QList<int> orig2 = secondIt->getOriginalCapacities();
    if (orig2.isEmpty())
        orig2 << secondIt->getCapacity();

    QList<int> mergedOrig = orig1 + orig2;

    // Thông tin bàn sau khi gộp
    const int mergedNumber    = std::min(tableNum1, tableNum2);
    const int mergedCapacity  = firstIt->getCapacity() + secondIt->getCapacity();
    const bool mergedOccupied = firstIt->isTableOccupied() || secondIt->isTableOccupied();

    // Giữ vị trí + hình dạng của bàn có số nhỏ hơn
    const QString mergedShape    = (tableNum1 < tableNum2) ? firstIt->getShape()
                                                        : secondIt->getShape();

    // Tạo bàn mới và lưu danh sách sức chứa gốc
    Seating mergedTable(mergedNumber, mergedCapacity, mergedOccupied, mergedShape);
    mergedTable.setOriginalCapacities(mergedOrig);

    // Dùng chỉ số để tránh invalidate iterator khi xóa
    int idx1 = static_cast<int>(firstIt - m_tables.begin());
    int idx2 = static_cast<int>(secondIt - m_tables.begin());

    if (tableNum1 < tableNum2) {
        // Giữ bàn số nhỏ hơn (idx1), xóa bàn số lớn hơn (idx2)
        m_tables[idx1] = mergedTable;
        m_tables.erase(m_tables.begin() + idx2);
    } else {
        // Giữ bàn số nhỏ hơn (idx2), xóa bàn số lớn hơn (idx1)
        m_tables[idx2] = mergedTable;
        m_tables.erase(m_tables.begin() + idx1);
    }
}

void GiangCoffeeSystem::editTable(int tableNumber, const QString& shape, int capacity)
{
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNumber) {
            m_tables[i].setShape(shape);
            if (capacity >= 1 && capacity <= 20) {   // giới hạn hợp lý
                m_tables[i].setCapacity(capacity);
            }
            return;
        }
    }
}

// =========================================================
// ĐỔI SỐ BÀN
// =========================================================
bool GiangCoffeeSystem::renameTable(int oldNumber, int newNumber)
{
    if (oldNumber == newNumber)
        return false;

    // Kiểm tra số mới đã tồn tại chưa
    for (const Seating& t : m_tables) {
        if (t.getTableNumber() == newNumber)
            return false;
    }

    // Tìm bàn cần đổi số
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == oldNumber) {
            m_tables[i].setTableNumber(newNumber);
            return true;
        }
    }
    return false;
}

// =========================================================
// HỦY GỘP BÀN (tách bàn) – khôi phục đúng số ghế gốc
// =========================================================
bool GiangCoffeeSystem::undoMerge(int tableNumber)
{
    // Tìm bàn cần tách
    auto it = std::find_if(m_tables.begin(), m_tables.end(),
                           [tableNumber](const Seating& t) {
                               return t.getTableNumber() == tableNumber;
                           });

    if (it == m_tables.end())
        return false;

    QList<int> origCaps = it->getOriginalCapacities();

    // Nếu không có thông tin gốc (bàn chưa từng gộp) → không làm gì
    if (origCaps.size() <= 1) {
        return false;
    }

    // Giữ bàn hiện tại với sức chứa gốc đầu tiên, xóa danh sách gốc
    it->setCapacity(origCaps[0]);
    it->clearOriginalCapacities();
    // Giữ nguyên trạng thái occupied của bàn chính

    QString shp = it->getShape();

    // Tạo lại các bàn còn lại với đúng sức chứa gốc
    for (int i = 1; i < origCaps.size(); ++i) {
        // Tìm số bàn còn trống
        int newNumber = -1;
        for (int candidate = 1; candidate <= 30; ++candidate) {
            bool exists = false;
            for (const Seating& t : m_tables) {
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
            break; // không còn số trống thì dừng

        // Tạo bàn mới với đúng số ghế gốc, trạng thái trống
        Seating newTable(newNumber, origCaps[i], false, shp);
        m_tables.append(newTable);
    }

    return true;
}

QVariantList GiangCoffeeSystem::getSeatingList() const
{
    QVariantList list;
    for (const Seating& table : m_tables) {
        QVariantMap map;
        map["tableNumber"] = table.getTableNumber();
        map["capacity"]    = table.getCapacity();
        map["occupied"]    = table.isTableOccupied();
        map["available"]   = table.isAvailable();
        map["status"]      = table.isTableOccupied() ? "Đã có khách" : "Trống";
        map["shape"]       = table.getShape();
        list.append(map);
    }
    return list;
}

GiangCoffeeSystem* GiangCoffeeSystem::getInstance()
{
    if (!m_instance) {
        m_instance = new GiangCoffeeSystem();
    }
    return m_instance;
}

// Hàm này có thể bị khuất ở phía dưới cùng của hình, mình thêm sẵn luôn cho chắc chắn
void GiangCoffeeSystem::generateReport(const QDateTime &time)
{
    // TODO: Xuất báo cáo doanh thu theo thời gian
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