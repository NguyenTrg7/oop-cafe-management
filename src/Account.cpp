#include "Account.h"
#include "GiangCoffeeSystem.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QCryptographicHash>
#include <fstream>
#include <sstream>

Account::Account(QObject *parent)
    : QObject(parent)
    , m_currentUserPhone("")
{
    initFile();
}

QString Account::getAccountFilePath()
{
    return GiangCoffeeSystem::getSaveFilePath("accounts.csv");
}

QString Account::currentUserPhone() const
{
    return m_currentUserPhone;
}

void Account::setCurrentUserPhone(const QString &phone)
{
    if (m_currentUserPhone != phone) {
        m_currentUserPhone = phone;
        emit currentUserPhoneChanged();
    }
}

QString Account::hashPassword(const QString &password)
{
    QByteArray hashed = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256);
    return QString::fromLatin1(hashed.toHex());
}

void Account::initFile()
{
    QString path = getAccountFilePath();
    QFile checkFile(path);
    bool hasAdmin = false;
    bool hasEmployee = false;

    if (checkFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&checkFile);
        while (!in.atEnd()) {
            QString line = in.readLine().trimmed();
            if (line.isEmpty()) continue;
            QStringList fields = line.split(",");
            if (!fields.isEmpty()) {
                if (fields[0] == "admin") hasAdmin = true;
                if (fields[0] == "nhanvien") hasEmployee = true;
            }
        }
        checkFile.close();
    }

    // Khởi tạo tài khoản mặc định được băm mật khẩu SHA-256
    if (!hasAdmin || !hasEmployee) {
        if (checkFile.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
            QTextStream out(&checkFile);
            if (!hasAdmin) {
                // admin / chuquanlatoi (SHA-256)
                out << "admin," << hashPassword("chuquanlatoi") << ",manager\n";
            }
            if (!hasEmployee) {
                // nhanvien / toilanhanvien (SHA-256)
                out << "nhanvien," << hashPassword("toilanhanvien") << ",staff\n";
            }
            checkFile.close();
        }
    }
}

QString Account::authenticate(const QString &username, const QString &password)
{
    QString path = getAccountFilePath();
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return "FILE_ERROR";

    QString inputUser = username.trimmed();
    QString inputHash = hashPassword(password);
    bool userExists = false;

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList fields = line.split(",");
        if (fields.size() >= 3) {
            QString dbUser = fields[0].trimmed();
            QString dbPass = fields[1].trimmed();
            QString dbRole = fields[2].trimmed();

            if (dbUser == inputUser) {
                userExists = true;
                // So sánh chuỗi SHA-256
                if (dbPass == inputHash || dbPass == password) {
                    file.close();
                    setCurrentUserPhone(username);
                    return dbRole;
                }
            }
        }
    }
    file.close();
    return userExists ? QString("WRONG_PASSWORD") : QString("NOT_REGISTERED");
}

void Account::setCustomerHandler(Customer *customer)
{
    m_customerHandler = customer;
}

bool Account::saveCustomerLoyalty()
{
    if (m_customerHandler)
        return m_customerHandler->save();
    return false;
}