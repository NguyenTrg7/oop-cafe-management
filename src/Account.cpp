#include "Account.h"
#include <QCoreApplication>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>

Account::Account(QObject *parent)
    : QObject(parent)
    , m_currentUserPhone("")
{
    QString absolutePath = QCoreApplication::applicationDirPath() + "/accounts.csv";
    m_csvFilePath = absolutePath.toStdString();
    initFile();
}

Account::~Account() {}

void Account::initFile()
{
    std::ifstream checkFile(m_csvFilePath);
    bool hasAdmin = false;

    if (checkFile.is_open()) {
        std::string line;
        while (std::getline(checkFile, line)) {
            if (line.empty())
                continue;
            if (line.back() == '\r')
                line.pop_back();

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
            // Mặc định luôn cấp quyền manager với pass chuquanlatoi
            outFile << "admin,chuquanlatoi,manager\n";
            outFile.close();
            std::cout << ">> Da tu dong tao/bo sung tai khoan Admin: admin / chuquanlatoi\n";
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
        if (line.empty())
            continue;
        if (line.back() == '\r')
            line.pop_back();

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

    if (!userExists) {
        return "NOT_REGISTERED";
    } else {
        return "WRONG_PASSWORD";
    }
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
            if (line.empty())
                continue;
            if (line.back() == '\r')
                line.pop_back();

            std::stringstream ss(line);
            std::string dbUser;
            if (std::getline(ss, dbUser, ',')) {
                if (dbUser == inputUser) {
                    inFile.close();
                    return false;
                }
            }
        }
        inFile.close();
    }

    std::ofstream outFile(m_csvFilePath, std::ios::app);
    if (outFile.is_open()) {
        outFile << inputUser << "," << inputPass << "," << inputRole << "\n";
        outFile.close();
        return true;
    }

    return false;
}

// LOGIC CẤP QUYỀN NHÂN VIÊN MỚI
bool Account::grantEmployeeRole(const QString &phoneNumber)
{
    std::string targetPhone = phoneNumber.toStdString();
    std::ifstream inFile(m_csvFilePath);

    std::vector<std::string> lines;
    std::string line;
    bool found = false;

    if (inFile.is_open()) {
        while (std::getline(inFile, line)) {
            if (line.empty())
                continue;
            std::string tempLine = line;
            if (!tempLine.empty() && tempLine.back() == '\r')
                tempLine.pop_back();

            std::stringstream ss(tempLine);
            std::string dbUser, dbPass, dbRole;

            if (std::getline(ss, dbUser, ',') && std::getline(ss, dbPass, ',')
                && std::getline(ss, dbRole)) {
                if (dbUser == targetPhone) {
                    // Nếu đã đăng ký: Đổi role thành staff và giữ nguyên mật khẩu (dbPass)
                    lines.push_back(dbUser + "," + dbPass + ",staff");
                    found = true;
                } else {
                    lines.push_back(tempLine);
                }
            }
        }
        inFile.close();
    }

    // Nếu chưa đăng ký hoặc bị xóa: Tạo mới tài khoản với mật khẩu "toilanhanvien"
    if (!found) {
        std::ofstream outFile(m_csvFilePath, std::ios::app);
        if (outFile.is_open()) {
            outFile << targetPhone << ",toilanhanvien,staff\n";
            outFile.close();
            return true;
        }
        return false;
    }

    // Nếu có thay đổi ở tài khoản cũ, cập nhật lại tệp
    std::ofstream outFile(m_csvFilePath, std::ios::trunc);
    if (outFile.is_open()) {
        for (const auto &l : lines) {
            outFile << l << "\n";
        }
        outFile.close();
        return true;
    }

    return false;
}

bool Account::removeAccount(const QString &username)
{
    std::string targetUser = username.toStdString();
    std::ifstream inFile(m_csvFilePath);
    if (!inFile.is_open())
        return false;

    std::vector<std::string> lines;
    std::string line;
    bool found = false;

    while (std::getline(inFile, line)) {
        if (line.empty())
            continue;
        std::string tempLine = line;
        if (!tempLine.empty() && tempLine.back() == '\r')
            tempLine.pop_back();

        std::stringstream ss(tempLine);
        std::string dbUser;

        if (std::getline(ss, dbUser, ',')) {
            if (dbUser == targetUser) {
                found = true;
            } else {
                lines.push_back(tempLine);
            }
        }
    }
    inFile.close();

    if (!found)
        return false;

    std::ofstream outFile(m_csvFilePath, std::ios::trunc);
    if (outFile.is_open()) {
        for (const auto &l : lines) {
            outFile << l << "\n";
        }
        outFile.close();
        return true;
    }

    return false;
}