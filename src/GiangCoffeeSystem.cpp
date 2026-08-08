#include "GiangCoffeeSystem.h"
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QTextStream>
#include <utility>
#include <QUrl>
#include <QSet>
#include <QDate>
#include <QTime>
#include <QCoreApplication>
#include <algorithm>

#ifndef SAVE_DIR_PATH
#define SAVE_DIR_PATH "./saves"
#endif


#ifndef DATA_DIR_PATH
#define DATA_DIR_PATH "./data"
#endif

GiangCoffeeSystem *GiangCoffeeSystem::m_instance = nullptr;

QString GiangCoffeeSystem::getSaveFilePath(const QString &fileName)
{
    QDir dir(SAVE_DIR_PATH);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    return dir.filePath(fileName);
}

void GiangCoffeeSystem::initializeSavesDirectory()
{
    QDir saveDir(SAVE_DIR_PATH);
    if (!saveDir.exists()) {
        saveDir.mkpath(".");
    }

    QDir dataDir(DATA_DIR_PATH);
    if (dataDir.exists()) {
        QFileInfoList entries = dataDir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot);
        for (const QFileInfo &fileInfo :std::as_const( entries)) {
            QString destPath = saveDir.filePath(fileInfo.fileName());
            // Nếu file trong saves không tồn tại thì mới copy qua (tránh đè dữ liệu user)
            if (!QFile::exists(destPath)) {
                QFile::copy(fileInfo.absoluteFilePath(), destPath);
                // Cấp quyền đọc/ghi cho file copy sang để tránh lỗi Read-Only
                QFile::setPermissions(destPath, QFile::ReadOwner | QFile::WriteOwner | QFile::ReadUser | QFile::WriteUser);
            }
        }
    }
}

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

    initializeSavesDirectory();
    loadSeating();

    if(m_tables.isEmpty()) {
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
}

GiangCoffeeSystem::~GiangCoffeeSystem()
{
    qDeleteAll(m_employees_list);
    m_employees_list.clear();

    qDeleteAll(m_orders);
    m_orders.clear();
}

void GiangCoffeeSystem::addEmployee(Employee *emp)
{
    if (emp) m_employees_list.append(emp);
}

void GiangCoffeeSystem::removeEmployee(const QString &empID)
{
    for (int i = 0; i < m_employees_list.size(); ++i) {
        if (m_employees_list[i]->getId() == empID) {
            delete m_employees_list[i];
            m_employees_list.removeAt(i);
            break;
        }
    }
}

void GiangCoffeeSystem::updateEmployeeInShifts(const QString &id, const QString &newName, const QString &newPhone)
{
    QString path = getSaveFilePath("Shift.csv");
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
    QString path = getSaveFilePath("Shift.csv");
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
    QString path = getSaveFilePath("Employee.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return false;

    QStringList lines;
    QTextStream in(&file);
    while (!in.atEnd()) {
        lines.append(in.readLine());
    }
    file.close();

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) return false;
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
    QString path = getSaveFilePath("Employee.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return list;

    QTextStream in(&file);
    in.readLine(); // Đọc dòng tiêu đề

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList fields = line.split(",");
        if (fields.size() >= 8) {
            QVariantMap emp;
            emp["id"] = fields[0].trimmed();

            QString val1 = fields[1].trimmed();
            QString val2 = fields[2].trimmed();

            // Tự động nhận diện và đảo lại nếu dữ liệu trong CSV cũ bị ngược thứ tự Tên <-> SĐT
            bool isVal1Phone = !val1.isEmpty() && val1.at(0).isDigit() && (val1.length() >= 9 && val1.length() <= 11);
            bool isVal2Phone = !val2.isEmpty() && val2.at(0).isDigit() && (val2.length() >= 9 && val2.length() <= 11);

            if (isVal1Phone && !isVal2Phone) {
                emp["name"] = val2;
                emp["phone"] = val1;
            } else {
                emp["name"] = val1;
                emp["phone"] = val2;
            }

            emp["salary"] = fields[3].trimmed().toDouble();
            emp["gender"] = fields[4].trimmed();
            emp["jobRole"] = fields[5].trimmed();

            if (fields.size() >= 13) {
                emp["dob"] = fields[6].trimmed();
                emp["cccd"] = fields[7].trimmed();
                emp["shiftDate"] = fields[8].trimmed();
                emp["shiftTime"] = fields[9].trimmed();
                emp["avatar"] = fields[10].trimmed();
                emp["cccdFront"] = fields[11].trimmed();
                emp["cccdBack"] = fields[12].trimmed();
            } else {
                emp["dob"] = "01/01/2000";
                emp["cccd"] = "";
                emp["shiftDate"] = fields[6].trimmed();
                emp["shiftTime"] = fields[7].trimmed();
                emp["avatar"] = "";
                emp["cccdFront"] = "";
                emp["cccdBack"] = "";
            }
            list.append(emp);
        }
    }
    file.close();
    return list;
}

bool GiangCoffeeSystem::addEmployeeCSV(const QString &id, const QString &name, const QString &phone, double salary, const QString &gender, const QString &jobRole, const QString &dob, const QString &cccd, const QString &shiftDate, const QString &shiftTime, const QString &avatar, const QString &cccdFront, const QString &cccdBack)
{
    QString path = getSaveFilePath("Employee.csv");
    QFile file(path);
    if (!file.open(QIODevice::Append | QIODevice::Text)) return false;

    QTextStream out(&file);
    out << id << "," << name << "," << phone << "," << salary << "," << gender << "," << jobRole << ","
        << dob << "," << cccd << "," << shiftDate << "," << shiftTime << ","
        << avatar << "," << cccdFront << "," << cccdBack << "\n";
    file.close();
    return true;
}

bool GiangCoffeeSystem::updateEmployeeCSV(const QString &id, const QString &name, const QString &phone, double salary, const QString &gender, const QString &jobRole, const QString &dob, const QString &cccd, const QString &shiftDate, const QString &shiftTime, const QString &avatar, const QString &cccdFront, const QString &cccdBack)
{
    QString path = getSaveFilePath("Employee.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return false;

    QStringList lines;
    QTextStream in(&file);
    while (!in.atEnd()) {
        lines.append(in.readLine());
    }
    file.close();

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) return false;
    QTextStream out(&file);

    for (const QString &line : std::as_const(lines)) {
        QStringList fields = line.split(",");
        if (!fields.isEmpty() && fields[0].trimmed() == id) {
            out << id << "," << name << "," << phone << "," << salary << ","
                << gender << "," << jobRole << "," << dob << "," << cccd << ","
                << shiftDate << "," << shiftTime << "," << avatar << ","
                << cccdFront << "," << cccdBack << "\n";
        } else {
            out << line << "\n";
        }
    }
    file.close();

    // Đồng bộ lại tên và SĐT mới sang các ca làm đã đăng ký trong Shift.csv
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

void GiangCoffeeSystem::saveSeating()
{
    QString path = getSaveFilePath("seating.csv");
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate)) return;

    QTextStream out(&file);
    out << "TableNumber,Capacity,Occupied,Shape,OriginalNumbers,OriginalCapacities,OriginalShapes,Note\n";

    for (const Seating &t : std::as_const(m_tables)) {
        QStringList nums, caps, shapes;
        for (int n : t.getOriginalNumbers()) nums << QString::number(n);
        for (int c : t.getOriginalCapacities()) caps << QString::number(c);
        for (const QString &s : t.getOriginalShapes()) shapes << s;

        QString noteSafe = t.getNote();
        noteSafe.replace(",", ";");
        noteSafe.replace("\n", " ");

        out << t.getTableNumber() << ","
            << t.getCapacity() << ","
            << (t.isTableOccupied() ? "1" : "0") << ","
            << t.getShape() << ","
            << nums.join("|") << ","
            << caps.join("|") << ","
            << shapes.join("|") << ","
            << noteSafe << "\n";
    }
    file.close();
}

void GiangCoffeeSystem::loadSeating()
{
    QString path = getSaveFilePath("seating.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return;

    m_tables.clear();
    QTextStream in(&file);
    in.readLine();

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList f = line.split(",");
        if (f.size() < 4) continue;

        int num = f[0].toInt();
        int cap = f[1].toInt();
        bool occ = (f[2] == "1");
        QString shape = f[3];

        Seating t(num, cap, occ, shape);

        if (f.size() >= 5 && !f[4].isEmpty()) {
            QList<int> nums;
            for (const QString &s : f[4].split("|", Qt::SkipEmptyParts)) nums << s.toInt();
            t.setOriginalNumbers(nums);
        }
        if (f.size() >= 6 && !f[5].isEmpty()) {
            QList<int> caps;
            for (const QString &s : f[5].split("|", Qt::SkipEmptyParts)) caps << s.toInt();
            t.setOriginalCapacities(caps);
        }
        if (f.size() >= 7 && !f[6].isEmpty()) {
            t.setOriginalShapes(f[6].split("|", Qt::SkipEmptyParts));
        }
        if (f.size() >= 8) {
            QString note = f[7].trimmed();
            note.replace(";", ",");
            t.setNote(note);
        }
        m_tables.append(t);
    }
    file.close();
}

void GiangCoffeeSystem::reserveTable(int tableNum)
{
    for (auto &table : m_tables) {
        if (table.getTableNumber() == tableNum) {
            if (table.isAvailable()) {
                table.occupyTable();
                saveSeating();
            }
            return;
        }
    }
}

void GiangCoffeeSystem::clearTable(int tableNum)
{
    for (auto &table : m_tables) {
        if (table.getTableNumber() == tableNum) {
            table.clearTable();
            saveSeating();
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

    QList<int> origNums1 = m_tables[idx1].getOriginalNumbers();
    if (origNums1.isEmpty()) origNums1 << tableNum1;
    QList<int> origCaps1 = m_tables[idx1].getOriginalCapacities();
    if (origCaps1.isEmpty()) origCaps1 << m_tables[idx1].getCapacity();
    QList<QString> origShapes1 = m_tables[idx1].getOriginalShapes();
    if (origShapes1.isEmpty()) origShapes1 << m_tables[idx1].getShape();
    QString note1 = m_tables[idx1].getNote();

    QList<int> origNums2 = m_tables[idx2].getOriginalNumbers();
    if (origNums2.isEmpty()) origNums2 << tableNum2;
    QList<int> origCaps2 = m_tables[idx2].getOriginalCapacities();
    if (origCaps2.isEmpty()) origCaps2 << m_tables[idx2].getCapacity();
    QList<QString> origShapes2 = m_tables[idx2].getOriginalShapes();
    if (origShapes2.isEmpty()) origShapes2 << m_tables[idx2].getShape();
    QString note2 = m_tables[idx2].getNote();

    const int mergedNumber = qMin(tableNum1, tableNum2);
    const int mergedCapacity = m_tables[idx1].getCapacity() + m_tables[idx2].getCapacity();
    const bool mergedOccupied = m_tables[idx1].isTableOccupied() || m_tables[idx2].isTableOccupied();
    const QString mergedShape = (tableNum1 < tableNum2) ? m_tables[idx1].getShape() : m_tables[idx2].getShape();
    QString mergedNote = note1;
    if (!note2.isEmpty()) mergedNote = note1.isEmpty() ? note2 : (note1 + " | " + note2);

    Seating mergedTable(mergedNumber, mergedCapacity, mergedOccupied, mergedShape);
    mergedTable.setOriginalNumbers(origNums1 + origNums2);
    mergedTable.setOriginalCapacities(origCaps1 + origCaps2);
    mergedTable.setOriginalShapes(origShapes1 + origShapes2);
    mergedTable.setNote(mergedNote);

    if (tableNum1 < tableNum2) {
        m_tables[idx1] = mergedTable;
        m_tables.removeAt(idx2);
    } else {
        m_tables[idx2] = mergedTable;
        m_tables.removeAt(idx1);
    }
    saveSeating();
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

    QList<int> origNums = m_tables[idx].getOriginalNumbers();
    QList<int> origCaps = m_tables[idx].getOriginalCapacities();
    QList<QString> origShapes = m_tables[idx].getOriginalShapes();

    if (origNums.size() <= 1 || origNums.size() != origCaps.size()) return false;

    m_tables.removeAt(idx);

    for (int i = 0; i < origNums.size(); ++i) {
        QString shp = (i < origShapes.size()) ? origShapes[i] : QStringLiteral("Vuông");
        m_tables.append(Seating(origNums[i], origCaps[i], false, shp));
    }

    std::sort(m_tables.begin(), m_tables.end(), [](const Seating &a, const Seating &b) {
        return a.getTableNumber() < b.getTableNumber();
    });

    saveSeating();
    return true;
}

void GiangCoffeeSystem::editTable(int tableNumber, const QString &shape, int capacity)
{
    for (auto &table : m_tables) {
        if (table.getTableNumber() == tableNumber) {
            table.setShape(shape);
            if (capacity >= 1 && capacity <= 20) table.setCapacity(capacity);
            saveSeating();
            return;
        }
    }
}

void GiangCoffeeSystem::setTableNote(int tableNumber, const QString &note)
{
    for (auto &table : m_tables) {
        if (table.getTableNumber() == tableNumber) {
            table.setNote(note);
            saveSeating();
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
        map["note"] = table.getNote();
        list.append(map);
    }
    return list;
}

void GiangCoffeeSystem::generateReport(const QDateTime &date) { Q_UNUSED(date); }

double GiangCoffeeSystem::checkDiscount(const QString &code, double totalAmount)
{
    QString path = getSaveFilePath("discounts.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return 0.0;

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
    QString path = getSaveFilePath("finance.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return list;

    QTextStream in(&file);
    in.readLine();

    while (!in.atEnd()) {
        QStringList fields = in.readLine().split(",");
        if (fields.size() >= 4) {
            QVariantMap record;
            record["date"] = fields[0].trimmed();
            record["type"] = fields[1].trimmed();
            record["amount"] = fields[2].toDouble();
            record["note"] = fields[3].trimmed();
            list.append(record);
        }
    }
    file.close();
    return list;
}

bool GiangCoffeeSystem::addTransactionCSV(const QString &date, const QString &type, double amount, const QString &note)
{
    QString path = getSaveFilePath("finance.csv");
    QFile file(path);
    if (!file.open(QIODevice::Append | QIODevice::Text)) return false;

    QTextStream out(&file);
    out << date << "," << type << "," << amount << "," << note << "\n";
    file.close();
    return true;
}

double GiangCoffeeSystem::parseShiftDurationHours(const QString &timeStr)
{
    QStringList parts = timeStr.split("-");
    if (parts.size() != 2) return 0.0;

    QTime start = QTime::fromString(parts[0].trimmed(), "HH:mm");
    QTime end = QTime::fromString(parts[1].trimmed(), "HH:mm");

    if (!start.isValid() || !end.isValid()) return 0.0;

    int secs = start.secsTo(end);
    if (secs < 0) secs += 24 * 3600;

    return secs / 3600.0;
}

double GiangCoffeeSystem::getNetWorkingHours(const QString &timeStr)
{
 return parseShiftDurationHours(timeStr);
}

bool GiangCoffeeSystem::validateShiftTimeBounds(const QString &timeStr)
{
    QStringList parts = timeStr.split("-");
    if (parts.size() != 2) return false;

    QTime start = QTime::fromString(parts[0].trimmed(), "HH:mm");
    QTime end = QTime::fromString(parts[1].trimmed(), "HH:mm");

    if (!start.isValid() || !end.isValid()) return false;

    QTime minTime(7, 0);
    QTime maxTime(22, 0);

    if (start < minTime || end > maxTime || start >= end) {
        return false;
    }
    return true;
}

QVariantList GiangCoffeeSystem::calculateMonthlyPayroll(int month, int year)
{
    QVariantList payrollList;
    QVariantList employees = loadEmployees();

    // 1. Đọc lịch phân ca
    struct ShiftEntry {
        QTime startTime;
        QTime endTime;
    };
    QMap<QString, QMap<QDate, QList<ShiftEntry>>> empShiftMap;

    QString shiftPath = getSaveFilePath("shift.csv");
    QFile shiftFile(shiftPath);
    if (shiftFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&shiftFile);
        while (!in.atEnd()) {
            QString line = in.readLine().trimmed();
            if (line.isEmpty()) continue;
            QStringList fields = line.split(",");
            if (fields.size() >= 3) {
                QString identifier = fields[0].trimmed();
                QDate date = QDate::fromString(fields[1].trimmed(), "dd/MM/yyyy");
                QString timeRange = fields[2].trimmed();

                if (date.isValid() && date.month() == month && date.year() == year) {
                    QStringList times = timeRange.split("-");
                    if (times.size() == 2) {
                        QTime start = QTime::fromString(times[0].trimmed(), "HH:mm");
                        QTime end = QTime::fromString(times[1].trimmed(), "HH:mm");
                        if (start.isValid() && end.isValid()) {
                            empShiftMap[identifier][date].append({start, end});
                        }
                    }
                }
            }
        }
        shiftFile.close();
    }

    // 2. Đọc dữ liệu điểm danh
    struct AttendanceEntry {
        QString type;
        QDateTime time;
    };
    QMap<QString, QMap<QDate, QList<AttendanceEntry>>> empAttendanceMap;

    QString attPath = getSaveFilePath("attendance.csv");
    QFile attFile(attPath);
    if (attFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&attFile);
        while (!in.atEnd()) {
            QString line = in.readLine().trimmed();
            if (line.isEmpty()) continue;

            QStringList fields = line.split(",");
            if (fields.size() >= 3) {
                QString identifier = fields[0].trimmed();
                QString type = fields[1].trimmed();
                QString timeStr = fields[2].trimmed();

                QDateTime dt = QDateTime::fromString(timeStr, "HH:mm dd/MM/yyyy");
                if (dt.isValid() && dt.date().month() == month && dt.date().year() == year) {
                    empAttendanceMap[identifier][dt.date()].append({type, dt});
                }
            }
        }
        attFile.close();
    }

    // 3. Quy chuẩn ngày công (26 ngày công chuẩn cho tháng 30 ngày)
    int daysInMonth = QDate(year, month, 1).daysInMonth();
    int standardWorkingDays = daysInMonth - 4;
    if (standardWorkingDays < 20) standardWorkingDays = 26;

    double standardHours = standardWorkingDays * 8.0;

    // 4. Tính toán lương từng nhân viên
    for (const QVariant& item : std::as_const(employees)) {
        QVariantMap empMap = item.toMap();
        QString empId = empMap["id"].toString().trimmed();
        QString empPhone = empMap["phone"].toString().trimmed();
        QString jobRole = empMap["jobRole"].toString().trimmed();
        double hourlySalaryFromCsv = empMap["salary"].toDouble();

        double totalNormalHours = 0.0;
        double totalOtHours = 0.0;

        QMap<QDate, QList<AttendanceEntry>> dailyAttendance;
        QMap<QDate, QList<ShiftEntry>> dailyShifts;

        if (empAttendanceMap.contains(empId)) dailyAttendance = empAttendanceMap[empId];
        else if (empAttendanceMap.contains(empPhone)) dailyAttendance = empAttendanceMap[empPhone];

        if (empShiftMap.contains(empId)) dailyShifts = empShiftMap[empId];
        else if (empShiftMap.contains(empPhone)) dailyShifts = empShiftMap[empPhone];

        for (auto it = dailyAttendance.begin(); it != dailyAttendance.end(); ++it) {
            QDate date = it.key();
            QList<AttendanceEntry> records = it.value();

            std::sort(records.begin(), records.end(), [](const AttendanceEntry &a, const AttendanceEntry &b) {
                return a.time < b.time;
            });

            double dailyHours = 0.0;
            QDateTime lastCheckIn;
            bool isCheckedIn = false;

            QList<ShiftEntry> scheduledShifts = dailyShifts.value(date);

            for (const auto &rec : records) {
                if (rec.type == "CHECK_IN") {
                    lastCheckIn = rec.time;
                    isCheckedIn = true;
                } else if (rec.type == "CHECK_OUT" && isCheckedIn) {
                    QDateTime effectiveIn = lastCheckIn;
                    QDateTime effectiveOut = rec.time;

                    // Khống chế theo ca làm việc tương ứng (tránh đè lỗi khi làm nhiều ca/ngày)
                    if (!scheduledShifts.isEmpty()) {
                        QTime inTime = lastCheckIn.time();
                        QTime outTime = rec.time.time();

                        for (const auto& shift :std::as_const(scheduledShifts)) {
                            // Chỉ khớp với ca trùng hoặc gần nhất với khoảng điểm danh
                            if (inTime <= shift.endTime && outTime >= shift.startTime) {
                                if (inTime < shift.startTime) effectiveIn.setTime(shift.startTime);
                                if (outTime > shift.endTime) effectiveOut.setTime(shift.endTime);
                                break;
                            }
                        }
                    }

                    qint64 secs = effectiveIn.secsTo(effectiveOut);
                    if (secs > 0) {
                        dailyHours += (secs / 3600.0);
                    }
                    isCheckedIn = false;
                }
            }

            // Mức 8 tiếng/ngày. Nghỉ 30 phút vẫn nằm trong 8 tiếng này và được hưởng đủ tiền
            double normal = qMin(8.0, qMax(0.0, dailyHours));
            double ot = qMax(0.0, dailyHours - 8.0);

            totalNormalHours += normal;
            totalOtHours += ot;
        }

        // 5. Bảng tính Lương
        double baseSalary = 0.0;
        double totalSalary = 0.0;
        double completionRatio = 0.0;

        if (jobRole == "Full-time") {
            baseSalary = 8000000.0;
            completionRatio = (standardHours > 0) ? (totalNormalHours / standardHours) : 0.0;

            double hourlyRate = baseSalary / standardHours;
            double baseEarned = baseSalary * completionRatio;
            double otEarned = totalOtHours * hourlyRate * 1.5;

            totalSalary = baseEarned + otEarned;

        } else if (jobRole == "Bảo vệ (Full-time)" || jobRole == "Bảo vệ") {
            baseSalary = 7000000.0;
            completionRatio = (standardHours > 0) ? (totalNormalHours / standardHours) : 0.0;

            double hourlyRate = baseSalary / standardHours;
            double baseEarned = baseSalary * completionRatio;
            double otEarned = totalOtHours * hourlyRate * 1.5;

            totalSalary = baseEarned + otEarned;

        } else {
            // Part-time: Lương = (Tổng giờ chuẩn x Đơn giá theo giờ) + (Giờ OT x Đơn giá x 1.5)
            baseSalary = hourlySalaryFromCsv;
            completionRatio = (standardHours > 0) ? (totalNormalHours / standardHours) : 0.0;

            double normalEarned = totalNormalHours * baseSalary;
            double otEarned = totalOtHours * baseSalary * 1.5;

            totalSalary = normalEarned + otEarned;
        }

        QVariantMap record;
        record["id"] = empId;
        record["name"] = empMap["name"].toString();
        record["jobRole"] = jobRole;
        record["baseSalary"] = baseSalary;
        record["standardHours"] = standardHours;
        record["completionRatio"] = completionRatio * 100.0;
        record["normalHours"] = totalNormalHours;
        record["otHours"] = totalOtHours;
        record["weekdayOtHours"] = totalOtHours;
        record["sundayOtHours"] = 0.0;
        record["totalSalary"] = totalSalary;

        payrollList.append(record);
    }

    return payrollList;
}

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
    QString path = getSaveFilePath("attendance.csv");
    QFile file(path);
    if (!file.open(QIODevice::Append | QIODevice::Text)) return false;

    QTextStream out(&file);
    out << identifier << "," << type << "," << timestamp << "\n";
    file.close();
    return true;
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
    QString path = getSaveFilePath("attendance.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return list;

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
        if (fields.size() >= 8) {
            QString newId = fields[0].trimmed();
            QString val1 = fields[1].trimmed();
            QString val2 = fields[2].trimmed();

            QString newName = val1;
            QString newPhone = val2;

            if (!val1.isEmpty() && val1.at(0).isDigit() && val1.length() >= 9 && val1.length() <= 11) {
                newName = val2;
                newPhone = val1;
            }

            if (existingIds.contains(newId) || existingPhones.contains(newPhone)) {
                skippedCount++;
                continue;
            }

            double salary = fields[3].toDouble();
            QString gender = fields[4].trimmed();
            QString jobRole = fields[5].trimmed();

            QString dob = "01/01/2000";
            QString cccd = "";
            QString shiftDate = "";
            QString shiftTime = "";
            QString avatar = "";
            QString cccdFront = "";
            QString cccdBack = "";

            if (fields.size() >= 13) {
                dob = fields[6].trimmed();
                cccd = fields[7].trimmed();
                shiftDate = fields[8].trimmed();
                shiftTime = fields[9].trimmed();
                avatar = fields[10].trimmed();
                cccdFront = fields[11].trimmed();
                cccdBack = fields[12].trimmed();
            } else {
                shiftDate = fields[6].trimmed();
                shiftTime = fields[7].trimmed();
            }

            addEmployeeCSV(newId, newName, newPhone, salary, gender, jobRole, dob, cccd, shiftDate, shiftTime, avatar, cccdFront, cccdBack);
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
    QString path = getSaveFilePath("Shift.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return list;

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
    if (!validateShiftTimeBounds(time)) {
        qDebug() << "Lỗi: Khung giờ phải nằm trong khoảng 07:00 đến 22:00!";
        return false;
    }

    QStringList newParts = time.split("-");
    QTime newStart = QTime::fromString(newParts[0].trimmed(), "HH:mm");
    QTime newEnd = QTime::fromString(newParts[1].trimmed(), "HH:mm");

    QVariantList employees = loadEmployees();
    QString jobRole = "Part-time";

    for (const QVariant &item :std::as_const(employees)) {
        if (item.toMap()["id"].toString() == id) {
            jobRole = item.toMap()["jobRole"].toString();
            break;
        }
    }

    double shiftGrossHours = parseShiftDurationHours(time);

    if (jobRole == "Part-time") {
        if (shiftGrossHours < 3.0 || shiftGrossHours > 5.0) {
            qDebug() << "Lỗi: Ca Part-time chỉ được đăng ký từ 3 đến 5 tiếng!";
            return false;
        }
    } else if (jobRole == "Full-time" || jobRole == "Bảo vệ (Full-time)") {
        if (time != "07:00-15:00" && time != "14:00-22:00") {
            qDebug() << "Lỗi: Nhân viên Full-time/Bảo vệ chỉ được đăng ký ca 07:00-15:00 hoặc 14:00-22:00";
            return false;
        }
    }

    double newShiftNetHours = getNetWorkingHours(time);
    QDate startDate = QDate::fromString(dateStr, "dd/MM/yyyy");
    if (!startDate.isValid()) return false;

    QDate endDate = startDate.addMonths(repeatMonths);
    QDate currentDate = startDate;

    QString path = getSaveFilePath("Shift.csv");

    while (currentDate <= endDate) {
        double dayNetHours = 0.0;
        double weekNormalHours = 0.0;
        double monthOtHours = 0.0;
        double yearOtHours = 0.0;

        QDate startOfWeek = currentDate.addDays(-(currentDate.dayOfWeek() - 1));
        QDate endOfWeek = startOfWeek.addDays(6);

        QFile fileRead(path);
        if (fileRead.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&fileRead);
            QMap<QDate, double> dailyNetMap;

            while (!in.atEnd()) {
                QString line = in.readLine().trimmed();
                if (line.isEmpty()) continue;

                QStringList fields = line.split(",");
                if (fields.size() >= 5 && fields[0] == id) {
                    QDate d = QDate::fromString(fields[3], "dd/MM/yyyy");
                    if (d.isValid()) {
                        if (d == currentDate) {
                            QStringList existParts = fields[4].split("-");
                            if (existParts.size() == 2) {
                                QTime existStart = QTime::fromString(existParts[0].trimmed(), "HH:mm");
                                QTime existEnd = QTime::fromString(existParts[1].trimmed(), "HH:mm");

                                if (existStart.isValid() && existEnd.isValid()) {
                                    if (newStart < existEnd && newEnd > existStart) {
                                        qDebug() << "Lỗi: Trùng ca làm việc!";
                                        fileRead.close();
                                        return false;
                                    }
                                }
                            }
                        }

                        double h = getNetWorkingHours(fields[4]);

                        if (d == currentDate) dayNetHours += h;
                        if (d >= startOfWeek && d <= endOfWeek) {
                            dailyNetMap[d] += h;
                        }
                        if (d.month() == currentDate.month() && d.year() == currentDate.year()) {
                            double dayH = dailyNetMap[d];
                            if (dayH > 8.0) monthOtHours += (dayH - 8.0);
                        }
                        if (d.year() == currentDate.year()) {
                            double dayH = dailyNetMap[d];
                            if (dayH > 8.0) yearOtHours += (dayH - 8.0);
                        }
                    }
                }
            }
            fileRead.close();

            for (auto it = dailyNetMap.begin(); it != dailyNetMap.end(); ++it) {
                weekNormalHours += qMin(8.0, it.value());
            }
        }

        if ((dayNetHours + newShiftNetHours) > 12.0) return false;
        if ((weekNormalHours + qMin(8.0, newShiftNetHours)) > 48.0) return false;

        double currentDayTotal = dayNetHours + newShiftNetHours;
        double newOt = (currentDayTotal > 8.0) ? (currentDayTotal - qMax(8.0, dayNetHours)) : 0.0;

        if ((monthOtHours + newOt) > 40.0) return false;
        if ((yearOtHours + newOt) > 200.0) return false;

        currentDate = currentDate.addDays(7);
    }

    QFile fileAppend(path);
    if (!fileAppend.open(QIODevice::Append | QIODevice::Text)) return false;

    QTextStream out(&fileAppend);
    currentDate = startDate;
    while (currentDate <= endDate) {
        out << id << "," << name << "," << phone << "," << currentDate.toString("dd/MM/yyyy") << "," << time << "\n";
        currentDate = currentDate.addDays(7);
    }

    fileAppend.close();
    return true;
}

bool GiangCoffeeSystem::removeShift(const QString &id, const QString &dateStr, const QString &time)
{
    QString path = getSaveFilePath("Shift.csv");
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return false;

    QStringList lines;
    QTextStream in(&file);
    while (!in.atEnd()) {
        lines.append(in.readLine());
    }
    file.close();

    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) return false;

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

    QString sourcePath = getSaveFilePath("Employee.csv");
    QFile sourceFile(sourcePath);
    if (!sourceFile.exists()) return false;

    QFile destFile(localPath);
    if (destFile.exists()) destFile.remove();

    return sourceFile.copy(localPath);
}