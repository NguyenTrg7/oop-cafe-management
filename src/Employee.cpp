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

void Employee::setPhone(const QString &phone) { if (m_phone != phone) { m_phone = phone; emit employeeChanged(); } }
void Employee::setSalary(double salary) { if (m_salary != salary) { m_salary = salary; emit employeeChanged(); } }
void Employee::setGender(const QString &gender) { if (m_gender != gender) { m_gender = gender; emit employeeChanged(); } }
void Employee::setJobRole(const QString &jobRole) { if (m_jobRole != jobRole) { m_jobRole = jobRole; emit employeeChanged(); } }
void Employee::setDob(const QString &dob) { if (m_dob != dob) { m_dob = dob; emit employeeChanged(); } }
void Employee::setCccd(const QString &cccd) { if (m_cccd != cccd) { m_cccd = cccd; emit employeeChanged(); } }
void Employee::setShiftDate(const QString &date) { if (m_shiftDate != date) { m_shiftDate = date; emit employeeChanged(); } }
void Employee::setShiftTime(const QString &time) { if (m_shiftTime != time) { m_shiftTime = time; emit employeeChanged(); } }
void Employee::setAvatar(const QString &avatar) { if (m_avatar != avatar) { m_avatar = avatar; emit employeeChanged(); } }
void Employee::setCccdFront(const QString &path) { if (m_cccdFront != path) { m_cccdFront = path; emit employeeChanged(); } }
void Employee::setCccdBack(const QString &path) { if (m_cccdBack != path) { m_cccdBack = path; emit employeeChanged(); } }

QVariantMap Employee::toVariantMap() const
{
    QVariantMap map;
    map["id"] = getId();
    map["name"] = getName();
    map["phone"] = m_phone;
    map["salary"] = m_salary;
    map["gender"] = m_gender;
    map["jobRole"] = m_jobRole;
    map["dob"] = m_dob;
    map["cccd"] = m_cccd;
    map["shiftDate"] = m_shiftDate;
    map["shiftTime"] = m_shiftTime;
    map["avatar"] = m_avatar;
    map["cccdFront"] = m_cccdFront;
    map["cccdBack"] = m_cccdBack;
    return map;
}

double Employee::calculateSalary(double normalHours, double weekdayOtHours, double sundayOtHours) const
{
    return (normalHours * m_salary)
    + (weekdayOtHours * m_salary * 1.5)
        + (sundayOtHours * m_salary * 2.0);
}

void Employee::displayInfo() const
{
    std::cout << "ID: " << getId().toStdString()
    << " | SĐT: " << m_phone.toStdString()
    << " | Tên: " << getName().toStdString()
    << " | CCCD: " << m_cccd.toStdString()
    << " | Chức vụ: " << m_jobRole.toStdString()
    << std::endl;
}