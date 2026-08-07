#ifndef SUPPLIER_H
#define SUPPLIER_H

#include <QString>

class Supplier {
private:
    QString supplierID;
    QString name;
    QString contactPerson;
    QString phone;
    QString email;
    QString address;
    QString itemsSupplied;
    QString status;

public:
    Supplier();
    Supplier(const QString &id, const QString &name, const QString &contactPerson,
             const QString &phone, const QString &email, const QString &address,
             const QString &itemsSupplied, const QString &status = "Hoạt động");
    ~Supplier();

    QString getID() const { return supplierID; }
    QString getName() const { return name; }
    QString getContactPerson() const { return contactPerson; }
    QString getPhone() const { return phone; }
    QString getEmail() const { return email; }
    QString getAddress() const { return address; }
    QString getItemsSupplied() const { return itemsSupplied; }
    QString getStatus() const { return status; }

    void setID(const QString &id) { supplierID = id; }
    void setName(const QString &n) { name = n; }
    void setContactPerson(const QString &cp) { contactPerson = cp; }
    void setPhone(const QString &p) { phone = p; }
    void setEmail(const QString &e) { email = e; }
    void setAddress(const QString &a) { address = a; }
    void setItemsSupplied(const QString &it) { itemsSupplied = it; }
    void setStatus(const QString &st) { status = st; }
};

#endif // SUPPLIER_H