#ifndef MENU_H
#define MENU_H

#include <string>
#include <vector>

// Cấu trúc đại diện cho một món nước trong quán
struct MenuItem {
    std::string id;
    std::string name;
    double price;
    std::string category; // Ví dụ: "Coffee", "Tea", "Cake"
};

class Menu {
private:
    std::vector<MenuItem> items; // Danh sách các món đang có

public:
    // Constructor & Destructor
    Menu();
    ~Menu();

    // Các phương thức quản lý menu
    void addMenuItem(const std::string& id, const std::string& name, double price, const std::string& category);
    void removeMenuItem(const std::string& id);
    void displayMenu() const;

    // Bạn có thể khai báo thêm các hàm tìm kiếm, tính toán... ở đây
};

#endif // MENU_H