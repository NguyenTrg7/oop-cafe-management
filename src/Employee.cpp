#include "Employee.h"
#include <iostream>

Employee::Employee(const QString &id, const QString &name, const QString &pos, double salary)
    : User(id, name)
    , m_empID(id)
    , m_position(pos)
    , m_baseSalary(salary)
    , m_hourWork(0.0)
    , m_shifft("")
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

double Employee::calculateSalary() const
{
    return m_baseSalary * m_hourWork;
}

void Employee::setShift(const QString &newShift)
{
    m_shifft = newShift;
}

void Employee::displayInfo() const
{
    std::cout << "ID: " << m_empID.toStdString() << " | Chuc vu: " << m_position.toStdString()
              << " | Luong co ban: " << m_baseSalary << std::endl;
void Employee::displayInfo() const {
    std::cout << "SĐT: " << m_phone.toStdString()
    << " | Tên: " << m_name.toStdString()
    << " | Ngày sinh: " << m_dob.toStdString()
    << " | CCCD: " << m_cccd.toStdString() << std::endl;
}