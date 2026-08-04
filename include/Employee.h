#ifndef EMPLOYEE_H
#define EMPLOYEE_H

#include "User.h"
#include <QString>

class Employee : public User {
    Q_OBJECT
private:
    QString m_phone;
    double m_salary;       // Lương cơ bản theo giờ (VNĐ/h)
    QString m_gender;      // Giới tính: Nam, Nữ, Khác
    QString m_jobRole;     // Phân loại: Full-time, Part-time, Bảo vệ (Full-time)
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
             const QString& gender = "Nam",
             const QString& jobRole = "Part-time",
             const QString& dob = "01/01/2000",
             const QString& cccd = "",
             const QString& shiftDate = "",
             const QString& shiftTime = "",
             const QString& avatar = "",
             const QString& cccdFront = "",
             const QString& cccdBack = "",
             QObject *parent = nullptr);

    ~Employee() override = default;

    // Getters
    QString getPhone() const { return m_phone; }
    double getSalary() const { return m_salary; }
    QString getGender() const { return m_gender; }
    QString getJobRole() const { return m_jobRole; }
    QString getDob() const { return m_dob; }
    QString getCccd() const { return m_cccd; }
    QString getShiftDate() const { return m_shiftDate; }
    QString getShiftTime() const { return m_shiftTime; }
    QString getAvatar() const { return m_avatar; }
    QString getCccdFront() const { return m_cccdFront; }
    QString getCccdBack() const { return m_cccdBack; }

    /**
     * HÀM TÍNH LƯƠNG HOÀN CHỈNH THEO LUẬT LAO ĐỘNG & QUY ĐỊNH QUÁN:
     * - Giờ làm bình thường (<= 8h/ngày, <= 48h/tuần): Lương 100% (x1.0)
     * - Giờ tăng ca ngày thường (T2 - T7): Lương 150% (x1.5)
     * - Giờ tăng ca Ngày nghỉ/Chủ Nhật: Lương 200% (x2.0)
     * Quán mở cửa 7h30-21h30 (Nhân viên 7h-22h) => Không có ca đêm.
     */
    double calculateSalary(double normalHours, double weekdayOtHours, double sundayOtHours) const {
        return (normalHours * m_salary)
        + (weekdayOtHours * m_salary * 1.5)
            + (sundayOtHours * m_salary * 2.0);
    }

    // Setters
    void setPhone(const QString& phone) { m_phone = phone; }
    void setSalary(double salary) { m_salary = salary; }
    void setGender(const QString& gender) { m_gender = gender; }
    void setJobRole(const QString& jobRole) { m_jobRole = jobRole; }
    void setDob(const QString& dob) { m_dob = dob; }
    void setCccd(const QString& cccd) { m_cccd = cccd; }
    void setShiftDate(const QString& date) { m_shiftDate = date; }
    void setShiftTime(const QString& time) { m_shiftTime = time; }
    void setAvatar(const QString& avatar) { m_avatar = avatar; }
    void setCccdFront(const QString& path) { m_cccdFront = path; }
    void setCccdBack(const QString& path) { m_cccdBack = path; }

    QString role() const override { return m_jobRole; }
    void displayInfo() const override;
};

#endif // EMPLOYEE_H