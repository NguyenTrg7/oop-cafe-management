#include "Employee.h"
#include <iostream>

Employee::Employee(const QString &id,
                   const QString &phone,
                   const QString &name,
                   double salary,
                   const QString &dob,
                   const QString &cccd,
                   const QString &shiftDate,
                   const QString &shiftTime,
                   const QString &avatar,
                   const QString &cccdFront,
                   const QString &cccdBack)
    : User(phone, name) // Giả định User constructor nhận phone và name
    , m_id(id)
    , m_phone(phone)
    , m_name(name)
    , m_salary(salary)
    , m_dob(dob)
    , m_cccd(cccd)
    , m_shiftDate(shiftDate)
    , m_shiftTime(shiftTime)
    , m_avatar(avatar)
    , m_cccdFront(cccdFront)
    , m_cccdBack(cccdBack)
{}

Employee::~Employee() {}

void Employee::displayInfo() const
{
    std::cout << "ID: " << m_id.toStdString() << " | SĐT: " << m_phone.toStdString()
    << " | Tên: " << m_name.toStdString() << " | Lương: " << m_salary
    << " | Ngày sinh: " << m_dob.toStdString() << " | CCCD: " << m_cccd.toStdString()
    << " | Lịch: " << m_shiftDate.toStdString() << " " << m_shiftTime.toStdString()
    << std::endl;
}