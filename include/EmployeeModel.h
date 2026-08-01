#ifndef EMPLOYEEMODEL_H
#define EMPLOYEEMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "Employee.h"
#include "Account.h"

class EmployeeModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum EmployeeRoles {
        IdRole = Qt::UserRole + 1,
        PhoneRole,
        NameRole,
        SalaryRole,
        DobRole,
        CccdRole,
        ShiftDateRole,
        ShiftTimeRole,
        AvatarRole,
        CccdFrontRole,
        CccdBackRole
    };

    explicit EmployeeModel(Account *accountHandler = nullptr, QObject *parent = nullptr);
    ~EmployeeModel();

    void setAccountHandler(Account *accountHandler) { m_accountHandler = accountHandler; }

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addEmployee(const QString& id, const QString& phone, const QString& name, double salary, const QString& dob, const QString& cccd, const QString& shiftDate, const QString& shiftTime, const QString& avatar, const QString& cccdFront, const QString& cccdBack);
    Q_INVOKABLE void updateEmployee(int index, const QString& id, const QString& phone, const QString& name, double salary, const QString& dob, const QString& cccd, const QString& shiftDate, const QString& shiftTime, const QString& avatar, const QString& cccdFront, const QString& cccdBack);
    Q_INVOKABLE void removeEmployee(int index);
    Q_INVOKABLE bool checkInCheckOut(const QString& phone, const QString& shiftDate, const QString& shiftTime);

    Q_INVOKABLE void importCSV(const QString& filePath);
    Q_INVOKABLE void exportCSV(const QString& filePath);

private:
    QList<Employee*> m_employees;
    Account *m_accountHandler;
};

#endif // EMPLOYEEMODEL_H