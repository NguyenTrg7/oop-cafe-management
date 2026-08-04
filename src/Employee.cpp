#include "Employee.h"
#include <iostream>

Employee::Employee(const QString &id,
                   const QString &phone,
                   const QString &name,
                   double salary,
                   const QString &gender,
                   const QString &jobRole,
                   const QString &dob,
                   const QString &cccd,
                   const QString &shiftDate,
                   const QString &shiftTime,
                   const QString &avatar,
                   const QString &cccdFront,
                   const QString &cccdBack,
                   QObject *parent)
    : User(id, name, parent)
    , m_phone(phone)
    , m_salary(salary)
    , m_gender(gender)
    , m_jobRole(jobRole)
    , m_dob(dob)
    , m_cccd(cccd)
    , m_shiftDate(shiftDate)
    , m_shiftTime(shiftTime)
    , m_avatar(avatar)
    , m_cccdFront(cccdFront)
    , m_cccdBack(cccdBack)
{}

void Employee::displayInfo() const
{
    std::cout << "ID: " << m_id.toStdString() << " | SĐT: " << m_phone.toStdString()
              << " | Tên: " << m_name.toStdString() << " | Giới tính: " << m_gender.toStdString()
              << " | Lương: " << m_salary << "đ/h | Chức vụ: " << m_jobRole.toStdString()
              << " | Lịch: " << m_shiftDate.toStdString() << " " << m_shiftTime.toStdString()
              << std::endl;
}