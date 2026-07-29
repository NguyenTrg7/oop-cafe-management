#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <QObject>
#include <QString>
#include <string>

class Customer;

class Account : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentUserPhone READ currentUserPhone WRITE setCurrentUserPhone NOTIFY currentUserPhoneChanged)

public:
    explicit Account(QObject *parent = nullptr);
    ~Account();

    QString currentUserPhone() const { return m_currentUserPhone; }
    void setCurrentUserPhone(const QString &phone);

    void setCustomerHandler(Customer *customer);

    Q_INVOKABLE QString authenticate(const QString &username, const QString &password);
    Q_INVOKABLE bool registerAccount(const QString &username, const QString &password, const QString &role);
    Q_INVOKABLE bool grantEmployeeRole(const QString &phoneNumber);
    Q_INVOKABLE bool removeAccount(const QString &username);
    Q_INVOKABLE void saveCustomerLoyalty();

signals:
    void currentUserPhoneChanged();

private:
    std::string m_csvFilePath;
    std::string m_customersCsvPath;
    QString m_currentUserPhone;
    Customer *m_customer;

    void initFile();
    void initCustomersFile();
    void loadCustomerLoyalty(const QString &phone);
    bool upsertCustomerLoyalty(const QString &phone, const QString &name, int points);
};

#endif // ACCOUNT_H