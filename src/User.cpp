#include "User.h"

User::User(const QString &id, const QString &name, QObject *parent)
    : QObject(parent), m_id(id), m_name(name)
{}

QString User::getId() const {
    return m_id;
}

QString User::getName() const {
    return m_name;
}

void User::setId(const QString& id) {
    if (m_id != id) {
        m_id = id;
        emit idChanged(); // Phát tín hiệu cập nhật UI (nếu có)
    }
}

void User::setName(const QString &name) {
    if (m_name != name) {
        m_name = name;
        emit nameChanged(); // Bắn tín hiệu để QML cập nhật lại giao diện
    }
}