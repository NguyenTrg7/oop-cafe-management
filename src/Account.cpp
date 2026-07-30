#include "Account.h"
#include "Customer.h"
#include <QCoreApplication>
#include <QFile>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>

Account::Account(QObject *parent)
    : QObject(parent)
    , m_currentUserPhone("")
    , m_customer(nullptr)
{
    m_csvFilePath = (QCoreApplication::applicationDirPath() + "/accounts.csv").toStdString();
    m_customersCsvPath = (QCoreApplication::applicationDirPath() + "/customers.csv").toStdString();
    initFile();
    initCustomersFile();
}

Account::~Account() {}

void Account::setCurrentUserPhone(const QString &phone)
{
    if (m_currentUserPhone != phone) {
        m_currentUserPhone = phone;
        emit currentUserPhoneChanged();
    }
}

void Account::setCustomerHandler(Customer *customer)
{
    m_customer = customer;
}

void Account::initFile()
{
    std::ifstream checkFile(m_csvFilePath);
    bool hasAdmin = false;

    if (checkFile.is_open()) {
        std::string line;
        while (std::getline(checkFile, line)) {
            if (line.empty()) continue;
            if (line.back() == '\r') line.pop_back();
            std::stringstream ss(line);
            std::string dbUser;
            if (std::getline(ss, dbUser, ',')) {
                if (dbUser == "admin") {
                    hasAdmin = true;
                    break;
                }
            }
        }
        checkFile.close();
    }

    if (!hasAdmin) {
        std::ofstream outFile(m_csvFilePath, std::ios::app);
        if (outFile.is_open()) {
            outFile << "admin,chuquanlatoi,manager\n";
            outFile.close();
        }
    }
}

void Account::initCustomersFile()
{
    QFile file(QString::fromStdString(m_customersCsvPath));
    if (!file.exists()) {
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            file.write("phone,name,points,vouchers\n");
            file.close();
            std::cout << ">> Da tao customers.csv\n";
        }
    }
}

QString Account::authenticate(const QString &username, const QString &password)
{
    std::string inputUser = username.toStdString();
    std::string inputPass = password.toStdString();

    std::ifstream file(m_csvFilePath);
    if (!file.is_open())
        return "FILE_ERROR";

    std::string line;
    bool userExists = false;

    while (std::getline(file, line)) {
        if (line.empty()) continue;
        if (line.back() == '\r') line.pop_back();

        std::stringstream ss(line);
        std::string dbUser, dbPass, dbRole;

        if (std::getline(ss, dbUser, ',') && std::getline(ss, dbPass, ',')
            && std::getline(ss, dbRole)) {
            if (dbUser == inputUser) {
                userExists = true;
                if (dbPass == inputPass) {
                    file.close();
                    setCurrentUserPhone(username);

                    QString role = QString::fromStdString(dbRole).trimmed().toLower();
                    if (role == "customer" || role == "khach hang")
                        loadCustomerLoyalty(username);
                    else if (m_customer)
                        m_customer->resetToGuest();

                    return QString::fromStdString(dbRole);
                }
            }
        }
    }
    file.close();
    return userExists ? QString("WRONG_PASSWORD") : QString("NOT_REGISTERED");
}

bool Account::registerAccount(const QString &username, const QString &password, const QString &role)
{
    std::string inputUser = username.toStdString();
    std::string inputPass = password.toStdString();
    std::string inputRole = role.toStdString();

    std::ifstream inFile(m_csvFilePath);
    if (inFile.is_open()) {
        std::string line;
        while (std::getline(inFile, line)) {
            if (line.empty()) continue;
            if (line.back() == '\r') line.pop_back();
            std::stringstream ss(line);
            std::string dbUser;
            if (std::getline(ss, dbUser, ',') && dbUser == inputUser) {
                inFile.close();
                return false;
            }
        }
        inFile.close();
    }

    std::ofstream outFile(m_csvFilePath, std::ios::app);
    if (!outFile.is_open())
        return false;

    outFile << inputUser << "," << inputPass << "," << inputRole << "\n";
    outFile.close();

    QString roleLower = role.trimmed().toLower();
    if (roleLower == "customer" || roleLower == "khach hang")
        upsertCustomerLoyalty(username, username, 0, QString());

    return true;
}

bool Account::grantEmployeeRole(const QString &phoneNumber)
{
    std::string targetPhone = phoneNumber.toStdString();
    std::ifstream inFile(m_csvFilePath);
    std::vector<std::string> lines;
    std::string line;
    bool found = false;

    if (inFile.is_open()) {
        while (std::getline(inFile, line)) {
            if (line.empty()) continue;
            std::string temp = line;
            if (!temp.empty() && temp.back() == '\r') temp.pop_back();

            std::stringstream ss(temp);
            std::string dbUser, dbPass, dbRole;
            if (std::getline(ss, dbUser, ',') && std::getline(ss, dbPass, ',')
                && std::getline(ss, dbRole)) {
                if (dbUser == targetPhone) {
                    lines.push_back(dbUser + "," + dbPass + ",staff");
                    found = true;
                } else {
                    lines.push_back(temp);
                }
            }
        }
        inFile.close();
    }

    if (!found) {
        std::ofstream outFile(m_csvFilePath, std::ios::app);
        if (!outFile.is_open()) return false;
        outFile << targetPhone << ",toilanhanvien,staff\n";
        outFile.close();
        return true;
    }

    std::ofstream outFile(m_csvFilePath, std::ios::trunc);
    if (!outFile.is_open()) return false;
    for (const auto &l : lines) outFile << l << "\n";
    outFile.close();
    return true;
}

bool Account::removeAccount(const QString &username)
{
    std::string targetUser = username.toStdString();
    std::ifstream inFile(m_csvFilePath);
    if (!inFile.is_open()) return false;

    std::vector<std::string> lines;
    std::string line;
    bool found = false;

    while (std::getline(inFile, line)) {
        if (line.empty()) continue;
        std::string temp = line;
        if (!temp.empty() && temp.back() == '\r') temp.pop_back();

        std::stringstream ss(temp);
        std::string dbUser;
        if (std::getline(ss, dbUser, ',')) {
            if (dbUser == targetUser) found = true;
            else lines.push_back(temp);
        }
    }
    inFile.close();
    if (!found) return false;

    std::ofstream outFile(m_csvFilePath, std::ios::trunc);
    if (!outFile.is_open()) return false;
    for (const auto &l : lines) outFile << l << "\n";
    outFile.close();
    return true;
}

void Account::loadCustomerLoyalty(const QString &phone)
{
    if (!m_customer) return;

    std::ifstream file(m_customersCsvPath);
    if (!file.is_open()) {
        m_customer->loadFrom(phone, phone, 0);
        m_customer->vouchersFromString(QString());
        upsertCustomerLoyalty(phone, phone, 0, QString());
        return;
    }

    std::string line, target = phone.toStdString();
    bool found = false;

    while (std::getline(file, line)) {
        if (line.empty()) continue;
        if (line.back() == '\r') line.pop_back();
        if (line.find("phone,name") == 0) continue;

        std::stringstream ss(line);
        std::string dbPhone, dbName, dbPoints, dbVouchers;
        if (!std::getline(ss, dbPhone, ',')) continue;
        std::getline(ss, dbName, ',');
        std::getline(ss, dbPoints, ',');
        std::getline(ss, dbVouchers); // phan con lai = vouchers

        if (dbPhone == target) {
            int pts = 0;
            try {
                if (!dbPoints.empty()) pts = std::stoi(dbPoints);
            } catch (...) {}
            m_customer->loadFrom(phone,
                                 dbName.empty() ? phone : QString::fromStdString(dbName), pts);
            m_customer->vouchersFromString(QString::fromStdString(dbVouchers));
            found = true;
            break;
        }
    }
    file.close();

    if (!found) {
        m_customer->loadFrom(phone, phone, 0);
        m_customer->vouchersFromString(QString());
        upsertCustomerLoyalty(phone, phone, 0, QString());
    }
}

void Account::saveCustomerLoyalty()
{
    if (!m_customer || m_customer->phoneNumber().isEmpty())
        return;

    upsertCustomerLoyalty(
        m_customer->phoneNumber(),
        m_customer->name(),
        m_customer->loyaltyPoints(),
        m_customer->vouchersToString());
}

bool Account::upsertCustomerLoyalty(const QString &phone, const QString &name,
                                    int points, const QString &vouchers)
{
    initCustomersFile();

    std::ifstream inFile(m_customersCsvPath);
    std::vector<std::string> lines;
    std::string line, target = phone.toStdString();
    bool found = false;

    if (inFile.is_open()) {
        while (std::getline(inFile, line)) {
            if (line.empty()) continue;
            if (line.back() == '\r') line.pop_back();

            if (line.find("phone,name") == 0) {
                lines.push_back("phone,name,points,vouchers");
                continue;
            }

            std::stringstream ss(line);
            std::string dbPhone;
            std::getline(ss, dbPhone, ',');

            if (dbPhone == target) {
                lines.push_back(phone.toStdString() + "," + name.toStdString()
                                + "," + std::to_string(points) + ","
                                + vouchers.toStdString());
                found = true;
            } else {
                lines.push_back(line);
            }
        }
        inFile.close();
    }

    if (!found) {
        if (lines.empty())
            lines.push_back("phone,name,points,vouchers");
        lines.push_back(phone.toStdString() + "," + name.toStdString()
                        + "," + std::to_string(points) + ","
                        + vouchers.toStdString());
    }

    std::ofstream outFile(m_customersCsvPath, std::ios::trunc);
    if (!outFile.is_open()) return false;
    for (const auto &l : lines) outFile << l << "\n";
    outFile.close();
    return true;
}