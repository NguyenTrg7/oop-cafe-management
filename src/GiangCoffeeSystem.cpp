#include "GiangCoffeeSystem.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <utility>
#include <QUrl>
#include <QSet>
#include <QDate>
#include <QDir>
#include <QCoreApplication>

GiangCoffeeSystem *GiangCoffeeSystem::m_instance = nullptr;

GiangCoffeeSystem *GiangCoffeeSystem::getInstance()
{
    if (m_instance == nullptr) {
        m_instance = new GiangCoffeeSystem();
    }
    return m_instance;
}

GiangCoffeeSystem::GiangCoffeeSystem(QObject *parent)
    : QObject(parent)
{
    m_address = "VNU-HCM University of Science";
    m_menuManager = new MenuManager(this);

    m_tables.append(Seating(1, 4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(2, 4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(3, 4, false, QStringLiteral("Tròn")));
    m_tables.append(Seating(4, 4, false, QStringLiteral("Tròn")));
    m_tables.append(Seating(5, 4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(6, 4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(7, 4, false, QStringLiteral("Tròn")));
    m_tables.append(Seating(8, 4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(9, 4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(10, 4, false, QStringLiteral("Tròn")));
    m_tables.append(Seating(11, 4, false, QStringLiteral("Vuông")));
    m_tables.append(Seating(12, 4, false, QStringLiteral("Tròn")));
}

GiangCoffeeSystem::~GiangCoffeeSystem()
{
    for (auto *emp : std::as_const(m_employees_list)) {
        delete emp;
    }
    m_employees_list.clear();

    for (auto *order : std::as_const(m_orders)) {
        delete order;
    }
    m_orders.clear();
}

void GiangCoffeeSystem::addEmployee(Employee *emp)
{
    if (emp) {
        m_employees_list.append(emp);
    }
}

void GiangCoffeeSystem::removeEmployee(const QString &empID)
{
    for (int i = 0; i < m_employees_list.size(); ++i) {
        if (m_employees_list[i]->getID() == empID) {
            delete m_employees_list[i];
            m_employees_list.removeAt(i);
            break;
        }
    }
}

void GiangCoffeeSystem::updateEmployeeInShifts(const QString &id, const QString &newName, const QString &newPhone)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/Shift.csv";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;

    QStringList lines;
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        QStringList fields = line.split(",");
        if (fields.size() >= 5 && fields[0] == id) {
            fields[1] = newName;
            fields[2] = newPhone;
            line = fields.join(",");
        }
        lines.append(line);
    }
    file.close();

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) return;
    QTextStream out(&file);
    for (const QString &l : lines) {
        out << l << "\n";
    }
    file.close();
}

void GiangCoffeeSystem::deleteEmployeeShifts(const QString &id)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/Shift.csv";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;

    QStringList lines;
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        QStringList fields = line.split(",");
        if (fields.size() >= 5 && fields[0] == id) {
            continue;
        }
        lines.append(line);
    }
    file.close();

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) return;
    QTextStream out(&file);
    for (const QString &l : lines) {
        out << l << "\n";
    }
    file.close();
}

bool GiangCoffeeSystem::deleteEmployeeCSV(const QString &id)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/Employee.csv";
    QFile file(path);
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
    for (const QString &line : std::as_const(lines)) {
        QStringList fields = line.split(",");
        if (!fields.isEmpty() && fields[0].trimmed() == id) {
            continue;
        }
        out << line << "\n";
    }
    file.close();

    deleteEmployeeShifts(id);
    return true;
}

QVariantList GiangCoffeeSystem::loadEmployees()
{
    QVariantList list;
    QString path = QCoreApplication::applicationDirPath() + "/data/Employee.csv";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return list;

    QTextStream in(&file);
    in.readLine(); // Bỏ qua Header

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty())
            continue;

        QStringList fields = line.split(",");
        if (fields.size() >= 6) {
            QVariantMap emp;
            emp["id"] = fields[0].trimmed();
            emp["name"] = fields[1].trimmed();
            emp["phone"] = fields[2].trimmed();
            emp["salary"] = fields[3].trimmed().toDouble();
            emp["shiftDate"] = fields[4].trimmed();
            emp["shiftTime"] = fields[5].trimmed();
            list.append(emp);
        }
    }
    file.close();
    return list;
}

bool GiangCoffeeSystem::addEmployeeCSV(const QString &id, const QString &name, const QString &phone, double salary, const QString &shiftDate, const QString &shiftTime)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/Employee.csv";
    QFile file(path);
    if (!file.open(QIODevice::Append | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << id << "," << name << "," << phone << "," << salary << "," << shiftDate << "," << shiftTime << "\n";
    file.close();
    return true;
}

bool GiangCoffeeSystem::updateEmployeeCSV(const QString &id, const QString &name, const QString &phone, double salary, const QString &shiftDate, const QString &shiftTime)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/Employee.csv";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return false;

    QStringList lines;
    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine();
        QStringList fields = line.split(",");
        if (!fields.isEmpty() && fields[0].trimmed() == id) {
            line = QString("%1,%2,%3,%4,%5,%6").arg(id, name, phone, QString::number(salary), shiftDate, shiftTime);
        }
        lines.append(line);
    }
    file.close();

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) return false;
    QTextStream out(&file);
    for (const QString &l : lines) {
        out << l << "\n";
    }
    file.close();

    updateEmployeeInShifts(id, name, phone);
    return true;
}

void GiangCoffeeSystem::addItem(const Menu &item) { m_menuItems.append(item); }
void GiangCoffeeSystem::removeItem(const QString &itemId) { Q_UNUSED(itemId); }

Menu GiangCoffeeSystem::searchMenu(const QString &name)
{
    for (const auto &menu : std::as_const(m_menuItems)) {
        if (menu.getName() == name) return menu;
    }
    return Menu();
}

void GiangCoffeeSystem::printMenu()
{
    for (const auto &menu : std::as_const(m_menuItems)) {
        menu.displayMenu();
    }
}

void GiangCoffeeSystem::addIngredient(const Ingredient &ing) { m_ingredients.append(ing); }
void GiangCoffeeSystem::addSup(const Supplier &sup) { m_suppliers.append(sup); }
void GiangCoffeeSystem::createInventory() { }

void GiangCoffeeSystem::placeOrder(Order *order)
{
    if (order) m_orders.append(order);
}

void GiangCoffeeSystem::reserveTable(int tableNum)
{
    for (auto &table : m_tables) {
        if (table.getTableNumber() == tableNum) {
            if (table.isAvailable()) table.occupyTable();
            return;
        }
    }
}

void GiangCoffeeSystem::clearTable(int tableNum)
{
    for (auto &table : m_tables) {
        if (table.getTableNumber() == tableNum) {
            table.clearTable();
            return;
        }
    }
}

void GiangCoffeeSystem::mergeTable(int tableNum1, int tableNum2)
{
    if (tableNum1 == tableNum2) return;

    int idx1 = -1, idx2 = -1;
    for (int i = 0; i < m_tables.size(); ++i) {
        if (m_tables[i].getTableNumber() == tableNum1) idx1 = i;
        if (m_tables[i].getTableNumber() == tableNum2) idx2 = i;
    }
    if (idx1 < 0 || idx2 < 0) return;

    QList<int> orig1 = m_tables[idx1].getOriginalCapacities();
    if (orig1.isEmpty()) orig1 << m_tables[idx1].getCapacity();

    QList<int> orig2 = m_tables[idx2].getOriginalCapacities();
    if (orig2.isEmpty()) orig2 << m_tables[idx2].getCapacity();

    QList<int> mergedOrig = orig1 + orig2;

    const int mergedNumber = qMin(tableNum1, tableNum2);
    const int mergedCapacity = m_tables[idx1].getCapacity() + m_tables[idx2].getCapacity();
    const bool mergedOccupied = m_tables[idx1].isTableOccupied() || m_tables[idx2].isTableOccupied();
    const QString mergedShape = (tableNum1 < tableNum2) ? m_tables[idx1].getShape() : m_tables[idx2].getShape();

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
    if (idx < 0) return false;

    QList<int> origCaps = m_tables[idx].getOriginalCapacities();
    if (origCaps.size() <= 1) return false;

    m_tables[idx].setCapacity(origCaps[0]);
    m_tables[idx].clearOriginalCapacities();
    QString shp = m_tables[idx].getShape();

    for (int i = 1; i < origCaps.size(); ++i) {
        int newNumber = -1;
        for (int candidate = 1; candidate <= 30; ++candidate) {
            bool exists = false;
            for (const Seating &t : std::as_const(m_tables)) {
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
        if (newNumber == -1) break;
        m_tables.append(Seating(newNumber, origCaps[i], false, shp));
    }
    return true;
}

void GiangCoffeeSystem::editTable(int tableNumber, const QString &shape, int capacity)
{
    for (auto &table : m_tables) {
        if (table.getTableNumber() == tableNumber) {
            table.setShape(shape);
            if (capacity >= 1 && capacity <= 20) table.setCapacity(capacity);
            return;
        }
    }
}

QVariantList GiangCoffeeSystem::getSeatingList() const
{
    QVariantList list;
    for (const Seating &table : std::as_const(m_tables)) {
        QVariantMap map;
        map["tableNumber"] = table.getTableNumber();
        map["capacity"] = table.getCapacity();
        map["occupied"] = table.isTableOccupied();
        map["available"] = table.isAvailable();
        map["status"] = table.isTableOccupied() ? QStringLiteral("Đã có khách") : QStringLiteral("Trống");
        map["shape"] = table.getShape();
        list.append(map);
    }
    return list;
}

void GiangCoffeeSystem::generateReport(const QDateTime &date) { Q_UNUSED(date); }

double GiangCoffeeSystem::checkDiscount(const QString &code, double totalAmount)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/discounts.csv";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return 0.0;
    }

    QTextStream in(&file);
    in.readLine();

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
                if (totalAmount < minOrder) return -1.0;
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
    QString path = QCoreApplication::applicationDirPath() + "/data/finance.csv";
    QFile file(path);
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

bool GiangCoffeeSystem::addTransactionCSV(const QString &date, const QString &type, double amount, const QString &note)
{
    QString dirPath = QCoreApplication::applicationDirPath() + "/data";
    QDir().mkpath(dirPath);

    QString path = dirPath + "/finance.csv";
    bool fileExists = QFile::exists(path);

    QFile file(path);
    if (!file.open(QIODevice::Append | QIODevice::Text))
        return false;

    QTextStream out(&file);
    if (!fileExists) {
        out << "Date,Type,Amount,Note\n";
    }

    out << date << "," << type << "," << QString::number(amount, 'f', 0) << "," << note << "\n";
    file.close();
    return true;
}

void GiangCoffeeSystem::calculatePayroll() { }

bool GiangCoffeeSystem::verifyEmployeePhone(const QString &phone)
{
    QString cleanPhone = phone.trimmed();
    if (cleanPhone.isEmpty()) return false;
    if (cleanPhone == "admin") return true;

    QVariantList employees = loadEmployees();
    for (const QVariant &item : std::as_const(employees)) {
        QVariantMap emp = item.toMap();
        if (emp["phone"].toString().trimmed() == cleanPhone) {
            return true;
        }
    }
    return false;
}

bool GiangCoffeeSystem::recordAttendanceCSV(const QString &identifier, const QString &type, const QString &timestamp)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/attendance.csv";
    QFile file(path);
    if (!file.open(QIODevice::Append | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << identifier << "," << type << "," << timestamp << "\n";
    file.close();
    return true;
}

bool GiangCoffeeSystem::recordOrderRevenue(double totalAmount, const QString &orderInfo)
{
    QString today = QDate::currentDate().toString("dd/MM/yyyy");
    return addTransactionCSV(today, "Thu", totalAmount, QString("Doanh thu đơn hàng: %1").arg(orderInfo));
}

bool GiangCoffeeSystem::verifyEmployeeID(const QString &id)
{
    QString cleanId = id.trimmed();
    if (cleanId.isEmpty()) return false;

    QVariantList employees = loadEmployees();
    for (const QVariant &item : std::as_const(employees)) {
        QVariantMap emp = item.toMap();
        if (emp["id"].toString().trimmed() == cleanId) {
            return true;
        }
    }
    return false;
}

QVariantList GiangCoffeeSystem::loadAttendance()
{
    QVariantList list;
    QString path = QCoreApplication::applicationDirPath() + "/data/attendance.csv";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return list;

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList fields = line.split(",");
        if (fields.size() >= 3) {
            QVariantMap record;
            record["identifier"] = fields[0].trimmed();
            record["type"] = fields[1].trimmed();
            record["timestamp"] = fields[2].trimmed();
            list.append(record);
        }
    }
    file.close();
    return list;
}

QVariantMap GiangCoffeeSystem::importEmployeesNoDuplicate(const QString &filePath)
{
    int addedCount = 0;
    int skippedCount = 0;

    QVariantList currentList = loadEmployees();
    QSet<QString> existingIds;
    QSet<QString> existingPhones;

    for (const QVariant &item : std::as_const(currentList)) {
        QVariantMap emp = item.toMap();
        existingIds.insert(emp["id"].toString().trimmed());
        existingPhones.insert(emp["phone"].toString().trimmed());
    }

    QString localPath = QUrl(filePath).toLocalFile();
    QFile file(localPath.isEmpty() ? filePath : localPath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return QVariantMap{{"success", false}, {"message", "Không thể mở file CSV."}};
    }

    QTextStream in(&file);
    in.readLine();

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList fields = line.split(",");
        if (fields.size() >= 6) {
            QString newId = fields[0].trimmed();
            QString newPhone = fields[2].trimmed();

            if (existingIds.contains(newId) || existingPhones.contains(newPhone)) {
                skippedCount++;
                continue;
            }

            addEmployeeCSV(newId, fields[1].trimmed(), newPhone, fields[3].toDouble(), fields[4].trimmed(), fields[5].trimmed());
            existingIds.insert(newId);
            existingPhones.insert(newPhone);
            addedCount++;
        }
    }
    file.close();

    return QVariantMap{
        {"success", true},
        {"message", QString("Đã thêm %1 nhân viên. Bỏ qua %2 nhân viên bị trùng.").arg(addedCount).arg(skippedCount)}
    };
}

QVariantList GiangCoffeeSystem::loadShifts(const QString &dateStr)
{
    QVariantList list;
    QString path = QCoreApplication::applicationDirPath() + "/data/Shift.csv";
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return list;

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList fields = line.split(",");
        if (fields.size() >= 5 && fields[3] == dateStr) {
            QVariantMap shift;
            shift["id"] = fields[0];
            shift["name"] = fields[1];
            shift["phone"] = fields[2];
            shift["shiftDate"] = fields[3];
            shift["shiftTime"] = fields[4];
            list.append(shift);
        }
    }
    file.close();
    return list;
}

bool GiangCoffeeSystem::addShift(const QString &id, const QString &name, const QString &phone, const QString &dateStr, const QString &time, int repeatMonths)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/Shift.csv";
    QFile file(path);
    if (!file.open(QIODevice::Append | QIODevice::Text))
        return false;

    QTextStream out(&file);
    QDate startDate = QDate::fromString(dateStr, "dd/MM/yyyy");
    if (!startDate.isValid()) return false;

    QDate endDate = startDate.addMonths(repeatMonths);
    QDate currentDate = startDate;

    while (currentDate <= endDate) {
        out << id << "," << name << "," << phone << "," << currentDate.toString("dd/MM/yyyy") << "," << time << "\n";
        currentDate = currentDate.addDays(1);
    }

    file.close();
    return true;
}

bool GiangCoffeeSystem::removeShift(const QString &id, const QString &dateStr, const QString &time)
{
    QString path = QCoreApplication::applicationDirPath() + "/data/Shift.csv";
    QFile file(path);
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
    for (const QString &line : std::as_const(lines)) {
        QStringList fields = line.split(",");
        if (fields.size() >= 5 && fields[0] == id && fields[3] == dateStr && fields[4] == time) {
            continue;
        }
        out << line << "\n";
    }
    file.close();
    return true;
}

bool GiangCoffeeSystem::exportEmployeesCSV(const QString &filePath)
{
    QString localPath = QUrl(filePath).toLocalFile();
    if (localPath.isEmpty()) localPath = filePath;

    QString sourcePath = QCoreApplication::applicationDirPath() + "/data/Employee.csv";
    QFile sourceFile(sourcePath);
    if (!sourceFile.exists()) return false;

    QFile destFile(localPath);
    if (destFile.exists()) {
        destFile.remove();
    }

    return sourceFile.copy(localPath);
}