#ifndef EMPLOYEE_H
#define EMPLOYEE_H

#include "User.h"
#include <QString>

class Employee : public User {
    Q_OBJECT
private:
    QString m_phone;
    QString m_name;
    QString m_dob;        // Ngày tháng năm sinh (dd/MM/yyyy)
    QString m_cccd;       // Số CCCD
    QString m_shift;      // Trạng thái ca làm
    QString m_avatar;     // Đường dẫn ảnh thẻ
    QString m_cccdFront;  // Đường dẫn ảnh CCCD Mặt trước
    QString m_cccdBack;   // Đường dẫn ảnh CCCD Mặt sau

public:
    Employee(const QString& phone = "",
             const QString& name = "",
             const QString& dob = "01/01/2000",
             const QString& cccd = "",
             const QString& shift = "Chưa nhận ca",
             const QString& avatar = "",
             const QString& cccdFront = "",
             const QString& cccdBack = "");

    ~Employee();

    // Getters
    QString getPhone() const { return m_phone; }
    QString getName() const { return m_name; }
    QString getDob() const { return m_dob; }
    QString getCccd() const { return m_cccd; }
    QString getShift() const { return m_shift; }
    QString getAvatar() const { return m_avatar; }
    QString getCccdFront() const { return m_cccdFront; }
    QString getCccdBack() const { return m_cccdBack; }
    double calculateSalary() {return 0;}

    // Setters
    void setPhone(const QString& phone) { m_phone = phone; }
    void setName(const QString& name) { m_name = name; }
    void setDob(const QString& dob) { m_dob = dob; }
    void setCccd(const QString& cccd) { m_cccd = cccd; }
    void setShift(const QString& shift) { m_shift = shift; }
    void setAvatar(const QString& avatar) { m_avatar = avatar; }
    void setCccdFront(const QString& path) { m_cccdFront = path; }
    void setCccdBack(const QString& path) { m_cccdBack = path; }

    QString role() const override { return "Employee"; }
    void displayInfo() const override;
};

#endif // EMPLOYEE_H