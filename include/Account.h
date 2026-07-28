#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <QObject>
#include <QString>
#include <string>

class Account : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentUserPhone READ currentUserPhone WRITE setCurrentUserPhone NOTIFY currentUserPhoneChanged)

public:
    explicit Account(QObject *parent = nullptr);
    ~Account();

    QString currentUserPhone() const { return m_currentUserPhone; }
    void setCurrentUserPhone(const QString &phone) {
        if (m_currentUserPhone != phone) {
            m_currentUserPhone = phone;
            emit currentUserPhoneChanged();
        }
    }

    Q_INVOKABLE QString authenticate(const QString &username, const QString &password);
    Q_INVOKABLE bool registerAccount(const QString &username, const QString &password, const QString &role);
    Q_INVOKABLE bool grantEmployeeRole(const QString &phoneNumber);
    Q_INVOKABLE bool removeAccount(const QString &username); // Bổ sung hàm xóa tài khoản

signals:
    void currentUserPhoneChanged();

private:
    std::string m_csvFilePath;
    QString m_currentUserPhone;
    void initFile();
};

#endif // ACCOUNT_H