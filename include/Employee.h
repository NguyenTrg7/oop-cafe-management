#ifndef EMPLOYEE_H
#define EMPLOYEE_H

#include "User.h"
#include <QString>

class Employee : public User {
    Q_OBJECT
private:
    QString m_id;
    QString m_phone;
    QString m_name;
    double m_salary;
    QString m_dob;
    QString m_cccd;
    QString m_shiftDate;
    QString m_shiftTime;
    QString m_avatar;
    QString m_cccdFront;
    QString m_cccdBack;

public:
    Employee(const QString& id = "",
             const QString& phone = "",
             const QString& name = "",
             double salary = 0.0,
             const QString& dob = "01/01/2000",
             const QString& cccd = "",
             const QString& shiftDate = "",
             const QString& shiftTime = "",
             const QString& avatar = "",
             const QString& cccdFront = "",
             const QString& cccdBack = "");

    ~Employee();

    // Getters
    QString getId() const { return m_id; }
    QString getPhone() const { return m_phone; }
    QString getName() const { return m_name; }
    double getSalary() const { return m_salary; }
    QString getDob() const { return m_dob; }
    QString getCccd() const { return m_cccd; }
    QString getShiftDate() const { return m_shiftDate; }
    QString getShiftTime() const { return m_shiftTime; }
    QString getAvatar() const { return m_avatar; }
    QString getCccdFront() const { return m_cccdFront; }
    QString getCccdBack() const { return m_cccdBack; }

    double calculateSalary() { return m_salary; }

    // Setters
    void setId(const QString& id) { m_id = id; }
    void setPhone(const QString& phone) { m_phone = phone; }
    void setName(const QString& name) { m_name = name; }
    void setSalary(double salary) { m_salary = salary; }
    void setDob(const QString& dob) { m_dob = dob; }
    void setCccd(const QString& cccd) { m_cccd = cccd; }
    void setShiftDate(const QString& date) { m_shiftDate = date; }
    void setShiftTime(const QString& time) { m_shiftTime = time; }
    void setAvatar(const QString& avatar) { m_avatar = avatar; }
    void setCccdFront(const QString& path) { m_cccdFront = path; }
    void setCccdBack(const QString& path) { m_cccdBack = path; }

    QString role() const override { return "Employee"; }
    void displayInfo() const override;
};

#endif // EMPLOYEE_H