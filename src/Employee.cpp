#include "Employee.h"
#include <iostream>

Employee::Employee(const QString& phone,
                   const QString& name,
                   const QString& dob,
                   const QString& cccd,
                   const QString& shift,
                   const QString& avatar,
                   const QString& cccdFront,
                   const QString& cccdBack)
    : User(phone, name),
    m_phone(phone),
    m_name(name),
    m_dob(dob),
    m_cccd(cccd),
    m_shift(shift),
    m_avatar(avatar),
    m_cccdFront(cccdFront),
    m_cccdBack(cccdBack)
{}

Employee::~Employee() {}

void Employee::displayInfo() const {
    std::cout << "SĐT: " << m_phone.toStdString()
    << " | Tên: " << m_name.toStdString()
    << " | Ngày sinh: " << m_dob.toStdString()
    << " | CCCD: " << m_cccd.toStdString() << std::endl;
}