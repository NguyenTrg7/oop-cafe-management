#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <QObject>
#include <QString>
#include <QHash>
#include <QVariantList>
#include <QVariantMap>

struct UserData {
    QString password;
    QString role;
};

class Account : public QObject {
    Q_OBJECT
    // 🔑 Khai báo Property kết nối với hàm getter currentUser()
    Q_PROPERTY(QString currentUser READ currentUser NOTIFY currentUserChanged)

public:
    explicit Account(QObject *parent = nullptr);

    // 🔑 HÀM GETTER (phải có dấu ngoặc tròn () và trả về QString)
    QString currentUser() const { return m_currentUser; }

    Q_INVOKABLE bool loadFromFile(const QString& filePath);
    Q_INVOKABLE bool saveToFile(const QString& filePath = "");
    Q_INVOKABLE QString loginAndGetRole(const QString& username, const QString& password);
    Q_INVOKABLE bool registerAccount(const QString& username, const QString& password, const QString& role);
    Q_INVOKABLE QVariantList getAccountList();
    Q_INVOKABLE bool addAccount(const QString& username, const QString& password, const QString& role);
    Q_INVOKABLE bool updateAccount(const QString& username, const QString& newPassword, const QString& newRole);
    Q_INVOKABLE bool deleteAccount(const QString& username);

signals:
    void currentUserChanged();

private:
    QHash<QString, UserData> m_accounts;
    QString m_filePath;

    // 🔑 BIẾN LƯU TÊN (Thêm tiền tố m_ để KHÔNG bị trùng với hàm getter currentUser فوق)
    QString m_currentUser;
};

#endif // ACCOUNT_H