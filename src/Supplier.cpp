#include "Supplier.h"

Supplier::Supplier()
    : supplierID(""), name(""), contactPerson(""), phone(""), email(""), address(""), itemsSupplied(""), status("Hoạt động")
{
}

Supplier::Supplier(const QString &id, const QString &name, const QString &contactPerson,
                   const QString &phone, const QString &email, const QString &address,
                   const QString &itemsSupplied, const QString &status)
    : supplierID(id), name(name), contactPerson(contactPerson), phone(phone),
    email(email), address(address), itemsSupplied(itemsSupplied), status(status)
{
}

Supplier::~Supplier() {}