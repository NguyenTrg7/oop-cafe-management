#ifndef SUPPLIER_H
#define SUPPLIER_H

#include <string>

class Supplier {
private:
    std::string supplierID;
    std::string name;
    std::string contactInfo;

public:
    Supplier();
    ~Supplier();
};

#endif // SUPPLIER_H