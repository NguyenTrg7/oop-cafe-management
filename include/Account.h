#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <QObject>
#include <QString>
#include "Customer.h"

class Account : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentUserPhone READ currentUserPhone WRITE setCurrentUserPhone NOTIFY currentUserPhoneChanged)

public:
    explicit Account(QObject *parent = nullptr);
    ~Account() override = default;

    QString currentUserPhone() const;
    void setCurrentUserPhone(const QString &phone);

    // Băm mật khẩu bằng SHA-256
    static QString hashPassword(const QString &password);

    // Xác thực tài khoản với mã SHA-256
    Q_INVOKABLE QString authenticate(const QString &username, const QString &password);

    Q_INVOKABLE void setCustomerHandler(Customer *customer);
    Q_INVOKABLE bool saveCustomerLoyalty();

signals:
    void currentUserPhoneChanged();

private:
    QString m_currentUserPhone;
    Customer *m_customerHandler{nullptr};

    static QString getAccountFilePath();
    void initFile();
};

#endif // ACCOUNT_H