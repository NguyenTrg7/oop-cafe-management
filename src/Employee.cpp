#include "Employee.h"
#include <iostream>

Employee::Employee(const QString &id, const QString &name, const QString &pos, double salary)
    : User(id, name)
    , m_empID(id)
    , m_position(pos)
    , m_baseSalary(salary)
    , m_hourWork(0.0)
    , m_shifft("")
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
}