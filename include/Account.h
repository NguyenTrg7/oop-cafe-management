#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <string>

class Account {
private:
    std::string username;
    std::string password;
    std::string role; // Ví dụ: "Admin", "Staff"

public:
    Account();
    ~Account();

    // Gợi ý hàm xác thực
    // bool login(const std::string& inputUser, const std::string& inputPass);
};

#endif // ACCOUNT_H