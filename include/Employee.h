#ifndef EMPLOYEE_H
#define EMPLOYEE_H
#include "User.h"

class Employee : public User {
    Q_OBJECT
private:
    // Thuộc tính theo UML[cite: 2]
    QString m_empID;
    QString m_position;
    double m_baseSalary;
    double m_hourWork;
    QString m_shifft;

public:
    Employee(const QString& id, const QString& name, const QString& pos, double salary);
    ~Employee();
    // Phương thức theo UML[cite: 2]
    double calculateSalary() const;
    void setShift(const QString& newShift);
    QString getID();
    QString role() const override { return "Employee"; }
    void displayInfo() const override;
};
#endif // EMPLOYEE_H