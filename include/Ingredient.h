#ifndef INGREDIENT_H
#define INGREDIENT_H

#include <string>

class Ingredient {
private:
    std::string ingredientID;
    std::string name;
    double quantity;
    std::string unit; // Ví dụ: "kg", "lit", "hop"

public:
    Ingredient();
    ~Ingredient();

    // Gợi ý các hàm getter/setter sau này
    // void restock(double amount);
};

#endif // INGREDIENT_H