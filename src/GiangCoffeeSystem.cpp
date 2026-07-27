#include "GiangCoffeeSystem.h"

GiangCoffeeSystem* GiangCoffeeSystem::m_instance = nullptr;

GiangCoffeeSystem::GiangCoffeeSystem(QObject *parent)
    : QObject(parent)
{
    // 10 bàn với vị trí cố định
    m_tables.append(Seating(1,  4, false, "Khu A - Cửa sổ",   "Vuông"));
    m_tables.append(Seating(2,  4, false, "Khu A - Cửa sổ",   "Vuông"));
    m_tables.append(Seating(3,  4, false, "Khu A - Giữa",     "Tròn"));
    m_tables.append(Seating(4,  4, false, "Khu A - Giữa",     "Tròn"));
    m_tables.append(Seating(5,  4, false, "Khu B - Quầy bar", "Vuông"));
    m_tables.append(Seating(6,  4, false, "Khu B - Quầy bar", "Vuông"));
    m_tables.append(Seating(7,  4, false, "Khu B - Góc",      "Tròn"));
    m_tables.append(Seating(8,  4, false, "Khu C - Sân vườn", "Vuông"));
    m_tables.append(Seating(9,  4, false, "Khu C - Sân vườn", "Vuông"));
    m_tables.append(Seating(10, 4, false, "Khu C - Sân vườn", "Tròn"));
}

GiangCoffeeSystem::~GiangCoffeeSystem()
{
    // Hàm hủy hệ thống
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

    // Thông tin bàn sau khi gộp
    const int mergedNumber    = std::min(tableNum1, tableNum2);
    const int mergedCapacity  = firstIt->getCapacity() + secondIt->getCapacity();
    const bool mergedOccupied = firstIt->isTableOccupied() || secondIt->isTableOccupied();

    // Giữ vị trí + hình dạng của bàn có số nhỏ hơn
    const QString mergedPosition = (tableNum1 < tableNum2) ? firstIt->getPosition()
                                                           : secondIt->getPosition();
    const QString mergedShape    = (tableNum1 < tableNum2) ? firstIt->getShape()
                                                        : secondIt->getShape();

    // Tạo bàn mới
    Seating mergedTable(mergedNumber, mergedCapacity, mergedOccupied,
                        mergedPosition, mergedShape);

    // Ghi đè bàn thứ nhất
    *firstIt = mergedTable;

    // Xóa bàn thứ hai
    m_tables.erase(secondIt);
}

void GiangCoffeeSystem::editTable(int tableNumber, const QString& /*position*/, const QString& shape)
{
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNumber) {
            // Không cho sửa vị trí nữa
            m_tables[i].setShape(shape);
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
// HỦY GỘP BÀN (tách bàn)
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

    int currentCapacity = it->getCapacity();

    // Chỉ tách được khi sức chứa > 4
    if (currentCapacity <= 4)
        return false;

    // Số bàn cần tạo thêm (mỗi bàn 4 ghế)
    int tablesToCreate = (currentCapacity / 4) - 1;

    // Giảm bàn hiện tại về 4 ghế
    it->setCapacity(4);

    // Tạo các bàn mới
    for (int i = 0; i < tablesToCreate; ++i) {
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

        // Tạo bàn mới 4 ghế, trạng thái trống
        Seating newTable(newNumber, 4, false, it->getPosition(), it->getShape());
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
        map["position"]    = table.getPosition();
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
}