

#ifndef USER_H
#define USER_H

#include <QObject>
#include <QString>

class User : public QObject {
    Q_OBJECT
    // Q_PROPERTY giúp QML có thể đọc/ghi dữ liệu từ C++ (Áp dụng MVVM)
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString role READ role CONSTANT)

public:
    explicit User(const QString& id, const QString& name, QObject *parent = nullptr);
    virtual ~User() = default;

    // Getters (Tính đóng gói)
    QString id() const;
    QString name() const;

    // Setters
    void setName(const QString& name);
    QString getName();
    // Tính trừu tượng & Đa hình: Hàm thuần ảo (Pure virtual function)
    virtual QString role() const = 0;
    virtual void displayInfo() const = 0;
    QString getID() { return m_id;}

signals:
    void nameChanged(); // Signal báo cho QML biết dữ liệu đã đổi

protected: // Cho phép lớp con truy cập
    QString m_id;
    QString m_name;
};

#endif // USER_H