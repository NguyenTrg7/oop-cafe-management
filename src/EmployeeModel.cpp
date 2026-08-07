#include "EmployeeModel.h"
#include "GiangCoffeeSystem.h"
#include <QCoreApplication>
#include <QUrl>
#include <fstream>
#include <sstream>

EmployeeModel::EmployeeModel(Account *accountHandler, QObject *parent)
    : QAbstractListModel(parent)
    , m_accountHandler(accountHandler)
{
    QString defaultPath = GiangCoffeeSystem::getSaveFilePath("Employee.csv");
    importCSV(defaultPath);
}

EmployeeModel::~EmployeeModel()
{
    qDeleteAll(m_employees);
    m_employees.clear();
}

int EmployeeModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_employees.count();
}

QVariant EmployeeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_employees.size())
        return QVariant();

    Employee *emp = m_employees[index.row()];
    switch (role) {
    case IdRole: return emp->getId();
    case NameRole: return emp->getName();
    case PhoneRole: return emp->getPhone();
    case SalaryRole: return emp->getSalary();
    case GenderRole: return emp->getGender();
    case JobRoleRole: return emp->getJobRole();
    case DobRole: return emp->getDob();
    case CccdRole: return emp->getCccd();
    case ShiftDateRole: return emp->getShiftDate();
    case ShiftTimeRole: return emp->getShiftTime();
    case AvatarRole: return emp->getAvatar();
    case CccdFrontRole: return emp->getCccdFront();
    case CccdBackRole: return emp->getCccdBack();
    default: return QVariant();
    }
}

QHash<int, QByteArray> EmployeeModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[PhoneRole] = "phone";
    roles[SalaryRole] = "salary";
    roles[GenderRole] = "gender";
    roles[JobRoleRole] = "jobRole";
    roles[DobRole] = "dob";
    roles[CccdRole] = "cccd";
    roles[ShiftDateRole] = "shiftDate";
    roles[ShiftTimeRole] = "shiftTime";
    roles[AvatarRole] = "avatar";
    roles[CccdFrontRole] = "cccdFront";
    roles[CccdBackRole] = "cccdBack";
    return roles;
}

void EmployeeModel::addEmployee(const QString &id, const QString &name, const QString &phone, double salary, const QString &gender, const QString &jobRole, const QString &dob, const QString &cccd, const QString &shiftDate, const QString &shiftTime, const QString &avatar, const QString &cccdFront, const QString &cccdBack)
{
    beginInsertRows(QModelIndex(), m_employees.count(), m_employees.count());
    m_employees.append(new Employee(id, name, phone, salary, gender, jobRole, dob, cccd, shiftDate, shiftTime, avatar, cccdFront, cccdBack));
    endInsertRows();

    QString defaultPath = GiangCoffeeSystem::getSaveFilePath("Employee.csv");
    exportCSV(defaultPath);
}

void EmployeeModel::updateEmployee(int index, const QString &id, const QString &name, const QString &phone, double salary, const QString &gender, const QString &jobRole, const QString &dob, const QString &cccd, const QString &shiftDate, const QString &shiftTime, const QString &avatar, const QString &cccdFront, const QString &cccdBack)
{
    if (index < 0 || index >= m_employees.size()) return;
    Employee *emp = m_employees[index];
    emp->setId(id);
    emp->setName(name);
    emp->setPhone(phone);
    emp->setSalary(salary);
    emp->setGender(gender);
    emp->setJobRole(jobRole);
    emp->setDob(dob);
    emp->setCccd(cccd);
    emp->setShiftDate(shiftDate);
    emp->setShiftTime(shiftTime);
    emp->setAvatar(avatar);
    emp->setCccdFront(cccdFront);
    emp->setCccdBack(cccdBack);
    emit dataChanged(createIndex(index, 0), createIndex(index, 0));

    QString defaultPath = GiangCoffeeSystem::getSaveFilePath("Employee.csv");
    exportCSV(defaultPath);
}

void EmployeeModel::removeEmployee(int index)
{
    if (index < 0 || index >= m_employees.size()) return;
    beginRemoveRows(QModelIndex(), index, index);
    Employee *emp = m_employees.takeAt(index);
    delete emp;
    endRemoveRows();

    QString defaultPath = GiangCoffeeSystem::getSaveFilePath("Employee.csv");
    exportCSV(defaultPath);
}

bool EmployeeModel::checkInCheckOut(const QString &phone, const QString &shiftDate, const QString &shiftTime)
{
    for (int i = 0; i < m_employees.size(); ++i) {
        if (m_employees[i]->getPhone() == phone) {
            m_employees[i]->setShiftDate(shiftDate);
            m_employees[i]->setShiftTime(shiftTime);
            emit dataChanged(createIndex(i, 0), createIndex(i, 0));
            QString defaultPath = GiangCoffeeSystem::getSaveFilePath("Employee.csv");
            exportCSV(defaultPath);
            return true;
        }
    }
    return false;
}

void EmployeeModel::importCSV(const QString &filePath)
{
    QString localPath = QUrl(filePath).toLocalFile();
    if (localPath.isEmpty()) localPath = filePath;

    std::ifstream file(localPath.toStdString());
    if (!file.is_open()) return;

    beginResetModel();
    qDeleteAll(m_employees);
    m_employees.clear();

    std::string line;
    bool isFirstLine = true;

    while (std::getline(file, line)) {
        if (line.empty()) continue;
        if (line.back() == '\r') line.pop_back();
        if (isFirstLine) { isFirstLine = false; continue; }

        std::stringstream ss(line);
        std::string id, name, phone, salaryStr, gender, jobRole, shiftDate, shiftTime;

        std::getline(ss, id, ',');
        std::getline(ss, name, ',');
        std::getline(ss, phone, ',');
        std::getline(ss, salaryStr, ',');
        std::getline(ss, gender, ',');
        std::getline(ss, jobRole, ',');
        std::getline(ss, shiftDate, ',');
        std::getline(ss, shiftTime, ',');

        if (!id.empty()) {
            double salary = 0.0;
            if (!salaryStr.empty()) salary = std::stod(salaryStr);
            m_employees.append(new Employee(
                QString::fromStdString(id),
                QString::fromStdString(name),
                QString::fromStdString(phone),
                salary,
                QString::fromStdString(gender),
                QString::fromStdString(jobRole),
                "", "",
                QString::fromStdString(shiftDate),
                QString::fromStdString(shiftTime)
                ));
        }
    }
    file.close();
    endResetModel();
}

void EmployeeModel::exportCSV(const QString &filePath)
{
    QString localPath = QUrl(filePath).toLocalFile();
    if (localPath.isEmpty()) localPath = filePath;

    std::ofstream file(localPath.toStdString());
    if (!file.is_open()) return;

    file << "ID,Name,Phone,Salary,Gender,JobRole,ShiftDate,ShiftTime\n";
    for (Employee *emp : m_employees) {
        file << emp->getId().toStdString() << ","
             << emp->getName().toStdString() << ","
             << emp->getPhone().toStdString() << ","
             << emp->getSalary() << ","
             << emp->getGender().toStdString() << ","
             << emp->getJobRole().toStdString() << ","
             << emp->getShiftDate().toStdString() << ","
             << emp->getShiftTime().toStdString() << "\n";
    }
    file.close();
}