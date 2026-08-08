#ifndef USER_H
#define USER_H

#include <QObject>
#include <QString>

class User : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString id READ getId WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString role READ role CONSTANT)

public:
    explicit User(const QString& id = "", const QString& name = "", QObject *parent = nullptr);
    virtual ~User() = default;

    QString getId() const;
    QString getName() const;

    void setId(const QString& id);
    void setName(const QString& name);

    virtual QString role() const = 0;
    virtual void displayInfo() const = 0;

signals:
    void idChanged();
    void nameChanged();

protected:
    QString m_id;
    QString m_name;
};

#endif // USER_H