#ifndef USER_H
#define USER_H

#include <QObject>
#include <QString>

class User : public QObject {
    Q_OBJECT
    // SỬA Ở ĐÂY: Xóa CONSTANT, thêm NOTIFY idChanged
    Q_PROPERTY(QString id READ getId WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString role READ role CONSTANT)

public:
    explicit User(const QString& id = "", const QString& name = "", QObject *parent = nullptr);
    virtual ~User() = default;

    // Getters đồng nhất
    QString getId() const;
    QString getName() const;

    // Setters
    void setId(const QString& id);
    void setName(const QString& name);

    // Hàm thuần ảo bắt buộc lớp con phải định nghĩa
    virtual QString role() const = 0;
    virtual void displayInfo() const = 0;

signals:
    // THÊM Ở ĐÂY: Tín hiệu khi id thay đổi
    void idChanged();
    void nameChanged();

protected:
    // Protected giúp lớp con (Employee) dùng trực tiếp được m_id và m_name
    QString m_id;
    QString m_name;
};

#endif // USER_H