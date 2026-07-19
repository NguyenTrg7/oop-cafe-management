#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <QObject>
#include <QString>
#include <QSqlDatabase> // Thư viện kết nối CSDL
#include <QSqlError>    // Thư viện quản lý lỗi CSDL

class Account : public QObject {
    Q_OBJECT

public:
    explicit Account(QObject *parent = nullptr);
    ~Account();

    Q_INVOKABLE bool authenticate(const QString& username, const QString& password);
    Q_INVOKABLE bool registerAccount(const QString& username, const QString& password);

private:
    // Thêm hàm phụ để khởi tạo kết nối Database lúc mới mở app
    bool initializeDatabase();

    // Biến lưu trữ kết nối database
    QSqlDatabase m_db;
};

#endif // ACCOUNT_H