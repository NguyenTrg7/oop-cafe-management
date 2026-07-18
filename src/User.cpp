#include "User.h"
#include <QDebug>

User::User(const QString& id, const QString& name, QObject *parent)
    : QObject(parent), m_id(id), m_name(name) {}

QString User::id() const { return m_id; }
QString User::name() const { return m_name; }

void User::setName(const QString& name) {
    if (m_name != name) {
        m_name = name;
        emit nameChanged(); // Cập nhật View (QML)
    }
}