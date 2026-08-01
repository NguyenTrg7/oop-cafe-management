#include "Account.h"
#include <QCoreApplication>
#include <QFile>
#include <fstream>
#include <sstream>

Account::Account(QObject *parent)
    : QObject(parent)
    , m_currentUserPhone("")
{
    m_csvFilePath = (QCoreApplication::applicationDirPath() + "/accounts.csv").toStdString();
    initFile();
}

Account::~Account() {}

void Account::setCurrentUserPhone(const QString &phone)
{
    if (m_currentUserPhone != phone) {
        m_currentUserPhone = phone;
        emit currentUserPhoneChanged();
    }
}

void Account::initFile()
{
    std::ifstream checkFile(m_csvFilePath);
    bool hasAdmin = false;
    bool hasEmployee = false;

    if (checkFile.is_open()) {
        std::string line;
        while (std::getline(checkFile, line)) {
            if (line.empty()) continue;
            if (line.back() == '\r') line.pop_back();
            std::stringstream ss(line);
            std::string dbUser;
            if (std::getline(ss, dbUser, ',')) {
                if (dbUser == "admin") hasAdmin = true;
                if (dbUser == "nhanvien") hasEmployee = true;
            }
        }
        checkFile.close();
    }

    // Khởi tạo luôn 2 tài khoản mặc định
    if (!hasAdmin || !hasEmployee) {
        std::ofstream outFile(m_csvFilePath, std::ios::trunc);
        if (outFile.is_open()) {
            outFile << "admin,chuquanlatoi,manager\n";
            outFile << "nhanvien,toilanhanvien,staff\n";
            outFile.close();
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
                    return QString::fromStdString(dbRole);
                }
            }
        }
    }
    file.close();
    return userExists ? QString("WRONG_PASSWORD") : QString("NOT_REGISTERED");
}