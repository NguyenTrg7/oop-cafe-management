#ifndef EMPLOYEE_H
#define EMPLOYEE_H

#include "User.h"
#include <QString>
#include <QVariantMap>

class Employee : public User {
    Q_OBJECT
    Q_PROPERTY(QString phone READ getPhone WRITE setPhone NOTIFY employeeChanged)
    Q_PROPERTY(double salary READ getSalary WRITE setSalary NOTIFY employeeChanged)
    Q_PROPERTY(QString gender READ getGender WRITE setGender NOTIFY employeeChanged)
    Q_PROPERTY(QString jobRole READ getJobRole WRITE setJobRole NOTIFY employeeChanged)
    Q_PROPERTY(QString dob READ getDob WRITE setDob NOTIFY employeeChanged)
    Q_PROPERTY(QString cccd READ getCccd WRITE setCccd NOTIFY employeeChanged)
    Q_PROPERTY(QString shiftDate READ getShiftDate WRITE setShiftDate NOTIFY employeeChanged)
    Q_PROPERTY(QString shiftTime READ getShiftTime WRITE setShiftTime NOTIFY employeeChanged)
    Q_PROPERTY(QString avatar READ getAvatar WRITE setAvatar NOTIFY employeeChanged)
    Q_PROPERTY(QString cccdFront READ getCccdFront WRITE setCccdFront NOTIFY employeeChanged)
    Q_PROPERTY(QString cccdBack READ getCccdBack WRITE setCccdBack NOTIFY employeeChanged)

private:
    QString m_phone;
    double m_salary{0.0};
    QString m_gender;
    QString m_jobRole;
    QString m_dob;
    QString m_cccd;
    QString m_shiftDate;
    QString m_shiftTime;
    QString m_avatar;
    QString m_cccdFront;
    QString m_cccdBack;

public:
    explicit Employee(const QString& id = "",
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

    // Setters
    void setPhone(const QString& phone);
    void setSalary(double salary);
    void setGender(const QString& gender);
    void setJobRole(const QString& jobRole);
    void setDob(const QString& dob);
    void setCccd(const QString& cccd);
    void setShiftDate(const QString& date);
    void setShiftTime(const QString& time);
    void setAvatar(const QString& avatar);
    void setCccdFront(const QString& path);
    void setCccdBack(const QString& path);

    // Chuyển đổi dữ liệu sang QVariantMap phục vụ giao diện QML
    Q_INVOKABLE QVariantMap toVariantMap() const;

    double calculateSalary(double normalHours, double weekdayOtHours, double sundayOtHours) const;

    QString role() const override { return m_jobRole; }
    void displayInfo() const override;

signals:
    void employeeChanged();
};

#endif // EMPLOYEE_H