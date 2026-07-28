#include "EmployeeModel.h"
#include <QCoreApplication>
#include <QUrl>
#include <fstream>
#include <sstream>

EmployeeModel::EmployeeModel(Account *accountHandler, QObject *parent)
    : QAbstractListModel(parent)
    , m_accountHandler(accountHandler)
{
    QString defaultPath = QCoreApplication::applicationDirPath() + "/employees.csv";
    importCSV(defaultPath);
}

EmployeeModel::~EmployeeModel()
{
    QString defaultPath = QCoreApplication::applicationDirPath() + "/employees.csv";
    exportCSV(defaultPath);
    qDeleteAll(m_employees);
    m_employees.clear();
}

int EmployeeModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_employees.count();
}

QVariant EmployeeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_employees.size())
        return QVariant();

    Employee *emp = m_employees[index.row()];
    switch (role) {
    case PhoneRole:
        return emp->getPhone();
    case NameRole:
        return emp->getName();
    case DobRole:
        return emp->getDob();
    case CccdRole:
        return emp->getCccd();
    case ShiftRole:
        return emp->getShift();
    case AvatarRole:
        return emp->getAvatar();
    case CccdFrontRole:
        return emp->getCccdFront();
    case CccdBackRole:
        return emp->getCccdBack();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> EmployeeModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[PhoneRole] = "phone";
    roles[NameRole] = "name";
    roles[DobRole] = "dob";
    roles[CccdRole] = "cccd";
    roles[ShiftRole] = "shift";
    roles[AvatarRole] = "avatar";
    roles[CccdFrontRole] = "cccdFront";
    roles[CccdBackRole] = "cccdBack";
    return roles;
}

void EmployeeModel::addEmployee(const QString &phone,
                                const QString &name,
                                const QString &dob,
                                const QString &cccd,
                                const QString &shift,
                                const QString &avatar,
                                const QString &cccdFront,
                                const QString &cccdBack)
{
    beginInsertRows(QModelIndex(), m_employees.count(), m_employees.count());
    m_employees.append(new Employee(phone, name, dob, cccd, shift, avatar, cccdFront, cccdBack));
    endInsertRows();

    // 1. Tự động tạo tài khoản đăng nhập với mật khẩu mặc định "123456" và role "staff"
    if (m_accountHandler) {
        m_accountHandler->registerAccount(phone, "123456", "staff");
    }

    // 2. Tự động lưu ngay lập tức ra CSV
    QString defaultPath = QCoreApplication::applicationDirPath() + "/employees.csv";
    exportCSV(defaultPath);
}

void EmployeeModel::updateEmployee(int index,
                                   const QString &phone,
                                   const QString &name,
                                   const QString &dob,
                                   const QString &cccd,
                                   const QString &shift,
                                   const QString &avatar,
                                   const QString &cccdFront,
                                   const QString &cccdBack)
{
    if (index < 0 || index >= m_employees.size())
        return;
    Employee *emp = m_employees[index];
    emp->setPhone(phone);
    emp->setName(name);
    emp->setDob(dob);
    emp->setCccd(cccd);
    emp->setShift(shift);
    emp->setAvatar(avatar);
    emp->setCccdFront(cccdFront);
    emp->setCccdBack(cccdBack);
    emit dataChanged(createIndex(index, 0), createIndex(index, 0));

    QString defaultPath = QCoreApplication::applicationDirPath() + "/employees.csv";
    exportCSV(defaultPath);
}

void EmployeeModel::removeEmployee(int index)
{
    if (index < 0 || index >= m_employees.size())
        return;

    QString empPhone = m_employees[index]->getPhone();

    beginRemoveRows(QModelIndex(), index, index);
    Employee *emp = m_employees.takeAt(index);
    delete emp;
    endRemoveRows();

    // 1. Tự động thu hồi tài khoản đăng nhập tương ứng
    if (m_accountHandler) {
        m_accountHandler->removeAccount(empPhone);
    }

    // 2. Tự động cập nhật file CSV
    QString defaultPath = QCoreApplication::applicationDirPath() + "/employees.csv";
    exportCSV(defaultPath);
}

bool EmployeeModel::checkInCheckOut(const QString &phone, const QString &shiftStatus)
{
    for (int i = 0; i < m_employees.size(); ++i) {
        if (m_employees[i]->getPhone() == phone) {
            m_employees[i]->setShift(shiftStatus);
            emit dataChanged(createIndex(i, 0), createIndex(i, 0));

            // Tự động lưu trạng thái ca làm mới vào file CSV
            QString defaultPath = QCoreApplication::applicationDirPath() + "/employees.csv";
            exportCSV(defaultPath);
            return true;
        }
    }
    return false;
}

void EmployeeModel::importCSV(const QString &filePath)
{
    QString localPath = QUrl(filePath).toLocalFile();
    if (localPath.isEmpty())
        localPath = filePath;

    std::ifstream file(localPath.toStdString());
    if (!file.is_open())
        return;

    beginResetModel();
    qDeleteAll(m_employees);
    m_employees.clear();

    std::string line;
    bool isFirstLine = true;

    while (std::getline(file, line)) {
        if (line.empty())
            continue;
        if (line.back() == '\r')
            line.pop_back();
        if (isFirstLine) {
            isFirstLine = false;
            continue;
        }

        std::stringstream ss(line);
        std::string phone, name, dob, cccd, shift, avatar, cccdFront, cccdBack;

        std::getline(ss, phone, ',');
        std::getline(ss, name, ',');
        std::getline(ss, dob, ',');
        std::getline(ss, cccd, ',');
        std::getline(ss, shift, ',');
        std::getline(ss, avatar, ',');
        std::getline(ss, cccdFront, ',');
        std::getline(ss, cccdBack, ',');

        if (!phone.empty()) {
            m_employees.append(new Employee(QString::fromStdString(phone),
                                            QString::fromStdString(name),
                                            QString::fromStdString(dob),
                                            QString::fromStdString(cccd),
                                            QString::fromStdString(shift),
                                            QString::fromStdString(avatar),
                                            QString::fromStdString(cccdFront),
                                            QString::fromStdString(cccdBack)));
        }
    }
    file.close();
    endResetModel();
}

void EmployeeModel::exportCSV(const QString &filePath)
{
    QString localPath = QUrl(filePath).toLocalFile();
    if (localPath.isEmpty())
        localPath = filePath;

    std::ofstream file(localPath.toStdString());
    if (!file.is_open())
        return;

    file << "Phone,Name,Dob,CCCD,Shift,Avatar,CccdFront,CccdBack\n";
    for (Employee *emp : m_employees) {
        file << emp->getPhone().toStdString() << "," << emp->getName().toStdString() << ","
             << emp->getDob().toStdString() << "," << emp->getCccd().toStdString() << ","
             << emp->getShift().toStdString() << "," << emp->getAvatar().toStdString() << ","
             << emp->getCccdFront().toStdString() << "," << emp->getCccdBack().toStdString()
             << "\n";
    }
    file.close();
}