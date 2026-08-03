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
    void setCurrentUserPhone(const QString &phone);

    Q_INVOKABLE QString authenticate(const QString &username, const QString &password);

signals:
    void currentUserPhoneChanged();

private:
    std::string m_csvFilePath;
    QString m_currentUserPhone;

    void initFile();
};

#endif // ACCOUNT_H