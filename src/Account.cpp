#include "Account.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

Account::Account(QObject *parent) : QObject(parent) {}

// Đọc dữ liệu từ file CSV
bool Account::loadFromFile(const QString& filePath) {
    m_filePath = filePath;
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Không thể mở file dữ liệu:" << filePath;
        return false;
    }

    m_accounts.clear();
    QTextStream in(&file);

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty() || line.startsWith("#")) continue;

        QStringList parts = line.split(",");
        if (parts.size() >= 3) {
            QString user = parts[0].trimmed();
            QString pass = parts[1].trimmed();
            QString role = parts[2].trimmed();
            m_accounts[user] = { pass, role };
        }
    }

    file.close();
    qDebug() << "Đã tải" << m_accounts.size() << "tài khoản từ file data.";
    return true;
}

// Lưu dữ liệu ngược lại file CSV
bool Account::saveToFile(const QString& filePath) {
    QString path = filePath.isEmpty() ? m_filePath : filePath;
    QFile file(path);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Không thể ghi vào file:" << path;
        return false;
    }

    QTextStream out(&file);
    for (auto it = m_accounts.constBegin(); it != m_accounts.constEnd(); ++it) {
        out << it.key() << "," << it.value().password << "," << it.value().role << "\n";
    }

    file.close();
    return true;
}

// Kiểm tra đăng nhập
QString Account::loginAndGetRole(const QString& username, const QString& password) {
    if (m_accounts.contains(username) && m_accounts[username].password == password) {
        m_currentUser = username; // 🔑 Ghi nhớ người đăng nhập hiện tại
        emit currentUserChanged();
        return m_accounts[username].role;
    }
    return ""; // Đăng nhập thất bại
}

// Đăng ký tài khoản mới và lưu tự động vào file
bool Account::registerAccount(const QString& username, const QString& password, const QString& role) {
    if (m_accounts.contains(username)) {
        return false; // Tài khoản đã tồn tại
    }

    m_accounts[username] = { password, role };
    saveToFile(); // Lưu lại vào file CSV ngay khi đăng ký thành công
    return true;
}

// 1. Lấy danh sách tài khoản truyền qua QML
QVariantList Account::getAccountList() {
    QVariantList list;
    for (auto it = m_accounts.constBegin(); it != m_accounts.constEnd(); ++it) {
        QVariantMap map;
        map["username"] = it.key();
        map["password"] = it.value().password;
        map["role"] = it.value().role;
        list.append(map);
    }
    return list;
}

// 2. Cấp tài khoản mới
bool Account::addAccount(const QString& username, const QString& password, const QString& role) {
    if (username.trimmed().isEmpty() || m_accounts.contains(username)) {
        return false; // Tài khoản rỗng hoặc đã tồn tại
    }
    m_accounts[username] = { password, role };
    saveToFile(); // Lưu ngay vào file accounts.csv
    return true;
}

// 3. Cập nhật mật khẩu / vai trò
bool Account::updateAccount(const QString& username, const QString& newPassword, const QString& newRole) {
    if (!m_accounts.contains(username)) return false;

    m_accounts[username] = { newPassword, newRole };
    saveToFile();
    return true;
}

// 4. Xóa tài khoản
bool Account::deleteAccount(const QString& username) {
    if (!m_accounts.contains(username)) return false;

    m_accounts.remove(username);
    saveToFile();
    return true;
}