#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <QObject>
#include <QString>
#include <string>

class Account : public QObject
{
    Q_OBJECT

public:
    explicit Account(QObject *parent = nullptr);
    ~Account();

    Q_INVOKABLE bool authenticate(const QString &username, const QString &password);
    Q_INVOKABLE bool registerAccount(const QString &username, const QString &password);

private:
    std::string m_csvFilePath;
    void initFile();
};

#endif // ACCOUNT_H